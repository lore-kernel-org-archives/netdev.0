From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Mon, 16 Jun 2008 23:48:01 +0200
Message-ID: <4856DF91.30606@trash.net>
References: <20080616213417.GA14988@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304090905080605090909"
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44184 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453AbYFPWEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 18:04:01 -0400
In-Reply-To: <20080616213417.GA14988@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040304090905080605090909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> Marcel Holtmann wrote, On 06/14/2008 02:35 PM:
> ...
>   
>> =======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 2.6.26-rc2 #5
>> -------------------------------------------------------
>> hcid/4136 is trying to acquire lock:
>>  (genl_mutex){--..}, at: [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174
>>
>> but task is already holding lock:
>>  (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c
>>
>> which lock already depends on the new lock.
>>     
> ...
>
> Hi,
>
> IMHO it looks like a real lockup threat. Probably it needs something
> better, but for now here is my simplistic patch proposal for testing.
>   
So we have:

genl_rcv()            : take genl_mutex
genl_rcv_msg()        : call netlink_dump_start() while holding genl_mutex
netlink_dump_start(),
netlink_dump()        : take nlk->cb_mutex
ctrl_dumpfamily()     : try to detect this case and not take genl_mutex a
                        second time

netlink_rcv()         : call netlink_dump
netlink_dump          : take nlk->cb_mutex
ctrl_dumpfamily()     : take genl_mutex

which is a real bug.

It seems the best fix is to use genl_mutex for the netlink cb_mutex,
drop genl_mutex before calling netlink_dump_start and don't take it
in ctrl_dumpfamily, relying completely on af_netlink.c for dump
locking. Unfortunately this creates a race since the ops passed to
netlink_dump_start are also protect by the mutex, so this patch
is just for testing whether it fixes the warning.

On second though - that race seems to be present already since
the ops can be unregistered and the module unloaded while a dump
is in progress.


--------------040304090905080605090909
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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
 

--------------040304090905080605090909--
