From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Vpn-failover] [RFC] IPSEC failover - Netlink part
Date: Thu, 04 Nov 2004 19:15:54 +0100
Message-ID: <418A71DA.2090607@trash.net>
References: <1099045435.2888.47.camel@nienna.balabit> <418A3630.1040900@astaro.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vpn-failover@lists.balabit.hu, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Ulrich Weber <uweber@astaro.de>
In-Reply-To: <418A3630.1040900@astaro.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ulrich Weber wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Hi,
>
> I take the opportunity to post my code as well. At the moment I'm 
> working at
> the same as Krisztian. My solutions however is for openswan, which uses
> netlink instead of pfkey.
>
> Please find attached the appropriate netlink modifications to
> include/linux/xfrm.h and net/xfrm/xfrm_users.c
>
> In theses patches, a new netlink group (XFRMGRP_REPLAY) is added to 
> notify
> about seq number changes. Each notify message contains a xfrm_usersa_id
> struct with the replay struct attached as rt attribute. In addition, 
> these
> replay struct is also attached at ipsec sa dumps.
>
> Any comments are welcome :)


Some minor bugs, see below.

Regards
Patrick

>------------------------------------------------------------------------
>
>--- linux.org/include/linux/xfrm.h.	2004-10-11 04:57:07.000000000 +0200
>+++ linux/include/linux/xfrm.h	2004-10-18 17:00:43.000000000 +0200
>@@ -140,6 +140,9 @@
> 	XFRM_MSG_FLUSHPOLICY,
> #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FLUSHPOLICY
> 
>+	XFRM_MSG_UPDSEQ,
>+#define XFRM_MSG_UPDSEQ XFRM_MSG_UPDSEQ
>+
> 	XFRM_MSG_MAX
> };
> 
>@@ -171,6 +174,7 @@
> 	XFRMA_ALG_COMP,		/* struct xfrm_algo */
> 	XFRMA_ENCAP,		/* struct xfrm_algo + struct xfrm_encap_tmpl */
> 	XFRMA_TMPL,		/* 1 or more struct xfrm_user_tmpl */
>+	XFRMA_REPLAY,		/* struct xfrm_replay_state */ 
> 	__XFRMA_MAX
> 
> #define XFRMA_MAX (__XFRMA_MAX - 1)
>@@ -258,5 +258,6 @@
>
> #define XFRMGRP_ACQUIRE                1
> #define XFRMGRP_EXPIRE         2
>+#define XFRMGRP_REPLAY         3
>
> #endif /* _LINUX_XFRM_H */
>  
>
>------------------------------------------------------------------------
>
>--- linux.org/net/xfrm/xfrm_user.c	2004-10-18 23:54:32.000000000 +0200
>+++ linux/net/xfrm/xfrm_user.c	2004-10-21 16:27:59.000000000 +0200
>@@ -240,6 +240,12 @@
> 	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
> 		goto error;
> 
>+        if(xfrma[XFRMA_REPLAY-1]) {
>+                struct xfrm_replay_state *replay;
>+                replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
>+                x->replay = *replay;
>+        }
>+
> 	err = -ENOENT;
> 	x->type = xfrm_get_type(x->id.proto, x->props.family);
> 	if (x->type == NULL)
>@@ -368,6 +375,8 @@
> 	if (x->encap)
> 		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
> 
>+	RTA_PUT(skb, XFRMA_REPLAY, sizeof(x->replay), &x->replay);
>+
> 	nlh->nlmsg_len = skb->tail - b;
> out:
> 	sp->this_idx++;
>@@ -852,6 +861,27 @@
> 	return 0;
> }
> 
>+static int xfrm_update_seq(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
>+{
>+        struct xfrm_state *x;
>+        struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
>  
>
>+	struct xfrm_replay_state *replay;
>+ 
>+	x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
>+        if (x == NULL) {
>+		printk(KERN_INFO "Found no xfrm state for sa seq update\n");
>+                return -ESRCH;
>+		}
>+
>+	if(xfrma[XFRMA_REPLAY-1]) {
>+		replay = RTA_DATA(xfrma[XFRMA_REPLAY - 1]);
>+		x->replay = *replay;
>  
>
>+		}
>+	else return -EINVAL;
>  
>
^^ leaks xfrm_state reference

>+		
>+	return 0;
>  
>
^^ same here

>+} 
>+
> static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
> 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* NEW SA */
> 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),	/* DEL SA */
>@@ -867,6 +897,7 @@
> 	NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
> 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),	/* FLUSH SA */
> 	NLMSG_LENGTH(0),				/* FLUSH POLICY */
>+	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),/* UPD SEQ */
>  
>
^^ what about struct xfrm_replay_state ?
