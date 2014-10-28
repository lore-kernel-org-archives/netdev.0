From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Tue, 28 Oct 2014 10:38:30 -0700
Message-ID: <1414517910.631.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
	 <1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
	 <20141028.005121.1715627351754245965.davem@davemloft.net>
	 <CA+mtBx9=xTyqTXrZODi9dyN1H0W51uqvHR4YT3DhFXpdc4FMbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37858 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbaJ1Ric (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 13:38:32 -0400
Received: by mail-pd0-f174.google.com with SMTP id p10so1140235pdj.33
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 10:38:32 -0700 (PDT)
In-Reply-To: <CA+mtBx9=xTyqTXrZODi9dyN1H0W51uqvHR4YT3DhFXpdc4FMbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 08:18 -0700, Tom Herbert wrote:

> UDP tunnels are becoming increasingly common. VXLAN, FOU, GUE, geneve,
> l2tp, esp/UDP, GRE/UDP, nvgre, etc. all rely on steering based on the
> outer header without deep inspection. When the source port is set to
> inner hash RFS works as is and steering is effectively done based
> inner TCP connections. If aRFS supports UDP, then this should just
> work also for UDP tunnels (another instance where we don't need
> protocol specific support in devices for tunneling).


If you really wanted to solve this, you would need to change RFS to be
aware of the tunnel and find L4 information, instead of current
implementation stopping at first UDP layer.

But as get_rps_cpu() / __skb_flow_dissect() have no way to find this,
you instead chose to invalidate RFS and maybe rely on RPS, because it
might help your workload.

Just to be clear : I tested the patch and saw a regression in my tests,
sending as little as one million UDP packets per second on the target.

Not only UDP rx processing was slower, but TCP flows were impacted.

With a table of 65536 slots, each slot was written 16 times per second
in average.

Google kernels have RFS_Hit/FRS_Miss snmp counters to catch this kind of
problems. Maybe I should upstream this part.
