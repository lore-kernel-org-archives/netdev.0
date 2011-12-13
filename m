From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 13 Dec 2011 04:28:52 +0100
Message-ID: <1323746932.2583.33.camel@edumazet-laptop>
References: <cover.1323744724.git.richardcochran@gmail.com>
	 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59356 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab1LMD25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 22:28:57 -0500
Received: by wgbdr13 with SMTP id dr13so12731499wgb.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 19:28:56 -0800 (PST)
In-Reply-To: <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 d=C3=A9cembre 2011 =C3=A0 04:00 +0100, Richard Cochran a =C3=
=A9crit :
> This commit removes the legacy timecompare code from the igb driver a=
nd
> offers a tunable PHC instead.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---

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
> +		shift =3D OFL_SHIFT_82580;
> +		msb_set =3D (systim >> 32) & SYSTIMH_MSB_82580;
> +		break;
> +	case e1000_82576:
> +		shift =3D OFL_SHIFT_82576;
> +		msb_set =3D (systim >> 32) & SYSTIMH_MSB_82576;
> +		break;
> +	default:
> +		return;
> +	}
> +
> +	spin_lock_irqsave(&adapter->tmreg_lock, flags);
> +
> +	ns =3D igb_overflow_get(adapter, systim, msb_set, shift);
> +
> +	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
> +
> +	memset(hwtstamps, 0, sizeof(*hwtstamps));
> +	hwtstamps->hwtstamp =3D ns_to_ktime(ns);
> +}

Adding a (shared) spinlock on a multiqueue device is source of extra
delay (because of extra cache line trafic), I guess.

It seems current code doesnt need a spinlock, maybe it was a bug ?
