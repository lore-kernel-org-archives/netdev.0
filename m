From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] codel: fix maxpacket/mtu confusion
Date: Thu, 30 Apr 2015 10:19:29 -0700
Message-ID: <1430414369.3711.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAA93jw4QUyc_hA-TYr4Xqruj4KHUztiE+QP+-9pDtmEvNfH3Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <vanj@google.com>, netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37600 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbD3RTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 13:19:31 -0400
Received: by igblo3 with SMTP id lo3so19317597igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 10:19:30 -0700 (PDT)
In-Reply-To: <CAA93jw4QUyc_hA-TYr4Xqruj4KHUztiE+QP+-9pDtmEvNfH3Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-30 at 10:01 -0700, Dave Taht wrote:
> I long ago dropped the maxpacket check and the statistic/statistic
> collection from various test versions of codel in favor of either a
> constant (1500 byte) check or none at all. There is always some level
> of buffering underneath codel. I have always wanted the big
> GRO/TSO/GRO superpackets to get peeled apart also - the present system
> worked OK with ECN in most cases, but seemed  like it could get ugly
> if we started dropping 64k worth of superpacket.

The peeling part does not belong to codel or fq_codel, but eventually
the parent qdisc, like TBF (peeling is already there), or HTB (no
peeling yet)

codel has binary choice : drop or not drop.

Starting to doing X MSS drops out of GRO packets seems not needed to me
if sender is elastic (properly reacts to drop/ecn_marks). It put extra
logic in the wrong place.

Again, if you have GRO super packets in codel/fq_codel, it means the
sender is buggy enough to send big bursts. Just drop the big GRO packet,
do not try to be gentle with the bad guy.
