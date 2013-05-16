From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] r8169: fix offloaded tx checksum for small packets.
Date: Fri, 17 May 2013 00:00:49 +0100
Message-ID: <1368745249.2655.60.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Hayes Wang" <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Holger =?ISO-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9453 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab3EPXAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 19:00:53 -0400
In-Reply-To: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 00:38 +0200, Francois Romieu wrote:
> 8168evl offloaded checksums are wrong since
> e5195c1f31f399289347e043d6abf3ffa80f0005 pads small packets to
> 60 bytes (without ethernet checksum). Observed UDP checksums are
> typically wrong by the count of added bytes.
> 
> It isn't worth compensating. Let's checksum by hand, then pad.
[...]
> @@ -5869,13 +5877,24 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
>  	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
>  		const struct iphdr *ip = ip_hdr(skb);
>  
> +		if (unlikely(skb->len < ETH_ZLEN &&
> +		    (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
> +			skb_checksum_help(skb);
> +			return rtl_skb_pad(skb);
[...]

skb_checksum_help() can fail, though it is unlikely for such a short
packet.  So I think this should be:

			return skb_checksum_help(skb) == 0 && rtl_skb_pad(skb);

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
