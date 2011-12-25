From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead
 of the timecompare method
Date: Sun, 25 Dec 2011 16:32:28 +0100
Message-ID: <20111225153227.GB2581@netboy.at.omicron.at>
References: <cover.1323744724.git.richardcochran@gmail.com>
 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48846 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab1LYPci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Dec 2011 10:32:38 -0500
Received: by eekc4 with SMTP id c4so10603259eek.19
        for <netdev@vger.kernel.org>; Sun, 25 Dec 2011 07:32:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 04:00:35AM +0100, Richard Cochran wrote:
> +void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
> +			    struct skb_shared_hwtstamps *hwtstamps,
> +			    u64 systim)
> +{
> +	u64 ns;
> +	unsigned long flags;
> +	unsigned int shift;
> +	int msb_set;
> +
> +	switch (adapter->hw.mac.type) {
> +	case e1000_i350:
> +	case e1000_82580:
> +		shift = OFL_SHIFT_82580;
> +		msb_set = (systim >> 32) & SYSTIMH_MSB_82580;
> +		break;
> +	case e1000_82576:
> +		shift = OFL_SHIFT_82576;
> +		msb_set = (systim >> 32) & SYSTIMH_MSB_82576;

Should have converted systim to nanoseconds here.

> +		break;
> +	default:
> +		return;
> +	}
> +
> +	spin_lock_irqsave(&adapter->tmreg_lock, flags);
> +
> +	ns = igb_overflow_get(adapter, systim, msb_set, shift);
> +
> +	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
> +
> +	memset(hwtstamps, 0, sizeof(*hwtstamps));
> +	hwtstamps->hwtstamp = ns_to_ktime(ns);
> +}
> -- 
> 1.7.2.5
> 
