From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] Merge p80211 to ieee80211 subsystem
Date: Sat, 26 Mar 2005 18:37:06 -0800
Message-ID: <20050327023706.GH8204@jm.kir.nu>
References: <1111740953.17276.84.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        "David S.Miller" <davem@davemloft.net>
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <1111740953.17276.84.camel@debian.sh.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2005 at 04:55:52PM +0800, Zhu Yi wrote:

> This patch merged David Miller's p80211 (with Vladimir's modification)
> into the ieee80211 subsystem in wireless-2.6. This makes the ieee80211
> code hook into the kernel as a true native network stack:
> 
> - It registers a new packet type ETH_P_802_11
> - Build 802.11 headers via ->hard_header and friends for TX
> - Handle RX packets passed by netif_rx or netif_receive_skb

What takes care of variable length IEEE 802.11 headers?
ieee80211_header() did not seem to have any code for WDS (4-address
frames) and hard_header_len was set to 24. Even for IEEE 802.11 data
frames, the header length can be 24, 26, 30, or 32..

> - Native WPA/802.11i?

What do you mean with this?

> Currently the driver doesn't support WPA yet, because wpa_supplicant
> only handles 802.3 packets but not 802.11 packets. For this reason, I
> only want this patch to be RFC, but not intend for inclusion now. After
> the ipw driver is in wireless-2.6, I'll submit an updated stack
> (hopfully with WPA support) together with patches switching the ipw
> drivers to use the native stack.

Do you mean that wpa_supplicant (or well, any program using packet
sockets with link layer headers) would need to be able to both parse and
generate IEEE 802.11 headers? Including setting QoS control field in
case WMM/IEEE 802.11e is used? What about encrypted packets? Will the
IEEE 802.11 code in kernel take care of encrypting and decrypting EAPOL
packets? Would wpa_supplicant need to indicate that it wants some of the
EAPOL frames encrypted or is this taken care of automatically?

dev->type is set to ARPHRD_ETHER. Shouldn't it be something else? How
does user space know what kind of frames to expect?

>  #ifdef CONFIG_IEEE80211_DEBUG
>  	if (crypt && !encrypt && ether_type == ETH_P_PAE) {
> +		/* FIXME: eap is wrong */
>  		struct eapol *eap = (struct eapol *)(skb->data +
> -			sizeof(struct ethhdr) - SNAP_SIZE - sizeof(u16));
> +			sizeof(struct ethhdr) - SNAP_SIZE);
>  		IEEE80211_DEBUG_EAP("TX: IEEE 802.11 EAPOL frame: %s\n",
>  			eap_get_type(eap->type));
>  	}
>  #endif

Why is there any EAP processing in kernel? This seems to be debug code,
but I don't really see why it would be needed in the first place. Same
for functions like eap_get_type() or struct eapol definition for that
matter.

-- 
Jouni Malinen                                            PGP id EFC895FA
