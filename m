From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Wed, 14 May 2014 21:09:35 +0200
Message-ID: <20140514210935.5fc80c79@redhat.com>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141748.20309.83121.stgit@dragon>
	<537399C2.8070908@intel.com>
	<20140514.134950.1208688313542719676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com, fw@strlen.de,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	robert@herjulf.se, greearb@candelatech.com,
	john.r.fastabend@intel.com, danieltt@kth.se, zhouzhouyi@gmail.com,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbaENTJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 15:09:57 -0400
In-Reply-To: <20140514.134950.1208688313542719676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 13:49:50 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 14 May 2014 09:28:50 -0700
> 
> > I'd say that it might be better to just add a note to the documentation
> > folder indicating what configuration is optimal for pktgen rather then
> > changing everyone's defaults to support one specific test.
> 
> We could have drivers provide a pktgen config adjustment mechanism,
> so if someone starts pktgen then the device auto-adjusts to a pktgen
> optimal configuration (whatever that may entail).

That might be problematic because changing the TX queue size cause the
ixgbe driver to reset the link.

Notice that pktgen is ignoring BQL.  I'm sort of hoping that BQL will
push back for real use-cases, to avoid the bad effects of increasing
the TX size.

One of the bad effects, I'm hoping BQL will mitigate, is the case of
filling the TX queue with large frames.  Consider 9K jumbo frames, how
long time will it take to empty 1024 jumbo frames on a 10G link:

(9000*8)/(10000*10^6)*1000*1024 = 7.37ms

But with 9K MTU and 512, we already have:
 (9000*8)/(10000*10^6)*1000*512 = 3.69ms

Guess the more normal use-case would be 1500+38 (Ethernet overhead)
 (1538*8)/(10000*10^6)*1000*1024 = 1.25ms

And then again, these calculations should then in theory be multiplied
with the number of TX queues.


I know, increasing these limits should not be taken lightly, but we
just have to be crystal clear that the current 512 limit, is
artificially limiting the capabilities of your hardware.

We can postpone this increase, because I also observe a 2Mpps limit
when actually using (alloc/free) real SKBs.  The alloc/free cost is
currently just hiding this limitation.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
