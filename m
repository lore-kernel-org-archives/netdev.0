From: Ulrich Weber <uweber@astaro.de>
Subject: Re: [Vpn-failover] [RFC] IPSEC failover - Netlink part
Date: Thu, 04 Nov 2004 15:01:20 +0100
Message-ID: <418A3630.1040900@astaro.de>
References: <1099045435.2888.47.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080205020700070500050104"
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: vpn-failover@lists.balabit.hu
In-Reply-To: <1099045435.2888.47.camel@nienna.balabit>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080205020700070500050104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

I take the opportunity to post my code as well. At the moment I'm working at
the same as Krisztian. My solutions however is for openswan, which uses
netlink instead of pfkey.

Please find attached the appropriate netlink modifications to
include/linux/xfrm.h and net/xfrm/xfrm_users.c

In theses patches, a new netlink group (XFRMGRP_REPLAY) is added to notify
about seq number changes. Each notify message contains a xfrm_usersa_id
struct with the replay struct attached as rt attribute. In addition, these
replay struct is also attached at ipsec sa dumps.

Any comments are welcome :)

Cheers
~ Ulrich
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBijYw22t2oTuElzoRAp0LAKCdKc4CgzWqLJLh4/U2oRFA96e49gCgk2R3
Rff8wpPVtUZtlCwJUEnP+34=
=b6vx
-----END PGP SIGNATURE-----

--------------080205020700070500050104
Content-Type: text/x-chdr;
 name="linux_xfrm.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux_xfrm.h"

--- linux.org/include/linux/xfrm.h.	2004-10-11 04:57:07.000000000 +0200
+++ linux/include/linux/xfrm.h	2004-10-18 17:00:43.000000000 +0200
@@ -140,6 +140,9 @@
 	XFRM_MSG_FLUSHPOLICY,
 #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FLUSHPOLICY
 
+	XFRM_MSG_UPDSEQ,
+#define XFRM_MSG_UPDSEQ XFRM_MSG_UPDSEQ
+
 	XFRM_MSG_MAX
 };
 
@@ -171,6 +174,7 @@
 	XFRMA_ALG_COMP,		/* struct xfrm_algo */
 	XFRMA_ENCAP,		/* struct xfrm_algo + struct xfrm_encap_tmpl */
 	XFRMA_TMPL,		/* 1 or more struct xfrm_user_tmpl */
+	XFRMA_REPLAY,		/* struct xfrm_replay_state */ 
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -258,5 +258,6 @@

 #define XFRMGRP_ACQUIRE                1
 #define XFRMGRP_EXPIRE         2
+#define XFRMGRP_REPLAY         3

 #endif /* _LINUX_XFRM_H */

--------------080205020700070500050104
Content-Type: text/x-patch;
 name="xfrm_user.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_user.diff"

--- linux.org/net/xfrm/xfrm_user.c	2004-10-18 23:54:32.000000000 +0200
+++ linux/net/xfrm/xfrm_user.c	2004-10-21 16:27:59.000000000 +0200
@@ -240,6 +240,12 @@
 	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
 		goto error;
 
+        if(xfrma[XFRMA_REPLAY-1]) {
+                struct xfrm_replay_state *replay;
+                replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
+                x->replay = *replay;
+        }
+
 	err = -ENOENT;
 	x->type = xfrm_get_type(x->id.proto, x->props.family);
 	if (x->type == NULL)
@@ -368,6 +375,8 @@
 	if (x->encap)
 		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
+	RTA_PUT(skb, XFRMA_REPLAY, sizeof(x->replay), &x->replay);
+
 	nlh->nlmsg_len = skb->tail - b;
 out:
 	sp->this_idx++;
@@ -852,6 +861,27 @@
 	return 0;
 }
 
+static int xfrm_update_seq(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+{
+        struct xfrm_state *x;
+        struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
+	struct xfrm_replay_state *replay;
+ 
+	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+        if (x == NULL) {
+		printk(KERN_INFO "Found no xfrm state for sa seq update\n");
+                return -ESRCH;
+		}
+
+	if(xfrma[XFRMA_REPLAY-1]) {
+		replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
+		x->replay = *replay;
+		}
+	else return -EINVAL;
+		
+	return 0;
+} 
+
 static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* NEW SA */
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),	/* DEL SA */
@@ -867,6 +897,7 @@
 	NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),	/* FLUSH SA */
 	NLMSG_LENGTH(0),				/* FLUSH POLICY */
+	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),/* UPD SEQ */
 };
 
 static struct xfrm_link {
@@ -893,6 +924,7 @@
 	{},
 	{	.doit	=	xfrm_flush_sa		},
 	{	.doit	=	xfrm_flush_policy	},
+	{       .doit   =       xfrm_update_seq		},
 };
 
 static int xfrm_done(struct netlink_callback *cb)
@@ -1050,6 +1082,33 @@
 	return -1;
 }
 
+static int build_replay(struct sk_buff *skb, struct xfrm_state *x, int event)
+{
+        struct xfrm_usersa_id *id;
+        struct nlmsghdr *nlh;
+        unsigned char *b = skb->tail;
+
+        nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_UPDSEQ,
+                        sizeof(*id));
+        id = NLMSG_DATA(nlh);
+        nlh->nlmsg_flags = 0;
+
+	id->daddr = x->id.daddr;
+	id->spi = x->id.spi;
+	id->family = x->props.family;
+	id->proto = x->id.proto;
+
+	RTA_PUT(skb, XFRMA_REPLAY, sizeof(x->replay), &x->replay);
+
+        nlh->nlmsg_len = skb->tail - b;
+        return skb->len;
+
+rtattr_failure:
+nlmsg_failure:
+        skb_trim(skb, b - skb->data);
+        return -1;
+}
+
 static int xfrm_send_state_notify(struct xfrm_state *x, int hard)
 {
 	struct sk_buff *skb;
@@ -1218,12 +1277,28 @@
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_EXPIRE, GFP_ATOMIC);
 }
 
+static int xfrm_send_replay_notify(struct xfrm_state *x, int event) {
+        struct sk_buff *skb;
+
+        skb = alloc_skb(sizeof(struct xfrm_usersa_id) + sizeof(struct xfrm_replay_state) + 16, GFP_ATOMIC);
+        if (skb == NULL)
+                return -ENOMEM;
+
+        if (build_replay(skb, x, event) < 0)
+                BUG();
+
+        NETLINK_CB(skb).dst_groups = XFRMGRP_REPLAY;
+
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_REPLAY, GFP_ATOMIC);
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
 	.acquire	= xfrm_send_acquire,
 	.compile_policy	= xfrm_compile_policy,
 	.notify_policy	= xfrm_send_policy_notify,
+	.notify_seq	= xfrm_send_replay_notify,
 };
 
 static int __init xfrm_user_init(void)

--------------080205020700070500050104--
