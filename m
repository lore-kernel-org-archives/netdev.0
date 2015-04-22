From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Wed, 22 Apr 2015 12:43:45 -0700
Message-ID: <5537F9F1.1080008@gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35104 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877AbbDVTnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 15:43:47 -0400
Received: by pabtp1 with SMTP id tp1so281628262pab.2
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 12:43:47 -0700 (PDT)
In-Reply-To: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 10:45 AM, Cong Wang wrote:
> The second parameter of eth_get_headlen() is the length of
> the frame buffer, not the header length of skb.
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index a0a9b1f..7b3a370 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6852,7 +6852,9 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
>  	/* we need the header to contain the greater of either ETH_HLEN or
>  	 * 60 bytes if the skb->len is less than 60 for skb_pad.
>  	 */
> -	pull_len = eth_get_headlen(va, IGB_RX_HDR_LEN);
> +	pull_len = eth_get_headlen(va, skb_frag_size(frag));
> +	if (unlikely(pull_len > IGB_RX_HDR_LEN))
> +		pull_len = IGB_RX_HDR_LEN;
>  
>  	/* align pull length to size of long to optimize memcpy performance */
>  	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));

You have this part right.  The length represents the maximum length we
are willing to traverse in the buffer.  So if we 100% want to get the
entire header regardless of what we can copy into then we could follow
your approach.  However, since the allocated space in the skb is only
IGB_RX_HDR_LEN we only really want to traverse up to that length.  Then
that is all we copy out of the header.

As a result we don't need the extra code for putting the upper limit on
pull_len since that is factored in by passing IGB_RX_HDR_LEN as the
maximum traversal length.

- Alex
