From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 06/15] 6lowpan: fix first fragment (FRAG1) handling
Date: Tue, 23 Oct 2012 09:19:38 +0200
Message-ID: <5086450A.9050506@computer.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org> <1350965397-12384-7-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:38521 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756727Ab2JWHUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:20:13 -0400
In-Reply-To: <1350965397-12384-7-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 06:09 AM, Tony Cheneau wrote:
> The first fragment, FRAG1, must contain some payload according to the
> specs. However, as it is currently written, the first fragment will
> remain empty and only contain the 6lowpan headers.
> 
> This patch also extract the transport layer information from the first
> fragment. This information is later on use when uncompressing UDP
> header.
> 
> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>  net/ieee802154/6lowpan.c |   54 +++++++++++++++++++++++++++++++++++----------
>  1 files changed, 42 insertions(+), 12 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 8a2ee95..38cecaf 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -654,7 +654,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
>  }
>  
>  static struct lowpan_fragment *
> -lowpan_alloc_new_frame(struct sk_buff *skb, u8 len, u16 tag)
> +lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
>  {
>  	struct lowpan_fragment *frame;
>  
> @@ -735,6 +735,18 @@ lowpan_process_data(struct sk_buff *skb)
>  		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits length */
>  		len = ((iphc0 & 7) << 8) | slen;
>  
> +		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1) {
> +			pr_debug("%s received a FRAG1 packet (tag: %d, "
> +				 "size of the entire IP packet: %d)"
> +				 , __func__, tag, len);

There are several schools of thought on the relative importance of
observing the 80-character line limit versus breaking up string
constants (in an attempt to maintain grepability). I think the above is
fine but others (whose opinion matters more than mine) may or may not
agree. Whatever you decide here, please apply consistently throughout.

However, the comma ahead of the __func__ should be at the end of the
previous line.

(...)

> -	/* if payload length is zero, therefore it's a first fragment */
> -	hlen = (plen == 0 ? LOWPAN_FRAG1_HEAD_SIZE :  LOWPAN_FRAGN_HEAD_SIZE);
> +	hlen = (type == LOWPAN_DISPATCH_FRAG1 ? LOWPAN_FRAG1_HEAD_SIZE :
> +			LOWPAN_FRAGN_HEAD_SIZE);

The second line of this statement should be aligned as follows:

+	hlen = (type == LOWPAN_DISPATCH_FRAG1 ? LOWPAN_FRAG1_HEAD_SIZE :
+		LOWPAN_FRAGN_HEAD_SIZE);

So the L for LOWPAN_FRAGN_HEAD_SIZE should be underneath the t for type.
