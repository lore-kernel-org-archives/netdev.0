From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Philosophical question:  Is a UDP multicast datagram for which
 there is no socket match a drop or an ignore?
Date: Tue, 30 Sep 2014 17:22:40 -0700
Message-ID: <542B4950.8050301@hp.com>
References: <542B3831.5030701@hp.com> <1412119398.16704.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:50323 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaJAAWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:22:42 -0400
In-Reply-To: <1412119398.16704.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 04:23 PM, Eric Dumazet wrote:
> On Tue, 2014-09-30 at 16:09 -0700, Rick Jones wrote:
>> I've been looking at some additional perf <mutter> -e skb_kfree_skb
>> results, this time with a laptop connected to a corporate network with a
>> large number of Windows systems sending out what they are wont to
>> send...  The laptop is just sitting there no active netperfs or anything :)
>>
>> I see profile hits for __udp4_lib_mcast_deliver() which has a
>> kfree_skb() call which will happen if either there were no sockets
>> found, or if an integral multiple of ARRAY_SIZE(stack) sockets are
>> found.  I'm assuming the latter is exceedingly rare.
>>
>> Anywho, the philosophical question - is such a situation a drop
>> (indicating the existing kfree_skb()), or is it an ignore (indicating a
>> consume_skb())?  Should there be a statistic incremented for either of
>> those?
>
> I guess we lack a UDP_MIB_NOPORTS increase here.

I was going back and forth on that - since it is a multicast it may not 
have really been directed at us in which case it would be an ignore (and 
perhaps a new "ignored" stat?).  But on the assumption that it should 
indeed remain a drop, and so a kfree_skb(), something along the lines of:


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..376e3d3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1656,6 +1656,7 @@ static int __udp4_lib_mcast_deliver(struct net 
*net, struc
         int dif = skb->dev->ifindex;
         unsigned int count = 0, offset = offsetof(typeof(*sk), 
sk_nulls_node);
         unsigned int hash2 = 0, hash2_any = 0, use_hash2 = 
(hslot->count > 10);
+       unsigned int inner_flushed = 0;

         if (use_hash2) {
                 hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), 
hnum) &
@@ -1694,8 +1695,12 @@ start_lookup:
          */
         if (count) {
                 flush_stack(stack, count, skb, count - 1);
-       } else {
+       } else if (!inner_flushed) {
+               UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, 0);
                 kfree_skb(skb);
+       } else {
+               /* there were matches flushed in the for_each */
+               consume_skb(skb);
         }
         return 0;
  }


?  The idea being that in the unlikely event there were indeed enough 
matches to trigger the flush_stack in the for_each and only enough for 
that it will be a consume_skb() and no statistic rather than a 
kfree_skb() and a statistic increment.

(likely munged by my mailer)

rick
