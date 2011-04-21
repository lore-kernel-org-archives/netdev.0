From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Thu, 21 Apr 2011 20:19:19 +0100
Message-ID: <1303413559.3165.55.camel@bwh-desktop>
References: <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
	 <1303397531.3685.16.camel@edumazet-laptop>
	 <1303411750.19212.123.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9122 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab1DUTTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 15:19:22 -0400
In-Reply-To: <1303411750.19212.123.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 21:49 +0300, Vladislav Zolotarov wrote:
[...]
> More than that, in addition it is impossible to disable the LRO with 
> the current bnx2x upstream driver (ethtool -K ethX lro off) and this is
> because dev_disable_lro passes to __ethtool_set_flags() flags based on
> the current value of dev->features while __ethtool_set_flags() expects
> only the flags set in dev->hw_features. bnx2x has NETIF_F_HW_VLAN_RX
> that is set in dev->features and not set in dev->hw_features and it's
> passed down to the __ethtool_set_flags(). 
[...]

The problem is here in register_netdevice():

	/* Transfer changeable features to wanted_features and enable
	 * software offloads (GSO and GRO).
	 */
	dev->hw_features |= NETIF_F_SOFT_FEATURES;
	dev->features |= NETIF_F_SOFT_FEATURES;
	dev->wanted_features = dev->features & dev->hw_features;

This doesn't work correctly for features that are always enabled, like
NETIF_F_HW_VLAN_RX in bnx2x, which are set in dev->features but not in
dev->hw_features.

The name 'hw_features' really wasn't a good choice - the obvious meaning
and the meaning assumed by this code is 'hardware-supported features'
and not 'hardware-supported features that can be toggled'.  And since we
add NETIF_F_SOFT_FEATURES, it really only means 'features that can be
toggled'.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

