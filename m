From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Philosophical question:  Is a UDP multicast datagram for which
 there is no socket match a drop or an ignore?
Date: Tue, 30 Sep 2014 17:29:18 -0700
Message-ID: <1412123358.16704.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <542B3831.5030701@hp.com>
	 <1412119398.16704.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <542B4950.8050301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41774 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaJAA3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:29:20 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so24925pde.6
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 17:29:20 -0700 (PDT)
In-Reply-To: <542B4950.8050301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 17:22 -0700, Rick Jones wrote:
> On 09/30/2014 04:23 PM, Eric Dumazet wrote:
> > On Tue, 2014-09-30 at 16:09 -0700, Rick Jones wrote:
> >> I've been looking at some additional perf <mutter> -e skb_kfree_skb
> >> results, this time with a laptop connected to a corporate network with a
> >> large number of Windows systems sending out what they are wont to
> >> send...  The laptop is just sitting there no active netperfs or anything :)
> >>
> >> I see profile hits for __udp4_lib_mcast_deliver() which has a
> >> kfree_skb() call which will happen if either there were no sockets
> >> found, or if an integral multiple of ARRAY_SIZE(stack) sockets are
> >> found.  I'm assuming the latter is exceedingly rare.
> >>
> >> Anywho, the philosophical question - is such a situation a drop
> >> (indicating the existing kfree_skb()), or is it an ignore (indicating a
> >> consume_skb())?  Should there be a statistic incremented for either of
> >> those?
> >
> > I guess we lack a UDP_MIB_NOPORTS increase here.
> 
> I was going back and forth on that - since it is a multicast it may not 
> have really been directed at us in which case it would be an ignore (and 
> perhaps a new "ignored" stat?).  But on the assumption that it should 
> indeed remain a drop, and so a kfree_skb(), something along the lines of:
> 

> 
> ?  The idea being that in the unlikely event there were indeed enough 
> matches to trigger the flush_stack in the for_each and only enough for 
> that it will be a consume_skb() and no statistic rather than a 
> kfree_skb() and a statistic increment.

Yes, please submit your patch formally, maybe using a more complete
form ? ;)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db5471bb5..be7db86046af 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1656,6 +1656,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif = skb->dev->ifindex;
 	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+	bool delivered = false;
 
 	if (use_hash2) {
 		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
@@ -1674,6 +1675,7 @@ start_lookup:
 					dif, hnum)) {
 			if (unlikely(count == ARRAY_SIZE(stack))) {
 				flush_stack(stack, count, skb, ~0);
+				delivered = true;
 				count = 0;
 			}
 			stack[count++] = sk;
@@ -1694,8 +1696,11 @@ start_lookup:
 	 */
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
-	} else {
+	} else if (!delivered) {
+		UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 		kfree_skb(skb);
+	} else {
+		consume_skb(skb);
 	}
 	return 0;
 }
