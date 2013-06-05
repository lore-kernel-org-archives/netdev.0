From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: add 64bit rate estimators
Date: Wed, 05 Jun 2013 12:37:37 -0700
Message-ID: <1370461057.24311.296.camel@edumazet-glaptop>
References: <1370408447.24311.241.camel@edumazet-glaptop>
	 <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:44408 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab3FEThj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 15:37:39 -0400
Received: by mail-oa0-f51.google.com with SMTP id f4so1485197oah.38
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 12:37:39 -0700 (PDT)
In-Reply-To: <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 19:55 +0100, Ben Hutchings wrote:
> On Tue, 2013-06-04 at 22:00 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > struct gnet_stats_rate_est contains u32 fields, so the byte per second
> > field can wrap at 34360Mbit.
> > 
> > Add a new gnet_stats_rate_est64 structure to get 64bit bps field, and
> > switch the kernel to use this structure natively.
> [...] 
> >  /**
> > + * struct gnet_stats_rate_est64 - rate estimator
> > + * @bps: current byte rate
> > + * @pps: current packet rate
> > + */
> > +struct gnet_stats_rate_est64 {
> > +	__u64	bps;
> > +	__u32	pps;
> > +} __attribute__ ((packed));
> [...]
> 
> Using attribute packed (which should be written as __packed) forces the
> alignment of each member and the structure as a whole to be 1.  For an
> architecture where unaligned access is expensive, gcc will make all
> reads and writes use byte operations.
> 
> I think you have to add a dummy __u32 member instead.

Its exported to userland so __packed is not available. Or has this been
changed lately ?

This structure is only used in very slow path, in the rate estimator
thing, so the unaligned accesses are not a problem at all.

I made this choice to not increase sizeof(struct Qdisc) and the
alignments as well.

If you think there is an issue with userland, we could use a
gnet_stats_rate_est64_packed in kernel, and a gnet_stats_rate_est64 in
userland.
