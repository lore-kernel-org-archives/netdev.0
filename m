From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 2/2] refactor full duplex flow control resolution
Date: Tue, 23 Dec 2008 17:45:35 +0000
Message-ID: <1230054335.3402.29.camel@deadeye.i.decadent.org.uk>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	 <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
	 <1229258301-5073-3-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:2495 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbYLWRpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 12:45:39 -0500
In-Reply-To: <1229258301-5073-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-12-14 at 12:38 +0000, Steve Glendinning wrote:
[...]
> +/**
> + * mii_resolve_flowctrl_fdx
> + * @lcladv: value of MII ADVERTISE register
> + * @rmtadv: value of MII LPA register
> + *
> + * Resolve full duplex flow control as per IEEE 802.3-2005 table 28B-3
> + */
> +static inline u8 mii_resolve_flowctrl_fdx(u16 lcladv, u16 rmtadv)
> +{
> +	u8 cap = 0;
> +
> +	if (lcladv & ADVERTISE_PAUSE_CAP) {
> +		if (lcladv & ADVERTISE_PAUSE_ASYM) {
> +			if (rmtadv & LPA_PAUSE_CAP)
> +				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
> +			else if (rmtadv & LPA_PAUSE_ASYM)
> +				cap = FLOW_CTRL_RX;
> +		} else {
> +			if (rmtadv & LPA_PAUSE_CAP)
> +				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
> +		}
> +	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
> +		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
> +			cap = FLOW_CTRL_TX;
> +	}
> +
> +	return cap;
> +}

There's a rather more elegant way to write this, which is:

	if (lcladv & rmtadv & ADVERTISE_PAUSE_CAP) {
		cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
	} else if (lcladv & rmtadv & ADVERTISE_PAUSE_ASYM) {
		if (lcladv & ADVERTISE_PAUSE_CAP)
			cap = FLOW_CTRL_RX;
		else if (rmtadv & ADVERTISE_PAUSE_CAP)
			cap = FLOW_CTRL_TX;
	}

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
