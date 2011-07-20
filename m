From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit
 methods
Date: Tue, 19 Jul 2011 17:52:49 -0700
Message-ID: <4E2626E1.6030005@candelatech.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>	 <1311105738.3113.11.camel@edumazet-laptop>	 <20110719202922.GA2352@minipsycho>	 <1311108107.3113.22.camel@edumazet-laptop>	 <20110720001904.GA1992@neilslaptop.think-freely.org> <1311122593.3113.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59942 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab1GTAxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 20:53:23 -0400
In-Reply-To: <1311122593.3113.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2011 05:43 PM, Eric Dumazet wrote:
> Le mardi 19 juillet 2011 =C3=A0 20:19 -0400, Neil Horman a =C3=A9crit=
 :

>> I'm sensitive to the performance impact, but I would much rather see=
 a lower
>> performing pktgen that doesn't randomly crash, and bring the perform=
ance back up
>> in a safe, reliable way.  To that end, I've been starting to think a=
bout
>> pre-allocating a ring buffer of skbs with a skb->users count biased =
up to
>> prevent driver freeing.  That way we could detect 'unused skb's' by =
a user count
>> that was at the bias level.  Thoughts?
>>
>
> I dont know. I use pktgen maybe once per week and never got a single
> crash like this. We probably are very few pktgen users in the world, =
and
> we use it exactly to avoid calling skb_clone() or other expensive per
> xmit setup.
>
> Just remove pktgen from RedHat kernels, if you dont trust sysadmins.
> # CONFIG_PKTGEN is not set
>
> Alternatively, add a check to problematic drivers to _not_ mess skb i=
f
> skb_shared(skb) is true : eventually use skb_share_check()

When the features-flags work gets completed so that we can start adding
new flags, we could add a CANT_DO_MULTI_SKB flag to drivers with known
issues and then restrict pktgen config accordingly.

Upstream code already clears skb memory to avoid leaking kernel memory
contents, so if you take away multi-skb too, pktgen is going to suck
at what it is supposed to do:  run fast as possible.

If you want real fun, use pktgen on a wlan0 device...it will crash
regardless of whether you use multi-skb or not because of xmit-queue
number issues :P

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
