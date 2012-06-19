From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/4 (v6)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Tue, 19 Jun 2012 15:41:55 +0100
Message-ID: <1340116915.2692.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340002187-9248-1-git-send-email-peppe.cavallaro@st.com>
	 <1340002187-9248-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61875 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754453Ab2FSOl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 10:41:59 -0400
In-Reply-To: <1340002187-9248-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 08:49 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the support for the Energy-Efficient Ethernet (EEE)
> to the Physical Abstraction Layer.
> To support the EEE we have to access to the MMD registers 3.20 and
> 7.60/61. So two new functions have been added to read/write the MMD
> registers (clause 45).
> 
> An Ethernet driver (I tested the stmmac) can invoke the phy_init_eee to properly
> check if the EEE is supported by the PHYs and it can also set the clock
> stop enable bit in the 3.0 register.
> The phy_get_eee_err can be used for reporting the number of time where
> the PHY failed to complete its normal wake sequence.
> 
> In the end, this patch also adds the EEE ethtool support implementing:
>  o phy_ethtool_set_eee
>  o phy_ethtool_get_eee
> 
> v1: initial patch
> v2: fixed some errors especially on naming convention
> v3: renamed again the mmd read/write functions thank to Ben's feedback
> v4: moved file to phy.c and added the ethtool support.
> v5: fixed phy_adv_to_eee, phy_eee_to_supported, phy_eee_to_adv return
>     values according to ethtool API (thanks to Ben's feedback).
>     Renamed some macros to avoid too long names.
> v6: fixed kernel-doc comments to be properly parsed.
>     Fixed the phy_init_eee function: we need to check which link mode
>     was autonegotiated and then the corresponding bits in 7.60 and 7.61
>     registers.
[...]
> +		adv = phy_eee_to_adv(eee_adv);
> +		lp = phy_eee_to_adv(eee_lp);
> +		if (!(lp & adv & phydev->advertising))
> +			goto eee_exit;
[...]

phydev->advertising is not the link mode that was autonegotiated, so I
can't believe this is right.  I think you need to use something like:

		adv = phy_eee_to_adv(eee_adv);
		lp = phy_eee_to_adv(eee_lp);
		i = phy_find_setting(phydev->speed, phydev->duplex);
		if ((lp & adv & settings[i].setting))
			goto eee_exit;

and require that genphy_read_status() is called first.  But I haven't
used phylib so I'm not at all sure about this!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
