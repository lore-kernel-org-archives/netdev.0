From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 2/5] Bad dereference of xfrm_state in pf_key
Date: Tue, 13 Jan 2004 13:22:36 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131321310.25742-100000@linux-udp14999547uds>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In pfkey_get(), the xfrm_state is dereferenced after it is dropped,
which could lead to dereferencing freed memory. This can also be done
by dropping the reference before the pfkey_broadcast() and in the IS_ERR
case.

thanks,

- KK

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
