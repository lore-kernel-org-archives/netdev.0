From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Tue, 01 Mar 2011 17:51:14 +0100
Message-ID: <4D6D2402.6020705@trash.net>
References: <20110221150710.GA5651@nord.niifaq.ru>	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>	 <4D6A6A5F.4030707@free.fr> <1298836236.8726.109.camel@edumazet-laptop>	 <4D6AB578.3010704@free.fr> <1298879114.8726.131.camel@edumazet-laptop> <4D6CF4A8.6000205@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1CAQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 11:51:13 -0500
In-Reply-To: <4D6CF4A8.6000205@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.03.2011 14:29, Daniel Lezcano wrote:
> On 02/28/2011 08:45 AM, Eric Dumazet wrote:
>>> In the normal case, dummy0 is supposed to drop the packets. But with
>>> macvlan these packets are broadcasted to the other macvlan ports, so no
>>> checksum is computed when the packets are transmitted between macvlan1
>>> and macvlan2.
>> So where frames get bad checksums ?
>>
>> In this "bridge" mode, I suspect the broadcast is done _before_ sending
>> frame to dummy, so maybe macvlan should not inherit from lowerdev in
>> this particular case ?
> 
> Hi Eric,
> 
> yes, you are right, the packets are sent before.
> 
> In the 'macvlan_queue_xmit', the code checks the dev is in 'bridge'
> mode. If so, it looks if there is a destination port for the packet and
> then calls the 'forward' callback which is 'dev_forward_skb'.
> 
> I was able to reproduce the same problem with qemu and an emulated
> 'e1000' card instead of dummy0. The packets are dropped too.
> 
> Patrick, do you have any suggestions to fix this ?

Since the frames are only looped back locally, I suppose the easiest
fix would be to mark them with CHECKSUM_UNNECESSARY. Alternatively
we need to complete the checksum manually, similar to what
dev_hard_start_xmit() does.
