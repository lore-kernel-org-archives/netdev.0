From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Bugs in xfrm
Date: Fri, 9 Jan 2004 17:40:03 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401091339170.10121-100000@linux-udp14999547uds>
References: <20031108223049.36651f8d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>, <kumarkr@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031108223049.36651f8d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

The following look to be bugs in xfrm related code.

1. In xfrm_lookup, a couple of bugs :
   - the found or allocated xfrm_states are not passed correctly to
     xfrm_bundle_create (and to the subsequent frees in case of create
     failing) if the first xfrm_tmpl_resolve failed and the second one
     succeeded.
   - error handling is wrong.

2. In pfkey_get(), the xfrm_state is dereferenced after it is dropped,
which could lead to dereferencing freed memory.

3. ipcomp_tunnel_create and xfrm_state_construct don't set x->km.state
to XFRM_STATE_DEAD. This can lead to the BUG_TRAP in __xfrm_state_destroy
when xfrm_state_put() finds this is the last reference. This was reported
as one of the problems of [Bug 1754] some time back.

4. I am not sure of this one. I think dst_free() cannot be used when
a bundle of dst's are allocated and have to be freed. We need a new
dst_bundle_free() routine to free all linked dst's ?? Change is in
__xfrm[46]_bundle_create & xfrm_lookup(), the lookup one I am not very
sure. Why are we doing a dst_put(), shouldn't this be a free of all
dst's off the dst->child list since the routine marking 'dead' cleared all
entries off the dst->next list ?

These changes compile cleanly, but I couldn't test since these are
corner cases. Please let me know if this can be applied. I am sending
as one patch file for now instead of multiple files as they all small.

Thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6.org/include/net/dst.h linux-2.6.0-rc2-bk6/include/net/dst.h
--- linux-2.6.0-rc2-bk6.org/include/net/dst.h	2004-01-09 17:08:18.000000000 -0800
+++ linux-2.6.0-rc2-bk6/include/net/dst.h	2004-01-09 17:08:55.000000000 -0800
@@ -168,6 +168,7 @@

 extern void * dst_alloc(struct dst_ops * ops);
 extern void __dst_free(struct dst_entry * dst);
+extern void dst_bundle_free(struct dst_entry * dst);
 extern struct dst_entry *dst_destroy(struct dst_entry * dst);

 static inline void dst_free(struct dst_entry * dst)
diff -ruN linux-2.6.0-rc2-bk6.org/net/ipv4/ipcomp.c linux-2.6.0-rc2-bk6/net/ipv4/ipcomp.c
--- linux-2.6.0-rc2-bk6.org/net/ipv4/ipcomp.c	2004-01-05 13:43:50.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/ipv4/ipcomp.c	2004-01-09 13:00:22.000000000 -0800
@@ -294,6 +294,7 @@
 	return t;

 error:
+	t->km.state = XFRM_STATE_DEAD;
 	xfrm_state_put(t);
 	t = NULL;
 	goto out;
diff -ruN linux-2.6.0-rc2-bk6.org/net/ipv4/xfrm4_policy.c linux-2.6.0-rc2-bk6/net/ipv4/xfrm4_policy.c
--- linux-2.6.0-rc2-bk6.org/net/ipv4/xfrm4_policy.c	2004-01-09 15:02:48.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/ipv4/xfrm4_policy.c	2004-01-09 16:11:57.000000000 -0800
@@ -162,7 +162,7 @@

 error:
 	if (dst)
-		dst_free(dst);
+		dst_bundle_free(dst);
 	return err;
 }

diff -ruN linux-2.6.0-rc2-bk6.org/net/ipv6/xfrm6_policy.c linux-2.6.0-rc2-bk6/net/ipv6/xfrm6_policy.c
--- linux-2.6.0-rc2-bk6.org/net/ipv6/xfrm6_policy.c	2004-01-09 16:43:45.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/ipv6/xfrm6_policy.c	2004-01-09 16:44:03.000000000 -0800
@@ -184,7 +184,7 @@

 error:
 	if (dst)
-		dst_free(dst);
+		dst_bundle_free(dst);
 	return err;
 }

diff -ruN linux-2.6.0-rc2-bk6.org/net/key/af_key.c linux-2.6.0-rc2-bk6/net/key/af_key.c
--- linux-2.6.0-rc2-bk6.org/net/key/af_key.c	2004-01-05 13:45:47.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/key/af_key.c	2004-01-09 12:41:30.000000000 -0800
@@ -1283,6 +1283,7 @@

 static int pfkey_get(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
+	__u8 proto;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 	struct xfrm_state *x;
@@ -1297,6 +1298,7 @@
 		return -ESRCH;

 	out_skb = pfkey_xfrm_state2msg(x, 1, 3);
+	proto = x->id.proto;
 	xfrm_state_put(x);
 	if (IS_ERR(out_skb))
 		return  PTR_ERR(out_skb);
@@ -1304,7 +1306,7 @@
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
 	out_hdr->sadb_msg_type = SADB_DUMP;
-	out_hdr->sadb_msg_satype = pfkey_proto2satype(x->id.proto);
+	out_hdr->sadb_msg_satype = pfkey_proto2satype(proto);
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_reserved = 0;
 	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
diff -ruN linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c
--- linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_policy.c	2004-01-09 12:42:53.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/xfrm/xfrm_policy.c	2004-01-09 17:31:05.000000000 -0800
@@ -694,6 +694,16 @@

 static int stale_bundle(struct dst_entry *dst);

+void dst_bundle_free(struct dst_entry *dst)
+{
+	struct dst_entry *next;
+
+	while (dst) {
+		next = dst->child;
+		dst_free(dst);
+	}
+}
+
 /* Main function: finds/creates a bundle for given flow.
  *
  * At the moment we eat a raw IP route. Mostly to speed up lookups
@@ -799,9 +809,16 @@
 					goto restart;
 				}
 			}
-			if (err)
+			if (err < 0)
 				goto error;
-		} else if (nx == 0) {
+			/*
+			 * Save number of xfrm_state's found/created for both
+			 * the nx == 0 check below as well as to pass the
+			 * right value to xfrm_bundle_create().
+			 */
+			nx = err;
+		}
+		if (nx == 0) {
 			/* Flow passes not transformed. */
 			xfrm_pol_put(policy);
 			return 0;
@@ -827,8 +844,8 @@
 			write_unlock_bh(&policy->lock);

 			xfrm_pol_put(policy);
-			if (dst)
-				dst_free(dst);
+			if (dst) /* 'dead' freed dst->next list only */
+				dst_bundle_free(dst);
 			goto restart;
 		}
 		dst->next = policy->bundles;
diff -ruN linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_user.c linux-2.6.0-rc2-bk6/net/xfrm/xfrm_user.c
--- linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_user.c	2004-01-09 12:57:42.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/xfrm/xfrm_user.c	2004-01-09 12:59:00.000000000 -0800
@@ -241,6 +241,7 @@
 	return x;

 error:
+	x->km.state = XFRM_STATE_DEAD;
 	xfrm_state_put(x);
 error_no_put:
 	*errp = err;
