From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Mon, 19 Aug 2013 07:57:15 -0700
Message-ID: <CAPshTCjpe99WobuiiR7QY0bRj86C2Tc9U8OkXpiKKFY1RrsG6g@mail.gmail.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	<1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	<1363651672.21184.17.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	<CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	<CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
	<1376766116.21329.9.camel@edumazet-glaptop>
	<CAPshTCh3CqrgasEvFG_Yy8NRHMp_rrQDqn7eRMD9NycmpxaWkQ@mail.gmail.com>
	<1376840262.21329.40.camel@edumazet-glaptop>
	<CAPshTCjB9S-Xc4MTs5XXLm6N=0-v_9gxC2SDwCzieTc4Py43fg@mail.gmail.com>
	<1376869493.4226.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Uday Naik <uday@google.com>,
	Michael Dalton <mwdalton@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:64896 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab3HSO5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 10:57:16 -0400
Received: by mail-vc0-f176.google.com with SMTP id ha11so3021257vcb.21
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 07:57:15 -0700 (PDT)
In-Reply-To: <1376869493.4226.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 18, 2013 at 4:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-08-18 at 14:11 -0700, Jerry Chu wrote:
>
>> It can if the csum validation is deferred. But this requires the stack code to
>> aggregate csum from individual pkt header, which can get ugly as one needs
>> to remove the header part from the individual csum first.
>
> You can _not_ aggregate packets _before_ validating their checksum, or
> else you could end up with a correct final checksum while two or more
> segments had buggy checksums. Checksum are already quite weak, please
> do not make them even weaker ;)

Yes I know how weak the 16bit 1's complement inet csum (see my previous email).
I've had the pleasure to debug a number of bugs in the past where 16bit words
were flipped by the buggy h/w hence went undetected by the weak TCP csum.

But I also think it's a tradeoff call. For WAN it's probably a bad
idea but for data
center traffic, pkt corruption is usually rare. If the performance
gain is large enough,
perhaps it justifies this hack (?)

>
> GRO should not throw out any segments, it is not its role.

I did not suggest GRO to throw away any pkt. GRO would just fix the csum
field in the header of the aggregated pkt and passes it on.

>
> If a router receives a bunch of packets, it should forward them
> regardless of the (TCP) checksum being good or not.

It won't affect the forwarding path (i think).

>
> The final receiver has full responsibility for ultimately validate the
> checksums and update various SNMP counters.

When the GRO pkt with the csum field fixed (aggregated) get to
the receiving TCP endpoint, it will be csum validated by the TCP stack
because skb->ip_summed == CHECKSUM_NONE, and the pkt will be
tossed if the csum check fails like non-GRO pkts.

To be clear, this hack is not something I'd be proud of and I doubt the
performance gain will be enough to justify it. This idea grew more out of
desperation for not having csum offload for encap'ed pkts, which I think
is a P0 bug!

Jerry

>
>
>
