From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Wed, 18 Jun 2008 10:52:30 +0200
Message-ID: <4858CCCE.7060404@trash.net>
References: <20080617132410.GB4632@ff.dom.local>	<4857BBB6.6010709@trash.net>	<20080617134303.GC4632@ff.dom.local> <20080617.213012.132043917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000302020400030404010301"
Cc: jarkao2@gmail.com, marcel@holtmann.org, netdev@vger.kernel.org,
	mingo@elte.hu, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56732 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbYFRIwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 04:52:38 -0400
In-Reply-To: <20080617.213012.132043917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000302020400030404010301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> In the meantime should I apply Patrick's current patch
> from this thread?

I think that makes sense, the module unload race is present anyway.
>
> If so I'd like a proper commit message and signoff, thanks!

Attached the patch with a proper changelog.






--------------000302020400030404010301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

netlink: genl: fix circular locking

genetlink has a circular locking dependency when dumping the registered
families:

- dump start:
genl_rcv()            : take genl_mutex
genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
netlink_dump_start(),
netlink_dump()        : take nlk->cb_mutex
ctrl_dumpfamily()     : try to detect this case and not take genl_mutex a
                        second time

- dump continuance:
netlink_rcv()         : call netlink_dump
netlink_dump          : take nlk->cb_mutex
ctrl_dumpfamily()     : take genl_mutex

Register genl_lock as callback mutex with netlink to fix this. This slightly
widens an already existing module unload race, the genl ops used during the
dump might go away when the module is unloaded. Thomas Graf is working on a
seperate fix for this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f5aa23c..3e1191c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -444,8 +444,11 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (ops->dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		return netlink_dump_start(genl_sock, skb, nlh,
-					  ops->dumpit, ops->done);
+		genl_unlock();
+		err = netlink_dump_start(genl_sock, skb, nlh,
+					 ops->dumpit, ops->done);
+		genl_lock();
+		return err;
 	}
 
 	if (ops->doit == NULL)
@@ -603,9 +606,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
-	if (chains_to_skip != 0)
-		genl_lock();
-
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
 			continue;
@@ -623,9 +623,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 errout:
-	if (chains_to_skip != 0)
-		genl_unlock();
-
 	cb->args[0] = i;
 	cb->args[1] = n;
 
@@ -770,7 +767,7 @@ static int __init genl_init(void)
 
 	/* we'll bump the group number right afterwards */
 	genl_sock = netlink_kernel_create(&init_net, NETLINK_GENERIC, 0,
-					  genl_rcv, NULL, THIS_MODULE);
+					  genl_rcv, &genl_mutex, THIS_MODULE);
 	if (genl_sock == NULL)
 		panic("GENL: Cannot initialize generic netlink\n");
 

--------------000302020400030404010301--
