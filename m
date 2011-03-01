From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Tue, 01 Mar 2011 21:04:42 +0100
Message-ID: <4D6D515A.8060707@free.fr>
References: <20110221150710.GA5651@nord.niifaq.ru>	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>	 <4D6A6A5F.4030707@free.fr> <1298836236.8726.109.camel@edumazet-laptop>	 <4D6AB578.3010704@free.fr> <1298879114.8726.131.camel@edumazet-laptop> <4D6CF4A8.6000205@free.fr> <4D6D2402.6020705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:60647 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757193Ab1CAUEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 15:04:52 -0500
In-Reply-To: <4D6D2402.6020705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2011 05:51 PM, Patrick McHardy wrote:
> On 01.03.2011 14:29, Daniel Lezcano wrote:
>> On 02/28/2011 08:45 AM, Eric Dumazet wrote:
>>>> In the normal case, dummy0 is supposed to drop the packets. But with
>>>> macvlan these packets are broadcasted to the other macvlan ports, so no
>>>> checksum is computed when the packets are transmitted between macvlan1
>>>> and macvlan2.
>>> So where frames get bad checksums ?
>>>
>>> In this "bridge" mode, I suspect the broadcast is done _before_ sending
>>> frame to dummy, so maybe macvlan should not inherit from lowerdev in
>>> this particular case ?
>> Hi Eric,
>>
>> yes, you are right, the packets are sent before.
>>
>> In the 'macvlan_queue_xmit', the code checks the dev is in 'bridge'
>> mode. If so, it looks if there is a destination port for the packet and
>> then calls the 'forward' callback which is 'dev_forward_skb'.
>>
>> I was able to reproduce the same problem with qemu and an emulated
>> 'e1000' card instead of dummy0. The packets are dropped too.
>>
>> Patrick, do you have any suggestions to fix this ?
> Since the frames are only looped back locally, I suppose the easiest
> fix would be to mark them with CHECKSUM_UNNECESSARY. Alternatively
> we need to complete the checksum manually, similar to what
> dev_hard_start_xmit() does.

That sounds very simple to fix, maybe too much simple :)

I did the following change:

---
  drivers/net/macvlan.c |    1 +
  1 file changed, 1 insertion(+)

Index: linux-next/drivers/net/macvlan.c
===================================================================
--- linux-next.orig/drivers/net/macvlan.c
+++ linux-next/drivers/net/macvlan.c
@@ -222,6 +222,7 @@ static int macvlan_queue_xmit(struct sk_

         if (vlan->mode == MACVLAN_MODE_BRIDGE) {
                 const struct ethhdr *eth = (void *)skb->data;
+               skb->ip_summed = CHECKSUM_UNNECESSARY;

                 /* send to other bridge ports directly */
                 if (is_multicast_ether_addr(eth->h_dest)) {


and that fixed the problem. Do you think it is acceptable ?

Thanks

   -- Daniel
