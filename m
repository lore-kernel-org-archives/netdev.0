From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: What's new in wireless-dev?
Date: Wed, 12 Jul 2006 22:30:22 -0400
Message-ID: <20060713023017.GA16084@tuxdriver.com>
References: <20060711204553.GB26186@tuxdriver.com> <20060712114832.4f1dbac6@griffin.suse.cz> <20060712124827.GB4213@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:56335 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932122AbWGMCal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 22:30:41 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060712124827.GB4213@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2006 at 08:48:32AM -0400, John W. Linville wrote:
> On Wed, Jul 12, 2006 at 11:48:32AM +0200, Jiri Benc wrote:
> > On Tue, 11 Jul 2006 16:45:58 -0400, John W. Linville wrote:
> > > John W. Linville:
> > >       d80211: use netif_tx_lock API
> > 
> > > --- a/net/d80211/ieee80211.c
> > > +++ b/net/d80211/ieee80211.c
> > > @@ -1338,7 +1338,7 @@ static void ieee80211_tx_pending(unsigne
> > >  	struct ieee80211_txrx_data tx;
> > >  	int i, ret, reschedule = 0;
> > >  
> > > -	spin_lock_bh(&dev->xmit_lock);
> > > +	netif_tx_lock_bh(dev);
> > >  	dev->xmit_lock_owner = smp_processor_id();
> > 
> > Those dev->xmit_lock_owner assignments are done in netif_tx_[un]lock_bh,
> > so they should go away as well.
> 
> Doh!  I missed that...thanks for the heads-up!

[PATCH] d80211: remove referencess to xmit_lock_owner

Clean-up sloppy attempt at moving to netif_tx_lock API.  When using that
API, direct manipulation of xmit_lock_owner is unnecessary and
inappropriate.

Signed-off-by: John W. Linville <linville@tuxdriver.com>

---

 net/d80211/ieee80211.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

a5b83f260b3cbe9ed161313e620c66b76e0218cf
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 542fec9..7ceef10 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1339,7 +1339,6 @@ static void ieee80211_tx_pending(unsigne
 	int i, ret, reschedule = 0;
 
 	netif_tx_lock_bh(dev);
-	dev->xmit_lock_owner = smp_processor_id();
 	for (i = 0; i < local->hw->queues; i++) {
 		if (__ieee80211_queue_stopped(local, i))
 			continue;
@@ -1364,7 +1363,6 @@ static void ieee80211_tx_pending(unsigne
 			reschedule = 1;
 		}
 	}
-	dev->xmit_lock_owner = -1;
 	netif_tx_unlock_bh(dev);
 	if (reschedule)
 		netif_schedule(dev);
-- 
1.3.1

-- 
John W. Linville
linville@tuxdriver.com
