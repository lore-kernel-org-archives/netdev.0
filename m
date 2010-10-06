From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may
 cap num_rx_queues at init time
Date: Wed, 6 Oct 2010 11:14:58 -0700
Message-ID: <20101006181458.GA6817@mcarlson.broadcom.com>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
 <1286256926.2457.2.camel@edumazet-laptop> <4CAB4D8F.8080108@intel.com>
 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
 <4CAB6447.6040407@intel.com> <4CAC8D11.2060604@intel.com>
 <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
 <1286378626.9417.24.camel@edumazet-laptop>
 <1286379105.2371.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3058 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759526Ab0JFSPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 14:15:07 -0400
In-Reply-To: <1286379105.2371.15.camel@achroite.uk.solarflarecom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 08:31:45AM -0700, Ben Hutchings wrote:
> On Wed, 2010-10-06 at 17:23 +0200, Eric Dumazet wrote:
> > Le mercredi 06 octobre 2010 ?? 16:07 +0100, Ben Hutchings a ??crit :
> > 
> > > The waste of memory is minimal now that we only allocate kobjects for
> > > real_num_rx_queues.
> > 
> > Thats strange, here with tg3 (and mono queue device) :
> > 
> > 0a:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S
> > Gigabit Ethernet (rev a3)
> > 
> > grep . /sys/class/net/eth2/queues/rx-*/rps_cpus
> > /sys/class/net/eth2/queues/rx-0/rps_cpus:00000000
> > /sys/class/net/eth2/queues/rx-1/rps_cpus:00000000
> > /sys/class/net/eth2/queues/rx-2/rps_cpus:00000000
> > /sys/class/net/eth2/queues/rx-3/rps_cpus:00000000
> > /sys/class/net/eth2/queues/rx-4/rps_cpus:00000000
> 
> It looks like I missed a necessary call to
> netif_set_real_num_rx_queues() in tg3.  I suggest that Matt should check
> and correct this since I got the numbers wrong last time.

Yes.  We were missing a call to this function in the legacy case.


[PATCH net-next] tg3: Set real_num_rx_queues for non-multiq devs

Commit 2ddaad397c47de012dfb956b0c05540da1a0dde5 entitled "tg3: Use
netif_set_real_num_{rx,tx}_queues()" added a new call to
netif_set_real_num_rx_queues in tg3_enable_msix().  This call also needs
to be added to the legacy path to correctly reflect the actual number of
rx queues.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 16e1a95..e5b9ec5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8906,6 +8906,7 @@ defcfg:
 		tp->irq_cnt = 1;
 		tp->napi[0].irq_vec = tp->pdev->irq;
 		netif_set_real_num_tx_queues(tp->dev, 1);
+		netif_set_real_num_rx_queues(tp->dev, 1);
 	}
 }
 
-- 
1.7.2.2


