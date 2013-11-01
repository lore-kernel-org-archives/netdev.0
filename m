From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH NEXT V2] rtlwifi: Fix endian error in extracting packet
 type
Date: Fri, 1 Nov 2013 01:02:49 +0000
Message-ID: <1383267769.1583.8.camel@bwh-desktop.uk.level5networks.com>
References: <1383266638-4813-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Mark Cave-Ayland" <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383266638-4813-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-10-31 at 19:43 -0500, Larry Finger wrote:
> From: Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>
> 
> All of the rtlwifi drivers have an error in the routine that tests if
> the data is "special". If it is, the subsequant transmission will be
> at the lowest rate to enhance reliability. The 16-bit quantity is
> big-endian, but was being extracted in native CPU mode. One of the
> effects of this bug is to inhibit association under some conditions
> as the TX rate is too high.
> 
> A statement that would have made the code correct had been changed to
> a comment. Rather than just reinstating that code, the fix here passes
> sparse tests. A side effect of fixing this problem would have been to force
> all IPv6 frames to run at the lowest rate. The test for that frame type
> is removed.
> 
> The original code only checked the lower-order byte of UDP ports for BOOTP
> protocol. That is extended to the full 16-bit source and destination ports.
> 
> One of the local headers contained duplicates of some of the ETH_P_XXX
> definitions. These are deleted.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Mark Cave-Ayland <mark.cave-ayland-r2/yp8inhXLQXOPxS62xeg@public.gmane.org>
> Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [2.6.38+]
> ---
> 
> V2 - Addresses comments by Ben Hutchings and Bjorn Mork.
> 
>  drivers/net/wireless/rtlwifi/base.c |   15 ++++++---------
>  drivers/net/wireless/rtlwifi/wifi.h |    6 +-----
>  2 files changed, 7 insertions(+), 14 deletions(-)
> Index: wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
> ===================================================================
> --- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/base.c
> +++ wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
> @@ -1077,17 +1077,17 @@ u8 rtl_is_special_data(struct ieee80211_
>  
>  	ip = (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
>  			      SNAP_SIZE + PROTOC_TYPE_SIZE);
> -	ether_type = *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
> -	/*	ether_type = ntohs(ether_type); */
> +	ether_type = be16_to_cpu(*(__be16 *)((u8 *)skb->data + mac_hdr_len +
> +					     SNAP_SIZE));
>  
>  	if (ETH_P_IP == ether_type) {
>  		if (IPPROTO_UDP == ip->protocol) {
>  			struct udphdr *udp = (struct udphdr *)((u8 *) ip +
>  							       (ip->ihl << 2));
> -			if (((((u8 *) udp)[1] == 68) &&
> -			     (((u8 *) udp)[3] == 67)) ||
> -			    ((((u8 *) udp)[1] == 67) &&
> -			     (((u8 *) udp)[3] == 68))) {
> +			if (((((u16 *) udp)[0] == 68) &&
> +			     (((u16 *) udp)[2] == 67)) ||
> +			    ((((u16 *) udp)[0] == 67) &&
> +			     (((u16 *) udp)[2] == 68))) {
[...]

Now you're missing byte-swapping here, and using the wrong offset for
the dest port (4 bytes rather than 2).

If you really think this is necessary then use something like:
			if ((udp->source == htons(68) &&
			     udp->dest == htons(67)) ||
			     ...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
