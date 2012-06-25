From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next (v2) 12/14] ixgbe: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 19:44:07 +0100
Message-ID: <1340649847.2572.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
	 <1340624745-8650-13-git-send-email-yuvalmin@broadcom.com>
	 <4FE88770.7070007@intel.com>
	 <1340646818.2486.27.camel@lb-tlvb-eilong.il.broadcom.com>
	 <4FE8B019.4030807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eilong@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29251 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753906Ab2FYSoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:44:11 -0400
In-Reply-To: <4FE8B019.4030807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 11:38 -0700, Alexander Duyck wrote:
> On 06/25/2012 10:53 AM, Eilon Greenstein wrote:
> > On Mon, 2012-06-25 at 08:44 -0700, Alexander Duyck wrote:
> >> This doesn't limit queues, only interrupt vectors.  As I told you before
> >> you should look at the ixgbe_set_rss_queues function if you actually
> >> want to limit the number of RSS queues.
> > How about this:
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > index af1a531..23a8609 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > @@ -277,6 +277,8 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
> >  	bool ret = false;
> >  	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_RSS];
> >  
> > +	f->indices = min_t(int, netif_get_num_default_rss_queues(), f->indices);
> > +
> >  	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
> >  		f->mask = 0xF;
> >  		adapter->num_rx_queues = f->indices;
> > @@ -302,7 +304,9 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
> >  	bool ret = false;
> >  	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
> >  
> > -	f_fdir->indices = min_t(int, num_online_cpus(), f_fdir->indices);
> > +	f_fdir->indices = min_t(int, netif_get_num_default_rss_queues(),
> > +				f_fdir->indices);
> > +
> >  	f_fdir->mask = 0;
> >  
> >  	/*
> > @@ -339,8 +343,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
> >  	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
> >  		return false;
> >  
> > -	f->indices = min_t(int, num_online_cpus(), f->indices);
> > -
> > +	f->indices = min_t(int, f->indices, netif_get_num_default_rss_queues());
> >  	adapter->num_rx_queues = 1;
> >  	adapter->num_tx_queues = 1;
> >
> This makes much more sense, but still needs a few minor changes.  The
> first change I would recommend is to not alter ixgbe_set_fdir_queues
> since that controls flow director queues, not RSS queues.  The second
> would be to update ixgbe_set_dcb_queues since that does RSS per DCB
> traffic class and will also need to be updated.

There is a difference between the stated aim (reduce memory allocated
for RX buffers) and this implementation (limit number of RSS queues
only).  If we agree on that aim then we should be limiting the total
number of RX queues.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
