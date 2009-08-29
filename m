From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Fri, 28 Aug 2009 23:38:58 -0700 (PDT)
Message-ID: <20090828.233858.256193304.davem@davemloft.net>
References: <4A97F2B4.7030900@gmail.com>
	<alpine.DEB.1.10.0908281211150.7317@gentwo.org>
	<4A98132C.8090105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751737AbZH2Gio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:38:44 -0400
In-Reply-To: <4A98132C.8090105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Aug 2009 19:26:04 +0200

> [PATCH] ip: Report qdisc packet drops
> 
> Christoph Lameter pointed out that packet drops at qdisc level where not
> accounted in SNMP counters. Only if application sets IP_RECVERR, drops
> are reported to user and SNMP counters updated.
> 
> IP_RECVERR is used to enable extended reliable error message passing.
> In case of tx drops at qdisc level, no error packet will be generated.
> It seems un-necessary to hide the qdisc drops for non IP_RECVERR enabled
> sockets (as probably most sockets are)
> 
> By removing the check of IP_RECVERR enabled sockets in ip_push_pending_frames()/
> raw_send_hdrinc() / ip6_push_pending_frames() / rawv6_send_hdrinc(),
> we can properly update IPSTATS_MIB_OUTDISCARDS, and in case of UDP, update
> UDP_MIB_SNDBUFERRORS SNMP counters.
> 
> Application send() syscalls, instead of returning an OK status (thus lying),
> will return -ENOBUFS error.
> 
> Note : send() manual page explicitly says for -ENOBUFS error :
> 
>  "The output queue for a network interface was full.
>   This generally indicates that the interface has stopped sending,
>   but may be caused by transient congestion.
>   (Normally, this does not occur in Linux. Packets are just silently
>   dropped when a device queue overflows.) "
> 
> This was not true for IP_RECVERR enabled sockets for < 2.6.32 linuxes,
> and starting from linux 2.6.32, last part wont be true at all.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

The core question in all of this is what IP_RECVERR means.

As far as I remember Alexey Kuznetsov's intentions, it means that the
application is interested in learning about errors caused by the
infrastructure of the network between local and remote stacks.

Reporting a qdisc level drop to the application by default has the
potential to break applications, because BSD and other stacks do not
do this.

I can see why we might be able to get away with making this change
now.  And I also can see the benefits of it, for sure.

Let me think about this some more.
