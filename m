From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Thu, 12 Jul 2007 15:56:14 +0900 (JST)
Message-ID: <20070712.155614.91275946.noboru.obata.ar@hitachi.com>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
    <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: ian.mcdonald@jandi.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:37483 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbXGLG41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 02:56:27 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id E936637C8F
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:56:25 +0900 (JST)
In-Reply-To: <5640c7e00706251518y75a34578xec45ce100b6df832@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: [MaybeSpam] Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Tue, 26 Jun 2007 10:18:46 +1200

> On 6/26/07, OBATA Noboru <noboru.obata.ar@hitachi.com> wrote:
> > From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> >
> > Make TCP_RTO_MAX a variable, and allow a user to change it via a
> > new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> > then guarantee TCP retransmission to be more controllable, say,
> > at least once per 10 seconds, by setting it to 10.  This is
> > quite helpful on failover-capable network devices, such as an
> > active-backup bonding device.  On such devices, it is desirable
> > that TCP retransmits a packet shortly after the failover, which
> > is what I would like to do with this patch.  Please see
> > Background and Problem below for rationale in detail.
> >
> RFC2988 says this:
>    (2.4) Whenever RTO is computed, if it is less than 1 second then the
>          RTO SHOULD be rounded up to 1 second.
> 
>          Traditionally, TCP implementations use coarse grain clocks to
>          measure the RTT and trigger the RTO, which imposes a large
>          minimum value on the RTO.  Research suggests that a large
>          minimum RTO is needed to keep TCP conservative and avoid
>          spurious retransmissions [AP99].  Therefore, this
>          specification requires a large minimum RTO as a conservative
>          approach, while at the same time acknowledging that at some
>          future point, research may show that a smaller minimum RTO is
>          acceptable or superior.
> 
>    (2.5) A maximum value MAY be placed on RTO provided it is at least 60
>          seconds.
> 
> Your code doesn't seem to meet requirements of section 2.5 as your
> minimum is 1 second.
> 
> I think if you're trying to solve the bonding issue then you should
> solve that issue, not hack the TCP implementation as that opens it up
> to abuse in other ways.

I think this is rather a new problem, or requirement, in the
combined case "TCP on a failover-capable network device," and
not easily solved only by bonding.

A notify mechanism from bonding to TCP is suggested, but I think
it is really hard to do it in the virtualized environment like
Xen.  Hypervisor (Dom-0) takes care of physical devices,
including bonding, and guests (Dom-U) handle TCP.  Notifying
from bonding in Dom-0 to TCP in Dom-U is really a challenge.

My problem (TCP retransmission may not be done in the expected
time frame, e.x., 10 seconds after a bonding failover) still
occurs in such an environment, and my code (capping TCP_RTO_MAX)
still works on VM environment.

So solving this in TCP layer makes sense to me.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
