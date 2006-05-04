From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Thu, 4 May 2006 11:11:40 +0200
Message-ID: <20060504111140.050c3e2f@griffin.suse.cz>
References: <200605032105.53694.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40147 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751456AbWEDJLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 05:11:42 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605032105.53694.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 May 2006 21:05:53 +0200, Michael Buesch wrote:
> @@ -354,6 +354,33 @@
>  	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
>  }
>  
> +static void bcm43xx_measure_channel_change_time(struct bcm43xx_private *bcm)
> +{
> +	struct bcm43xx_radioinfo *radio;
> +	u64 start, stop;
> +	unsigned long flags;
> +	u8 oldchan, testchan;
> +
> +	/* We (ab)use the bcm43xx TSF timer to measure the time needed
> +	 * to switch channels. This information is handed over to
> +	 * the ieee80211 subsystem.
> +	 * Time is measured in microseconds.
> +	 */
> +
> +	bcm43xx_lock_mmio(bcm, flags);
> +	radio = bcm43xx_current_radio(bcm);
> +	oldchan = radio->channel;
> +	testchan = (oldchan == 6) ? 7 : 6;
> +	bcm43xx_tsf_read(bcm, &start);
> +	bcm43xx_radio_selectchannel(bcm, testchan, 0);
> +	bcm43xx_tsf_read(bcm, &stop);
> +	bcm43xx_radio_selectchannel(bcm, oldchan, 0);
> +	bcm43xx_unlock_mmio(bcm, flags);
> +
> +	assert(stop > start);

I think some safety fallback would be better. Like
if (stop - start < SOME_MIN_VALUE) channel_change_time = SOME_MIN_VALUE
(of course, this won't work because stop and start are unsigned, but you
probably got the idea).

And couldn't TSF counter overflow during the measurement?

> +	bcm->ieee->channel_change_time = stop - start;
> +}
> +
>  static
>  void bcm43xx_macfilter_set(struct bcm43xx_private *bcm,
>  			   u16 offset,
> @@ -3706,6 +3733,7 @@

Please, could you use -p parameter when generating diffs for easier
review?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
