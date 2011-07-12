From: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Subject: Re: [net-next 5/5] ixgbe: convert to ndo_fix_features
Date: Tue, 12 Jul 2011 23:44:45 +0200
Message-ID: <20110712214445.GA14904@rere.qmqm.pl>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1310212240-24623-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110709121108.GA7720@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34505DF1B3F@orsmsx509.amr.corp.intel.com>
 <20110712100932.GA6433@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34505E7682C@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:33209 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab1GLVor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 17:44:47 -0400
Content-Disposition: inline
In-Reply-To: <C0716E470783B24A8178C9E38CD2F34505E7682C@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good to see the idea converging. :) More hints below.

On Tue, Jul 12, 2011 at 02:28:15PM -0700, Skidmore, Donald C wrote:
[...]
> The logic in this conditional is a little complex. I believe it would
> end up looking something like the following:
>=20
> in fix_features:
>=20
> 	/* Prevent change if not RSC capable or invalid ITR setting */
> 	if (data & NETIF_F_LRO)

That's not a fast path - you can drop (data & NETIF_F_LRO) check.

> 		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
> 			data &=3D ~NETIF_F_LRO;
> 		else if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
> 	    		   (adapter->rx_itr_setting !=3D 1 &&
> 			    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE)) {
> 				data &=3D ~NETIF_F_LRO;
> 		}
> 	}=20

Same for !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED). After this chang=
e,
you might add a call to netdev_update_features() whenever the second pa=
rt
of the condition is changed by user and you get correctness all the tim=
e
'for free'.

> in set_feature:
>=20
> 	/* Make sure RSC matches LRO, reset if change */
> 	if (!!(data & NETIF_F_LRO) !=3D=20
> 	    !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
> 		adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
> 		switch (adapter->hw.mac.type) {
> 		case ixgbe_mac_X540:
> 		case ixgbe_mac_82599EB:
> 			need_reset =3D true;
> 			break;
> 		default:
> 			break;=09
> 		}
> 	}

Correct. Why would you need IXGBE_FLAG2_RSC_ENABLED now, when it just
mirrors NETIF_F_LRO?

[...]
> Thanks again for the clarifications, the netdev-features.txt helped a=
 lot too.=20

Nice to hear (read) that!

Best Regards,
Micha=B3 Miros=B3aw
