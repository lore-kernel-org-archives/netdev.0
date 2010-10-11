From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net-next 2/5] bnx2x: save cycles in setting gso_size
Date: Mon, 11 Oct 2010 15:00:33 +0100
Message-ID: <1286805633.2349.64.camel@achroite.uk.solarflarecom.com>
References: <1286749675.4669.24.camel@lb-tlvb-dmitry>
	 <20101010.205254.193716921.davem@davemloft.net>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4281D8@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42613 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561Ab0JKOAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 10:00:37 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4281D8@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-11 at 01:53 -0700, Vladislav Zolotarov wrote:
[...]
> Dave, it's a gSo_size, not a gRo_size and we are handling an LRO skb
> here. It's quite confusing, I agree... ;) This is currently the way 
> to mark an LRO skb in order to properly handle the LRO skbs that 
> might still be forwarded to the stack short time after the LRO has 
> been disabled due to enabling the IP forwarding (or if there is a 
> bug in a driver).
> See the skb_warn_if_lro() below:
> 
> static inline bool skb_warn_if_lro(const struct sk_buff *skb)
> {
> 	/* LRO sets gso_size but not gso_type, whereas if GSO is really
> 	 * wanted then gso_type will be set. */
> 	struct skb_shared_info *shinfo = skb_shinfo(skb);
> 	if (skb_is_nonlinear(skb) && shinfo->gso_size != 0 &&
> 	    unlikely(shinfo->gso_type == 0)) {
> 		__skb_warn_lro_forwarding(skb);
> 		return true;
> 	}
> 	return false;
> }
> 
> So, the convention is to set the gSo_size to a none-zero value leaving
> the gSo_type zero for an LRO skbs. It's quite hacky but this is what
> we have for quite a while and it quite worked so far. ;) To make it 
> cleaner we might have done the following:
[...]

The requirement (or as you call it, "convention") is to set gso_size to
the observed MSS of the packets that have been combined.  If you don't
do that then TCP will not know the true number of packets for purposes
of delayed-ACK etc.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

