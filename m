From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH v2 net-next 05/12] 6lowpan: use
 short IEEE 802.15.4 addresses for broadcast destination
Date: Tue, 26 Mar 2013 12:56:21 +0100
Message-ID: <20130326115620.GB1341@x61s.campuswlan.hs-rm.de>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
 <1364270372-19430-6-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:36742 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757535Ab3CZLyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 07:54:47 -0400
Received: by mail-ea0-f179.google.com with SMTP id f15so2784852eak.10
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 04:54:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1364270372-19430-6-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tony,

On Mon, Mar 25, 2013 at 11:59:25PM -0400, Tony Cheneau wrote:
> The IEEE 802.15.4 standard uses the 0xFFFF short address (2 bytes) for message
> broadcasting.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>  net/ieee802154/6lowpan.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index e7f61de..0eebb96 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -572,21 +572,28 @@ static int lowpan_header_create(struct sk_buff *skb,
>  	 * this isn't implemented in mainline yet, so currently we assign 0xff
>  	 */
>  	{
> +		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
> +
>  		/* prepare wpan address data */
>  		sa.addr_type = IEEE802154_ADDR_LONG;
>  		sa.pan_id = 0xff;
> -
> -		da.addr_type = IEEE802154_ADDR_LONG;
> -		da.pan_id = 0xff;
> -
> -		memcpy(&(da.hwaddr), daddr, 8);
>  		memcpy(&(sa.hwaddr), saddr, 8);
>  
> -		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
> +		da.pan_id = 0xff;
> +		/*
> +		 * if the destination address is the broadcast address, use the
> +		 * corresponding short address
> +		 */
> +		if (lowpan_is_addr_broadcast(daddr)) {
> +			da.addr_type = IEEE802154_ADDR_SHORT;
> +			da.short_addr = IEEE802154_ADDR_BROADCAST;
> +		} else {
> +			da.addr_type = IEEE802154_ADDR_LONG;
> +			memcpy(&(da.hwaddr), daddr, 8);

It's some nitpick here.
Maybe it's better to use IEEE802154_ADDR_LEN instead of 8.

I mean we have this define, and we should use it if we mean the
ieee802154 address length.

Alex
