From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Fri, 21 Nov 2014 04:46:09 -0800
Message-ID: <1416573969.2280.39.camel@jtkirshe-mobl>
References: <cover.1416562191.git.rcochran@linutronix.de>
	 <00356ddec4e20d99010884c8f18cd00df4419eaf.1416562192.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wtgW2NLc8YhZj34yTibS"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bruce.w.allan@intel.com, Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>, Jian Yu <jian.yu@ni.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14495 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbaKUMqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 07:46:15 -0500
In-Reply-To: <00356ddec4e20d99010884c8f18cd00df4419eaf.1416562192.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wtgW2NLc8YhZj34yTibS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 10:41 +0100, Richard Cochran wrote:
> The i210 device offers a number of special PTP Hardware Clock features on
> the Software Defined Pins (SDPs). This patch adds support for two of the
> possible functions, namely time stamping external events, and periodic
> output signals.
>=20
> The assignment of PHC functions to the four SDP can be freely chosen by
> the user.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      |    9 ++
>  drivers/net/ethernet/intel/igb/igb_main.c |   51 ++++++-
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  220 +++++++++++++++++++++++=
+++++-
>  3 files changed, 274 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/=
intel/igb/igb.h
> index 82d891e..f6aca7c 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -343,6 +343,9 @@ struct hwmon_buff {
>  	};
>  #endif
> =20
> +#define IGB_N_EXTTS	2
> +#define IGB_N_PEROUT	2
> +#define IGB_N_SDP	4
>  #define IGB_RETA_SIZE	128
> =20
>  /* board specific private data structure */
> @@ -439,6 +442,12 @@ struct igb_adapter {
>  	u32 tx_hwtstamp_timeouts;
>  	u32 rx_hwtstamp_cleared;
> =20
> +	struct ptp_pin_desc sdp_config[IGB_N_SDP];
> +	struct {
> +		struct timespec start;
> +		struct timespec period;
> +	} perout[IGB_N_PEROUT];
> +
>  	char fw_version[32];
>  #ifdef CONFIG_IGB_HWMON
>  	struct hwmon_buff *igb_hwmon_buff;
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethe=
rnet/intel/igb/igb_main.c
> index 5fe6e17..b003a68 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5387,7 +5387,8 @@ static void igb_tsync_interrupt(struct igb_adapter =
*adapter)
>  {
>  	struct e1000_hw *hw =3D &adapter->hw;
>  	struct ptp_clock_event event;
> -	u32 ack =3D 0, tsicr =3D rd32(E1000_TSICR);
> +	struct timespec ts;
> +	u32 ack =3D 0, tsauxc, sec, nsec, tsicr =3D rd32(E1000_TSICR);
> =20
>  	if (tsicr & TSINTR_SYS_WRAP) {
>  		event.type =3D PTP_CLOCK_PPS;
> @@ -5404,6 +5405,54 @@ static void igb_tsync_interrupt(struct igb_adapter=
 *adapter)
>  		ack |=3D E1000_TSICR_TXTS;
>  	}
> =20
> +	if (tsicr & TSINTR_TT0) {
> +		spin_lock(&adapter->tmreg_lock);
> +		ts =3D timespec_add(adapter->perout[0].start,
> +				  adapter->perout[0].period);
> +		wr32(E1000_TRGTTIML0, ts.tv_nsec);
> +		wr32(E1000_TRGTTIMH0, ts.tv_sec);
> +		tsauxc =3D rd32(E1000_TSAUXC);
> +		tsauxc |=3D TSAUXC_EN_TT0;
> +		wr32(E1000_TSAUXC, tsauxc);
> +		adapter->perout[0].start =3D ts;
> +		spin_unlock(&adapter->tmreg_lock);
> +		ack |=3D TSINTR_TT0;
> +	}
> +
> +	if (tsicr & TSINTR_TT1) {
> +		spin_lock(&adapter->tmreg_lock);
> +		ts =3D timespec_add(adapter->perout[1].start,
> +				  adapter->perout[1].period);
> +		wr32(E1000_TRGTTIML1, ts.tv_nsec);
> +		wr32(E1000_TRGTTIMH1, ts.tv_sec);
> +		tsauxc =3D rd32(E1000_TSAUXC);
> +		tsauxc |=3D TSAUXC_EN_TT1;
> +		wr32(E1000_TSAUXC, tsauxc);
> +		adapter->perout[1].start =3D ts;
> +		spin_unlock(&adapter->tmreg_lock);
> +		ack |=3D TSINTR_TT1;
> +	}
> +
> +	if (tsicr & TSINTR_AUTT0) {
> +		nsec =3D rd32(E1000_AUXSTMPL0);
> +		sec  =3D rd32(E1000_AUXSTMPH0);
> +		event.type =3D PTP_CLOCK_EXTTS;
> +		event.index =3D 0;
> +		event.timestamp =3D sec * 1000000000ULL + nsec;
> +		ptp_clock_event(adapter->ptp_clock, &event);
> +		ack |=3D TSINTR_AUTT0;
> +	}
> +
> +	if (tsicr & TSINTR_AUTT1) {
> +		nsec =3D rd32(E1000_AUXSTMPL1);
> +		sec  =3D rd32(E1000_AUXSTMPH1);
> +		event.type =3D PTP_CLOCK_EXTTS;
> +		event.index =3D 1;
> +		event.timestamp =3D sec * 1000000000ULL + nsec;
> +		ptp_clock_event(adapter->ptp_clock, &event);
> +		ack |=3D TSINTR_AUTT1;
> +	}
> +
>  	/* acknowledge the interrupts */
>  	wr32(E1000_TSICR, ack);
>  }
> diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ether=
net/intel/igb/igb_ptp.c
> index 526f4a6..2609044 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ptp.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
> @@ -360,16 +360,203 @@ static int igb_ptp_settime_i210(struct ptp_clock_i=
nfo *ptp,
>  	return 0;
>  }
> =20
> +static void igb_pin_direction(int pin, int input, u32 *ctrl, u32 *ctrl_e=
xt)
> +{
> +	u32 *ptr =3D pin < 2 ? ctrl : ctrl_ext;
> +	u32 mask[IGB_N_SDP] =3D {
> +		E1000_CTRL_SDP0_DIR,
> +		E1000_CTRL_SDP1_DIR,
> +		E1000_CTRL_EXT_SDP2_DIR,
> +		E1000_CTRL_EXT_SDP3_DIR,
> +	};
> +
> +	if (input)
> +		*ptr &=3D ~mask[pin];
> +	else
> +		*ptr |=3D mask[pin];
> +}
> +
> +static void igb_pin_extts(struct igb_adapter *igb, int chan, int pin)
> +{
> +	struct e1000_hw *hw =3D &igb->hw;
> +	u32 aux0_sel_sdp[IGB_N_SDP] =3D {
> +		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
> +	};
> +	u32 aux1_sel_sdp[IGB_N_SDP] =3D {
> +		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
> +	};
> +	u32 ts_sdp_en[IGB_N_SDP] =3D {
> +		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
> +	};
> +	u32 ctrl, ctrl_ext, tssdp =3D 0;
> +
> +	ctrl =3D rd32(E1000_CTRL);
> +	ctrl_ext =3D rd32(E1000_CTRL_EXT);
> +	tssdp =3D rd32(E1000_TSSDP);
> +
> +	igb_pin_direction(pin, 1, &ctrl, &ctrl_ext);
> +
> +	/* Make sure this pin is not enabled as an ouput. */

Minor nitpick, output is mis-spelled (I can fix that up for you)

> +	tssdp &=3D ~ts_sdp_en[pin];
> +
> +	if (chan =3D=3D 1) {
> +		tssdp &=3D ~AUX1_SEL_SDP3;
> +		tssdp |=3D aux1_sel_sdp[pin] | AUX1_TS_SDP_EN;
> +	} else {
> +		tssdp &=3D ~AUX0_SEL_SDP3;
> +		tssdp |=3D aux0_sel_sdp[pin] | AUX0_TS_SDP_EN;
> +	}
> +
> +	wr32(E1000_TSSDP, tssdp);
> +	wr32(E1000_CTRL, ctrl);
> +	wr32(E1000_CTRL_EXT, ctrl_ext);
> +}
> +
> +static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
> +{
> +	struct e1000_hw *hw =3D &igb->hw;
> +	u32 aux0_sel_sdp[IGB_N_SDP] =3D {
> +		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
> +	};
> +	u32 aux1_sel_sdp[IGB_N_SDP] =3D {
> +		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
> +	};
> +	u32 ts_sdp_en[IGB_N_SDP] =3D {
> +		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
> +	};
> +	u32 ts_sdp_sel_tt0[IGB_N_SDP] =3D {
> +		TS_SDP0_SEL_TT0, TS_SDP1_SEL_TT0,
> +		TS_SDP2_SEL_TT0, TS_SDP3_SEL_TT0,
> +	};
> +	u32 ts_sdp_sel_tt1[IGB_N_SDP] =3D {
> +		TS_SDP0_SEL_TT1, TS_SDP1_SEL_TT1,
> +		TS_SDP2_SEL_TT1, TS_SDP3_SEL_TT1,
> +	};
> +	u32 ts_sdp_sel_clr[IGB_N_SDP] =3D {
> +		TS_SDP0_SEL_FC1, TS_SDP1_SEL_FC1,
> +		TS_SDP2_SEL_FC1, TS_SDP3_SEL_FC1,
> +	};
> +	u32 ctrl, ctrl_ext, tssdp =3D 0;
> +
> +	ctrl =3D rd32(E1000_CTRL);
> +	ctrl_ext =3D rd32(E1000_CTRL_EXT);
> +	tssdp =3D rd32(E1000_TSSDP);
> +
> +	igb_pin_direction(pin, 0, &ctrl, &ctrl_ext);
> +
> +	/* Make sure this pin is not enabled as an input. */
> +	if ((tssdp & AUX0_SEL_SDP3) =3D=3D aux0_sel_sdp[pin])
> +		tssdp &=3D ~AUX0_TS_SDP_EN;
> +
> +	if ((tssdp & AUX1_SEL_SDP3) =3D=3D aux1_sel_sdp[pin])
> +		tssdp &=3D ~AUX1_TS_SDP_EN;
> +
> +	tssdp &=3D ~ts_sdp_sel_clr[pin];
> +	if (chan =3D=3D 1)
> +		tssdp |=3D ts_sdp_sel_tt1[pin];
> +	else
> +		tssdp |=3D ts_sdp_sel_tt0[pin];
> +
> +	tssdp |=3D ts_sdp_en[pin];
> +
> +	wr32(E1000_TSSDP, tssdp);
> +	wr32(E1000_CTRL, ctrl);
> +	wr32(E1000_CTRL_EXT, ctrl_ext);
> +}
> +
>  static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
>  				       struct ptp_clock_request *rq, int on)
>  {
>  	struct igb_adapter *igb =3D
>  		container_of(ptp, struct igb_adapter, ptp_caps);
>  	struct e1000_hw *hw =3D &igb->hw;
> +	u32 tsauxc, tsim, tsauxc_mask, tsim_mask, trgttiml, trgttimh;
>  	unsigned long flags;
> -	u32 tsim;
> +	struct timespec ts;
> +	int pin;
> +	s64 ns;
> =20
>  	switch (rq->type) {
> +	case PTP_CLK_REQ_EXTTS:
> +		if (on) {
> +			pin =3D ptp_find_pin(igb->ptp_clock, PTP_PF_EXTTS,
> +					   rq->extts.index);
> +			if (pin < 0)
> +				return -EBUSY;
> +		}
> +		if (rq->extts.index =3D=3D 1) {
> +			tsauxc_mask =3D TSAUXC_EN_TS1;
> +			tsim_mask =3D TSINTR_AUTT1;
> +		} else {
> +			tsauxc_mask =3D TSAUXC_EN_TS0;
> +			tsim_mask =3D TSINTR_AUTT0;
> +		}
> +		spin_lock_irqsave(&igb->tmreg_lock, flags);
> +		tsauxc =3D rd32(E1000_TSAUXC);
> +		tsim =3D rd32(E1000_TSIM);
> +		if (on) {
> +			igb_pin_extts(igb, rq->extts.index, pin);
> +			tsauxc |=3D tsauxc_mask;
> +			tsim |=3D tsim_mask;
> +		} else {
> +			tsauxc &=3D ~tsauxc_mask;
> +			tsim &=3D ~tsim_mask;
> +		}
> +		wr32(E1000_TSAUXC, tsauxc);
> +		wr32(E1000_TSIM, tsim);
> +		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
> +		return 0;
> +
> +	case PTP_CLK_REQ_PEROUT:
> +		if (on) {
> +			pin =3D ptp_find_pin(igb->ptp_clock, PTP_PF_PEROUT,
> +					   rq->perout.index);
> +			if (pin < 0)
> +				return -EBUSY;
> +		}
> +		ts.tv_sec =3D rq->perout.period.sec;
> +		ts.tv_nsec =3D rq->perout.period.nsec;
> +		ns =3D timespec_to_ns(&ts);
> +		ns =3D ns >> 1;
> +		if (on && ns < 500000LL) {
> +			/* 2k interrupts per second is an awful lot. */
> +			return -EINVAL;
> +		}
> +		ts =3D ns_to_timespec(ns);
> +		if (rq->perout.index =3D=3D 1) {
> +			tsauxc_mask =3D TSAUXC_EN_TT1;
> +			tsim_mask =3D TSINTR_TT1;
> +			trgttiml =3D E1000_TRGTTIML1;
> +			trgttimh =3D E1000_TRGTTIMH1;
> +		} else {
> +			tsauxc_mask =3D TSAUXC_EN_TT0;
> +			tsim_mask =3D TSINTR_TT0;
> +			trgttiml =3D E1000_TRGTTIML0;
> +			trgttimh =3D E1000_TRGTTIMH0;
> +		}
> +		spin_lock_irqsave(&igb->tmreg_lock, flags);
> +		tsauxc =3D rd32(E1000_TSAUXC);
> +		tsim =3D rd32(E1000_TSIM);
> +		if (on) {
> +			int i =3D rq->perout.index;

Probably should have a blank line after the local variable declaration.
Again, I can fix this up for ya.

> +			igb_pin_perout(igb, i, pin);
> +			igb->perout[i].start.tv_sec =3D rq->perout.start.sec;
> +			igb->perout[i].start.tv_nsec =3D rq->perout.start.nsec;
> +			igb->perout[i].period.tv_sec =3D ts.tv_sec;
> +			igb->perout[i].period.tv_nsec =3D ts.tv_nsec;
> +			wr32(trgttiml, rq->perout.start.sec);
> +			wr32(trgttimh, rq->perout.start.nsec);
> +			tsauxc |=3D tsauxc_mask;
> +			tsim |=3D tsim_mask;
> +		} else {
> +			tsauxc &=3D ~tsauxc_mask;
> +			tsim &=3D ~tsim_mask;
> +		}
> +		wr32(E1000_TSAUXC, tsauxc);
> +		wr32(E1000_TSIM, tsim);
> +		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
> +		return 0;
> +
>  	case PTP_CLK_REQ_PPS:
>  		spin_lock_irqsave(&igb->tmreg_lock, flags);
>  		tsim =3D rd32(E1000_TSIM);
> @@ -380,9 +567,6 @@ static int igb_ptp_feature_enable_i210(struct ptp_clo=
ck_info *ptp,
>  		wr32(E1000_TSIM, tsim);
>  		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
>  		return 0;
> -
> -	default:
> -		break;
>  	}
> =20
>  	return -EOPNOTSUPP;
> @@ -394,6 +578,20 @@ static int igb_ptp_feature_enable(struct ptp_clock_i=
nfo *ptp,
>  	return -EOPNOTSUPP;
>  }
> =20
> +static int igb_ptp_verify_pin(struct ptp_clock_info *ptp, unsigned int p=
in,
> +			      enum ptp_pin_function func, unsigned int chan)
> +{
> +	switch (func) {
> +	case PTP_PF_NONE:
> +	case PTP_PF_EXTTS:
> +	case PTP_PF_PEROUT:
> +		break;
> +	case PTP_PF_PHYSYNC:
> +		return -1;
> +	}
> +	return 0;
> +}
> +
>  /**
>   * igb_ptp_tx_work
>   * @work: pointer to work struct
> @@ -784,6 +982,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
>  {
>  	struct e1000_hw *hw =3D &adapter->hw;
>  	struct net_device *netdev =3D adapter->netdev;
> +	int i;
> =20
>  	switch (hw->mac.type) {
>  	case e1000_82576:
> @@ -826,16 +1025,26 @@ void igb_ptp_init(struct igb_adapter *adapter)
>  		break;
>  	case e1000_i210:
>  	case e1000_i211:
> +		for (i =3D 0; i < IGB_N_SDP; i++) {
> +			struct ptp_pin_desc *ppd =3D &adapter->sdp_config[i];

Probably should have a blank line here as well, which I can fix up.

> +			snprintf(ppd->name, sizeof(ppd->name), "SDP%d", i);
> +			ppd->index =3D i;
> +			ppd->func =3D PTP_PF_NONE;
> +		}
>  		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
>  		adapter->ptp_caps.owner =3D THIS_MODULE;
>  		adapter->ptp_caps.max_adj =3D 62499999;
> -		adapter->ptp_caps.n_ext_ts =3D 0;
> +		adapter->ptp_caps.n_ext_ts =3D IGB_N_EXTTS;
> +		adapter->ptp_caps.n_per_out =3D IGB_N_PEROUT;
> +		adapter->ptp_caps.n_pins =3D IGB_N_SDP;
>  		adapter->ptp_caps.pps =3D 1;
> +		adapter->ptp_caps.pin_config =3D adapter->sdp_config;
>  		adapter->ptp_caps.adjfreq =3D igb_ptp_adjfreq_82580;
>  		adapter->ptp_caps.adjtime =3D igb_ptp_adjtime_i210;
>  		adapter->ptp_caps.gettime =3D igb_ptp_gettime_i210;
>  		adapter->ptp_caps.settime =3D igb_ptp_settime_i210;
>  		adapter->ptp_caps.enable =3D igb_ptp_feature_enable_i210;
> +		adapter->ptp_caps.verify =3D igb_ptp_verify_pin;
>  		/* Enable the timer functions by clearing bit 31. */
>  		wr32(E1000_TSAUXC, 0x0);
>  		break;
> @@ -954,6 +1163,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
>  	case e1000_i210:
>  	case e1000_i211:
>  		wr32(E1000_TSAUXC, 0x0);
> +		wr32(E1000_TSSDP, 0x0);
>  		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
>  		wr32(E1000_IMS, E1000_IMS_TS);
>  		break;



--=-wtgW2NLc8YhZj34yTibS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbzQRAAoJEOVv75VaS+3O/awP/2ShdTjkt+GkrZiS3zpom8kK
V77yyKtBYlzOHlUgoEOctqUmoTBfrcxK4FnI+/CaJkWUQmvjWmtimjLF0bwDl0LA
oM+w74R0lYFkZJC3CbxbIahffuZuKMmmbSQ08KOKtcb9OS8NU3USTKif9k6iRZLA
p+0YsGu5KY3rzLLebwFabm04bFChoALvRRu35KOHgnQKvsgm/7RI5p4zMZJaNY6n
OrZestZ8SAoHy8q3MDrjdDS0ntF1RL3ge3HpMgQrjidIwgf4NkNIJJ+ka2uUGows
+PpWKlYskPe2mNnqKwA7zP0SrmtpOt4YPL6BlWuHWYjwisQUGNr6xj4zxF72saA2
/9/yY1L5GCibmiKqEjE7pCwuP07Q/MpLVI6mJO8MlMRNjhLGQtjA+8nPHKGZSUe2
qIfzaboRbkzflzyL7N8XFUBltJpY9vuUNykc3ggrhc2qN/ylm1w1RyBICOfdhUW+
qGh9A/W4h+UJtRYUZHodIHbkjVB9o9LbIhF+4jQDUY/v8ZfP6NN0E4Dh3qeeX5xV
MmnYIQqxwBL50/mWl35zMNeksjNHLiJI4uGztuRmPSr+FX3ySkjRWRWSvNb7jg7g
nZ2VNj1Y2ZxAqFxJh9Znlt8leS37enZIcyWCjVqIiI21hGDR3yMOrgCowoZv+CYN
bBErF1XbbAGbHf4UwFla
=fdZq
-----END PGP SIGNATURE-----

--=-wtgW2NLc8YhZj34yTibS--
