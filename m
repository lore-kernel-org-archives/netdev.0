From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH net-next 1/3] ixgbe: support
 netdev_ops->ndo_xmit_flush()
Date: Tue, 26 Aug 2014 08:44:55 +0200
Message-ID: <20140826084455.28dd4058@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-2-git-send-email-dborkman@redhat.com>
	<20140825140721.162a6c91@redhat.com>
	<53FBBE06.3020405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, brouer@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754354AbaHZGpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 02:45:00 -0400
In-Reply-To: <53FBBE06.3020405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 15:51:50 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> On 08/25/2014 05:07 AM, Jesper Dangaard Brouer wrote:
> > On Sun, 24 Aug 2014 15:42:16 +0200
> > Daniel Borkmann <dborkman@redhat.com> wrote:
> > 
> >> This implements the deferred tail pointer flush API for the ixgbe
> >> driver. Similar version also proposed longer time ago by Alexander Duyck.
> > 
> > I've run some benchmarks with this patch only, which actually shows a
> > performance regression.
> > 
> > Using trafgen with QDISC_BYPASS and mmap mode, via cmdline:
> >  trafgen --cpp  --dev eth5 --conf udp_example01.trafgen -V --cpus 1
> > 
> > BASELINE(no-patch): trafgen QDISC_BYPASS and mmap:
> >  - tx:1562539 pps
> > 
> > (This patch only): ixgbe use of .ndo_xmit_flush.
> >  - tx:1532299 pps
> > 
> > Regression: -30240 pps
> >  * In nanosec: (1/1562539*10^9)-(1/1532299*10^9) = -12.63 ns
> > 
> > 
> > As DaveM points out, me might not need the mmiowb().
> > Result when not performing the mmiowb():
> >  - tx:1548352 pps
> > 
> > Still a small regression: -14187 pps
> >  * In nanosec: (1/1562539*10^9)-(1/1548352*10^9) = -5.86 ns
> > 
> > 
> > I was not expecting this "slowdown", with this rather simple use of the
> > new ndo_xmit_flush API.  Can anyone explain why this is happening?
> 
> One possibility is that we are now doing less stuff between the time we
> write tail and when we grab the qdisc lock (locked transactions are
> stalled by MMIO) so that we are spending more time stuck waiting for the
> write to complete and doing nothing.

In this testcase we are bypassing the qdisc code path, but still taking
the HARD_TX_LOCK.  I were only expecting in the area of -2ns due to the
extra function call overhead.

But when we start to include the qdisc code path, then the performance
regression gets even worse.  I would like an explanation for that, see:

 http://thread.gmane.org/gmane.linux.network/327254/focus=327431


> Then of course there are always the funny oddball quirks such as the
> code changes might have changed the alignment of a loop resulting in Tx
> cleanup more expensive than it was before.

Yes, this is when it gets hairy!

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
