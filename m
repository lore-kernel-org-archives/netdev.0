From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] Re: IPSec: setkey -DP freezes machine
Date: Mon, 3 Mar 2003 23:13:55 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303032238240.10142-100000@blackbird.intercode.com.au>
References: <20030303.013451.20307573.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: toml@us.ibm.com, <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030303.013451.20307573.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Mar 2003, David S. Miller wrote:

>    Alternatively, a family parameter could be added to the compile_policy() 
>    operation, but this duplicates data already present in our native 
>    xfrm_userpolicy_info format.
> 
> I like this solution, it seems the cleanest.
> 

Ok, here's a patch which does this.

I've also added check to verify_newpolicy_info() so that we don't run into
the same problem for policies provided via the netlink interface.

Tom, would you let me know if this works for you, as my racoon isn't
working yet.


- James
-- 
James Morris
<jmorris@intercode.com.au>



diff -urN -X dontdiff linux-2.5.63.orig/include/net/xfrm.h linux-2.5.63.w1/include/net/xfrm.h
--- linux-2.5.63.orig/include/net/xfrm.h	Fri Feb 21 00:44:01 2003
+++ linux-2.5.63.w1/include/net/xfrm.h	Mon Mar  3 22:19:40 2003
@@ -223,7 +223,7 @@
 	char			*id;
 	int			(*notify)(struct xfrm_state *x, int event);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
-	struct xfrm_policy	*(*compile_policy)(int opt, u8 *data, int len, int *dir);
+	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
diff -urN -X dontdiff linux-2.5.63.orig/net/ipv4/xfrm_state.c linux-2.5.63.w1/net/ipv4/xfrm_state.c
--- linux-2.5.63.orig/net/ipv4/xfrm_state.c	Fri Feb 21 00:44:01 2003
+++ linux-2.5.63.w1/net/ipv4/xfrm_state.c	Mon Mar  3 22:23:53 2003
@@ -680,7 +680,7 @@
 	err = -EINVAL;
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		pol = km->compile_policy(optname, data, optlen, &err);
+		pol = km->compile_policy(sk->family, optname, data, optlen, &err);
 		if (err >= 0)
 			break;
 	}
diff -urN -X dontdiff linux-2.5.63.orig/net/ipv4/xfrm_user.c linux-2.5.63.w1/net/ipv4/xfrm_user.c
--- linux-2.5.63.orig/net/ipv4/xfrm_user.c	Tue Feb 25 15:03:26 2003
+++ linux-2.5.63.w1/net/ipv4/xfrm_user.c	Mon Mar  3 22:56:34 2003
@@ -538,6 +538,21 @@
 		return -EINVAL;
 	};
 
+	switch (p->family) {
+	case AF_INET:
+		break;
+
+	case AF_INET6:
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		break;
+#else
+		return  -EAFNOSUPPORT;
+#endif
+
+	default:
+		return -EINVAL;
+	};
+
 	return verify_policy_dir(p->dir);
 }
 
@@ -1057,7 +1072,8 @@
 /* User gives us xfrm_user_policy_info followed by an array of 0
  * or more templates.
  */
-struct xfrm_policy *xfrm_compile_policy(int opt, u8 *data, int len, int *dir)
+struct xfrm_policy *xfrm_compile_policy(u16 family, int opt,
+                                        u8 *data, int len, int *dir)
 {
 	struct xfrm_userpolicy_info *p = (struct xfrm_userpolicy_info *)data;
 	struct xfrm_user_tmpl *ut = (struct xfrm_user_tmpl *) (p + 1);
diff -urN -X dontdiff linux-2.5.63.orig/net/key/af_key.c linux-2.5.63.w1/net/key/af_key.c
--- linux-2.5.63.orig/net/key/af_key.c	Tue Feb 25 15:03:26 2003
+++ linux-2.5.63.w1/net/key/af_key.c	Mon Mar  3 22:30:56 2003
@@ -2420,7 +2420,8 @@
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
-static struct xfrm_policy *pfkey_compile_policy(int opt, u8 *data, int len, int *dir)
+static struct xfrm_policy *pfkey_compile_policy(u16 family, int opt,
+                                                u8 *data, int len, int *dir)
 {
 	struct xfrm_policy *xp;
 	struct sadb_x_policy *pol = (struct sadb_x_policy*)data;
@@ -2451,6 +2452,7 @@
 	xp->lft.hard_byte_limit = XFRM_INF;
 	xp->lft.soft_packet_limit = XFRM_INF;
 	xp->lft.hard_packet_limit = XFRM_INF;
+	xp->family = family;
 
 	xp->xfrm_nr = 0;
 	if (pol->sadb_x_policy_type == IPSEC_POLICY_IPSEC &&
