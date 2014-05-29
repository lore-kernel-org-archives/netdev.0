From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Thu, 29 May 2014 17:29:23 +0200
Message-ID: <20140529172923.2f4aab8a@redhat.com>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141748.20309.83121.stgit@dragon>
	<537399C2.8070908@intel.com>
	<20140514.134950.1208688313542719676.davem@davemloft.net>
	<20140514210935.5fc80c79@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	dborkman@redhat.com, fw@strlen.de, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com, robert@herjulf.se,
	greearb@candelatech.com, john.r.fastabend@intel.com,
	danieltt@kth.se, zhouzhouyi@gmail.com, Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965140AbaE2PaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:30:20 -0400
In-Reply-To: <20140514210935.5fc80c79@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 21:09:35 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > Date: Wed, 14 May 2014 09:28:50 -0700
> > 
> > > I'd say that it might be better to just add a note to the documentation
> > > folder indicating what configuration is optimal for pktgen rather then
> > > changing everyone's defaults to support one specific test.
>
> I know, increasing these limits should not be taken lightly, but we
> just have to be crystal clear that the current 512 limit, is
> artificially limiting the capabilities of your hardware.

The above statement is mine and it is wrong ;-)

 I'm dropping this patch because of the following understanding:

Alexander Duyck pointed out to me, that interrupt throttling might be
the reason behind the need to increase the TX ring size.  I tested this
and Alex is right.

The needed TX ring size ("ethtool -g") for max performance, is
directly corrolated with how fast/often the TX cleanup is running.

Adjusting the "ethtool -C <ethx> rx-usecs" value affect how often we
cleanup the ring(s).  The default value "1" is some auto interrupt throttling.

Notice with these coalesce tuning, the performance even increase from
6.7Mpps to 7.1Mpps on top of patchset V1.

On top of V1 patchset:
 - 6,747,016 pps - rx-usecs:  1 tx-ring: 1024 (irqs: 9492)
 - 6,684,612 pps - rx-usecs: 10 tx-ring: 1024 (irqs:99322)
 - 7,005,226 pps - rx-usecs: 20 tx-ring: 1024 (irqs:50444)
 - 7,113,048 pps - rx-usecs: 30 tx-ring: 1024 (irqs:34004)
 - 7,133,019 pps - rx-usecs: 40 tx-ring: 1024 (irqs:25845)
 - 7,168,399 pps - rx-usecs: 50 tx-ring: 1024 (irqs:20896)

Look same performance with 512 TX ring.

Lowering TX ring size to (default) 512:
 (On top of V1 patchset)
 - 3,934,674 pps - rx-usecs:  1 tx-ring: 512 (irqs: 9602)
 - 6,684,066 pps - rx-usecs: 10 tx-ring: 512 (irqs:99370)
 - 7,001,235 pps - rx-usecs: 20 tx-ring: 512 (irqs:50567)
 - 7,115,047 pps - rx-usecs: 30 tx-ring: 512 (irqs:34105)
 - 7,130,250 pps - rx-usecs: 40 tx-ring: 512 (irqs:25741)
 - 7,165,296 pps - rx-usecs: 50 tx-ring: 512 (irqs:20898)

Look how even a 256 TX ring is enough, if we cleanup the TX ring fast
enough, and how performance decrease if we cleanup to slowly.

Lowering TX ring size to (default) 256:
 (On top of V1 patchset)
 - 1,883,360 pps - rx-usecs:  1 tx-ring: 256 (irqs: 9800)
 - 6,683,552 pps - rx-usecs: 10 tx-ring: 256 (irqs:99786)
 - 7,005,004 pps - rx-usecs: 20 tx-ring: 256 (irqs:50749)
 - 7,108,776 pps - rx-usecs: 30 tx-ring: 256 (irqs:34536)
 - 5,734,301 pps - rx-usecs: 40 tx-ring: 256 (irqs:25909)
 - 4,590,093 pps - rx-usecs: 50 tx-ring: 256 (irqs:21183)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
