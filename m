From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver code
Date: Wed, 13 Aug 2008 12:21:38 +0200
Message-ID: <19f34abd0808130321y1596a455qfffb49b0a039d2d6@mail.gmail.com>
References: <20080813095324.GA15055@ben.ifi.uio.no>
	 <20080813095942.GA9145@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Jeff Garzik" <jgarzik@pobox.com>
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:50049 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbYHMKVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:21:39 -0400
Received: by py-out-1112.google.com with SMTP id p76so1825960pyb.10
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 03:21:38 -0700 (PDT)
In-Reply-To: <20080813095942.GA9145@martell.zuzino.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Hm, did my original e-mail not make it to the lists?)

>> The least invasive fix is to detect that we're trying to re-enter the
>> driver code. We provide a netdev_busy() function which can be used to
>> determine whether a deadlock can occur if we try to transmit another
>> packet.
>>
>> Note that this may lead to lost messages if the driver is active on
>> another CPU while we try to use the same device for netconsole.
>
> This sucks.

Indeed. What can be done about it?

>> It would probably be best to set a "lost messages" flag in this case and
>> add it to the stream when the device becomes ready again.

With such a flag, we can at least avoid silent loss of messages. But
what is the likelihood of this happening in the first place? I have no
idea.

I still think that this is better than a possible deadlock, which
gives NO CLUE as to what happened (because it jams the other
consoles). Hopefully the interface will not be used for other traffic.

But I agree. This possibly penalizes all the other cases where people
*don't* pull out their netconsole-device cables.

We could simply not print out the "link up/down" message if the device
is running netconsole. But it feels like papering over the design
error. Because there are other functions in there which may cause
additional messages to be printed, not just the very visible printk().

Can we detect if the lock was taken on the same CPU or not?

Maybe it is possible to postpone the packet instead of discarding it?

>> +static bool rtl8139_busy (struct net_device *dev)
>> +{
>> +     struct rtl8139_private *tp = netdev_priv(dev);
>> +     return spin_is_locked(&tp->lock);
>> +}
>
> How do I know if my driver is suspectible to this sort of deadlock?

if the ->hard_start_xmit() takes any locks which can be taken from any
code that calls (also indirectly!) printk(), in this case the
interrupt handler that is invoked when I replace the cable. My guess
is that _all_ drivers need to take some sort of lock in
hard_start_xmit().

It's a bit fragile, I agree. But the completely silent deadlock is nasty too!


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
