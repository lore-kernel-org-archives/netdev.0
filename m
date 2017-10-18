From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next] liquidio: pass date and time info to NIC
 firmware
Date: Wed, 18 Oct 2017 21:00:47 +0200
Message-ID: <20171018190047.GG15371@lunn.ch>
References: <20171018172445.GA14012@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:50277 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbdJRTAw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 15:00:52 -0400
Content-Disposition: inline
In-Reply-To: <20171018172445.GA14012@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Felix

> +static void lio_sync_octeon_time(struct work_struct *work)
> +{
> +	struct cavium_wk *wk = (struct cavium_wk *)work;
> +	struct lio *lio = (struct lio *)wk->ctxptr;
> +	struct octeon_device *oct = lio->oct_dev;
> +	struct octeon_soft_command *sc;
> +	struct timespec64 ts;
> +	struct lio_time *lt;
> +	int ret;
> +
> +	sc = octeon_alloc_soft_command(oct, sizeof(struct lio_time), 0, 0);
> +	if (!sc) {
> +		dev_err(&oct->pci_dev->dev,
> +			"Failed to sync time to octeon: soft command allocation failed\n");
> +		return;
> +	}
> +
> +	lt = (struct lio_time *)sc->virtdptr;
> +
> +	/* Get time of the day */
> +	getnstimeofday64(&ts);


> @@ -890,11 +894,29 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
>  			load_addr += size;
>  		}
>  	}
> +
> +	/* Get time of the day */
> +	do_gettimeofday(&time);
> +	time_to_tm(time.tv_sec, (-sys_tz.tz_minuteswest) * 60,  &tm_val);

So here, you correct for the timezone the machine is in. However,
lio_sync_octeon_time() uses getnstimeofday64(), which as far as i
know, does not adjust for the time zone.

Maybe put your machine into Pacific/Kiritimati and see what happens?

      Andrew
