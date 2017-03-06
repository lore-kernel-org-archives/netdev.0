From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH v6 6/6] 6lowpan: Fix IID format for Bluetooth
Date: Mon, 6 Mar 2017 21:03:24 +0100
Message-ID: <eaf424c0-731a-2bab-0050-35d0a1091fcb@pengutronix.de>
References: <20170302132335.21192-1-luiz.dentz@gmail.com>
 <20170302132335.21192-7-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, patrik.flykt@linux.intel.com,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:36037 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753816AbdCFUEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 15:04:16 -0500
In-Reply-To: <20170302132335.21192-7-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

sorry, I decided now to take a look into the patch... Currently I have
no time to do anything... normally. That's why I simple said "everything
okay" in irc.

On 03/02/2017 02:23 PM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> 
> According to RFC 7668 U/L bit shall not be used:
> 
> https://wiki.tools.ietf.org/html/rfc7668#section-3.2.2 [Page 10]:
> 
>    In the figure, letter 'b' represents a bit from the
>    Bluetooth device address, copied as is without any changes on any
>    bit.  This means that no bit in the IID indicates whether the
>    underlying Bluetooth device address is public or random.
> 
>    |0              1|1              3|3              4|4              6|
>    |0              5|6              1|2              7|8              3|
>    +----------------+----------------+----------------+----------------+
>    |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
>    +----------------+----------------+----------------+----------------+
> 
> Because of this the code cannot figure out the address type from the IP
> address anymore thus it makes no sense to use peer_lookup_ba as it needs
> the peer address type.
> 
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
> Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> ---
>  include/net/6lowpan.h   |  4 ---
>  include/net/addrconf.h  |  7 ++++-
>  net/bluetooth/6lowpan.c | 79 ++++++++-----------------------------------------
>  3 files changed, 18 insertions(+), 72 deletions(-)
> 
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index c5792cb..a713780 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -211,10 +211,6 @@ static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
>  	ipaddr->s6_addr[11] = 0xFF;
>  	ipaddr->s6_addr[12] = 0xFE;
>  	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
> -	/* second bit-flip (Universe/Local)
> -	 * is done according RFC2464
> -	 */
> -	ipaddr->s6_addr[8] ^= 0x02;
>  }
>  
>  #ifdef DEBUG
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 17c6fd8..3931fd2 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -129,7 +129,12 @@ static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  	} else {
>  		eui[3] = 0xFF;
>  		eui[4] = 0xFE;
> -		eui[0] ^= 2;
> +
> +		/*
> +		 * According to RFC 7668 U/L bit shall not be toggled.
> +		 */
> +		if (dev->type != ARPHRD_6LOWPAN)
> +			eui[0] ^= 2;
>  	}
>  	return 0;
>  }

I don't know why you make this in such function which is called by a lot
of others dev->types which are not ARPHRD_6LOWPAN.

What addrconf does now is a switch case over dev->type and then calling
addrconf_ifid_eui48 for some cases and recheck again dev->type for a
special case of ARPHRD_6LOWPAN.

ARPHRD_6LOWPAN is also somehow wrong because you need check on ARPHRD_6LOWPAN and
LLTYPE_BTLE. As I mentioned the IPv6-over-foo adaptation describes how
to generate IID and not the dev->addr_len.

---

Second thing is we bitflip u/l and then we bitflip again because we
don't want it and do it again...

---

Anyway, I see it will working for you... but it's very confusing for me.
Don't use addrconf_ifid_eui48 here, grab 2-3 code lines from which does:

1. copy first mac addr bytes
2. set FF FE
3. copy last mac addr bytes

and this according LLTYPE_BTLE and not dev->addr_len....

---

For me it's not acceptable because you doing dev->type handling which is
already evaluated before and other subsystems will do such check as
well. We can avoid this check on others subsystems. If your IID is
different generated than a normal EUI48, then simple don't use
addrconf_ifid_eui48.

---

We already talked about to place the 8 IID bytes into 6lowpan netdev private
space. If we do that later, we need to touch addrconf_ifid_eui48
again..

- Alex
