From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/7] sfc: Add support for IEEE-1588 PTP
Date: Thu, 19 Jul 2012 15:37:33 +0100
Message-ID: <1342708653.2617.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
	 <1342635693.2617.56.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120719142558.GB24484@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Andrew Jackson <ajackson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27602 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751808Ab2GSOho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 10:37:44 -0400
In-Reply-To: <20120719142558.GB24484@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 16:25 +0200, Richard Cochran wrote:
> On Wed, Jul 18, 2012 at 07:21:33PM +0100, Ben Hutchings wrote:
> > Add PTP IEEE-1588 support and make accesible via the PHC subsystem.
> > 
> > This work is based on prior code by Andrew Jackson
> > 
> > Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[...]
> > --- a/drivers/net/ethernet/sfc/nic.h
> > +++ b/drivers/net/ethernet/sfc/nic.h
> > @@ -250,6 +250,37 @@ extern int efx_sriov_get_vf_config(struct net_device *dev, int vf,
> >  extern int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
> >  				     bool spoofchk);
> >  
> > +struct ethtool_ts_info;
> > +#ifdef CONFIG_SFC_PTP
> > +extern void efx_ptp_probe(struct efx_nic *efx);
> > +extern int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd);
> > +extern int efx_ptp_get_ts_info(struct net_device *net_dev,
> > +			       struct ethtool_ts_info *ts_info);
> > +extern bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
> > +extern int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
> > +extern void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
> > +#else
> > +static inline void efx_ptp_probe(struct efx_nic *efx) {}
> > +static inline int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> > +static inline int efx_ptp_get_ts_info(struct net_device *net_dev,
> > +				      struct ethtool_ts_info *ts_info)
> > +{
> > +	return -EOPNOTSUPP;
> 
> If your PTP support is not enabled, then it would be better to offer
> the standard ethtool answer to this query.
> 
> Also, it would be nice to still offer SW Tx timestamping, even when
> PTP is disabled.

Yes, I'm aware we should do that, but I also want to resolve the feature
gap between in-tree and out-of-tree versions first.

[...]
> > +/* Process times received from MC.
> > + *
> > + * Extract times from returned results, and establish the minimum value
> > + * seen.  The minimum value represents the "best" possible time and events
> > + * too much greater than this are rejected - the machine is, perhaps, too
> > + * busy. A number of readings are taken so that, hopefully, at least one good
> > + * synchronisation will be seen in the results.
> > + */
> 
> This code looks like it is trying to find the offset between two
> clocks. Is there some reason why you cannot use <linux/timecompare.h>
> to accomplish this?
>
> Also, these comments about "hopefull" synchronization make me
> nervous. I think it might be easier just to offer RAW timestamps and
> forget about the SYS timestamps.
> 
> I am trying to purge the whole SYS thing (only blackfin is left)
> because there is a much better way to go about this, namely
> synchronizing the system time to the PHC time via an internal PPS
> signal.

Andrew, would that work for us?

[...]
> > +static int efx_phc_settime(struct ptp_clock_info *ptp,
> > +			   const struct timespec *e_ts)
> > +{
> > +	/* We must provide this function, but we cannot actually set the time */
> 
> Huh? You can adjtime, so must be able to settime, too, right?

Unless I missed something, the firmware interface doesn't include an
atomic settime operation.  We may be able to fudge it with gettime and
adjtime, if that's good enough.

> If you have enough range in the RAW timestamp in the MC firmware (like
> 64 bits of nanoseconds), and you allow settime, then you can spare the
> system time synchronization code altogether.
[...]

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
