From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Thu, 1 Jun 2017 22:42:13 +0200
Message-ID: <75fccaea-0ebe-1a2a-27d7-ad30fd99f41d@6wind.com>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
 <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170601170246.GF2673@x240.lan>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37880 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdFAUmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 16:42:18 -0400
Received: by mail-wm0-f46.google.com with SMTP id d127so3205574wmf.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 13:42:17 -0700 (PDT)
In-Reply-To: <20170601170246.GF2673@x240.lan>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/06/2017 à 19:02, Flavio Leitner a écrit :
> On Thu, Jun 01, 2017 at 10:00:07AM +0200, Nicolas Dichtel wrote:
>> The NETLINK_F_LISTEN_ALL_NSID otion enables to listen all netns that have a
>> nsid assigned into the netns where the netlink socket is opened.
>> The nsid is sent as metadata to userland, but the existence of this nsid is
>> checked only for netns that are different from the socket netns. Thus, if
>> no nsid is assigned to the socket netns, NETNSA_NSID_NOT_ASSIGNED is
>> reported to the userland. This value is confusing and useless.
>> After this patch, only valid nsid are sent to userland.
>>
>> Reported-by: Flavio Leitner <fbl@sysclose.org>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  net/netlink/af_netlink.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index ee841f00a6ec..7586d446d7dc 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -62,6 +62,7 @@
>>  #include <asm/cacheflush.h>
>>  #include <linux/hash.h>
>>  #include <linux/genetlink.h>
>> +#include <linux/net_namespace.h>
>>  
>>  #include <net/net_namespace.h>
>>  #include <net/sock.h>
>> @@ -1415,7 +1416,8 @@ static void do_one_broadcast(struct sock *sk,
>>  		goto out;
>>  	}
>>  	NETLINK_CB(p->skb2).nsid = peernet2id(sock_net(sk), p->net);
>> -	NETLINK_CB(p->skb2).nsid_is_set = true;
>> +	if (NETLINK_CB(p->skb2).nsid != NETNSA_NSID_NOT_ASSIGNED)
>> +		NETLINK_CB(p->skb2).nsid_is_set = true;
>>  	val = netlink_broadcast_deliver(sk, p->skb2);
>>  	if (val < 0) {
>>  		netlink_overrun(sk);
> 
> If the assumption is that nsid allocation can never fail or that if it
> does, we can't report to userspace, then the patch is good, but it
> doesn't sound like a good long term solution.
> 
> Let's consider that the allocation of an id fails for whatever reason.
> I think that should be reported to userspace to allow it to retry, or
> do something else to handle this situation properly.  Not sending
> anything means that it's in the same netns as the old kernels did,
> which is incorrect.
This is correct, because if nsid allocation fails, no netlink messages from this
netns are sent to userspace (the check is done at the beginning of
do_one_broadcast). The only netns allowed to send netlink messages to userspace
without nsid is the netns of the socket.

> 
> On the other hand, with the original patch, if the socket and the
> device are in the same netns, we don't need to report any ID.  Previous
> kernels did that, so we are not breaking anything.  When the netns
> differs, then we either should report the real ID or an error.
> 
I don't understand. With or without my last patch, the kernel sends netlink
messages of other netns than the netns where the socket is opened, only if an
nsid is assigned.


Nicolas

ps: I won't be able to read my emails before monday ;-)
