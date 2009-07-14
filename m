From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Tue, 14 Jul 2009 12:33:13 -0700 (PDT)
Message-ID: <20090714.123313.186658126.davem@davemloft.net>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	<20090713.104950.121936768.davem@davemloft.net>
	<65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753978AbZGNTdJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 15:33:09 -0400
In-Reply-To: <65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Mon, 13 Jul 2009 15:04:51 -0700

> On Mon, Jul 13, 2009 at 10:49 AM, David Miller <davem@davemloft.net> =
wrote:
>>
>> Why not take this to it's logical end point, which is to monitor
>> transmits using a tiny flow lookup table, and map receives of the sa=
me
>> flow to the same cpu?
>=20
> Is it better do use transmits, or monitor where recvmsg was called?

=46irst of all, using recvmsg would be on the more stateful side, and
we try to avoid that.  All of the logic should work if we had to
put it purely inside of dev_hard_xmit() and netif_receive_skb(),
way below the stack itself ever gets involved.

Second, Intel has committed the "monitor the TXs to device where to
steer RX" logic into silicon with their Flow Director stuff.  What
does that tell you about it's effectiveness? :-)

It seems the best heuristic to me, especially since it satisfies
many of the design constraints.

> Right.=A0 In fact, just using the hash as the key is what you want wh=
en
> device provides the hash (i.e. Toeplitz).=A0 The caveat is that we
> should to prevent OOO packets when threads migrate, I think I have a
> reasonable solution for that following your earlier suggestion.

But as you found, compared to jhash, Toeplitz is expensive to compute
and you would need to do this if implemented by monitoring transmits.

And furthermore, from the device perspective:

1) some (such as NIU) provide different hash values, not Toeplitz

2) it is expensive to extract this value (must enable different,
   larger, RX descriptor modes, thus more DMA traffic, etc.)

I really don't think Toeplitz is a net win, to be honest.

> I hope to have a new patch soon for steering packets to application
> CPU and using device hash, thanks for bugging me on it!

I had no choice, as I'm giving a presentation on this stuff tomorrow
night here in NYC :-)
