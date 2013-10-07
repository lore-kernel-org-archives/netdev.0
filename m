From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 11:01:32 +0100
Message-ID: <20131007100132.GA28411@zion.uk.xensource.com>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16218 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab3JGKBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 06:01:34 -0400
Content-Disposition: inline
In-Reply-To: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 05:26:23PM +0100, Paul Durrant wrote:
> Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error into
> xenvif_count_skb_slots() for skbs with a linear area spanning a page
> boundary. The alignment of skb->data needs to be taken into account, not
> just the head length. This patch fixes the issue by dry-running the code
> from xenvif_gop_skb() (and adjusting the comment above the function to note
> that).
> 

If I'm not mistaken the change in commit 4f0581d2 is correct because we
changed the way that the ring is packed. Now you seem to fall back to
the original scheme (or something in between without reverting later
other changes in that commit).

Do you have instruction to reproduce the bug? Can you paste some
detailed oops message?

Wei.

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Xi Xiong <xixiong@amazon.com>
> Cc: Matt Wilson <msw@amazon.com>
> Cc: Annie Li <annie.li@oracle.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <Ian.Campbell@citrix.com>
> 
> ---
>  drivers/net/xen-netback/netback.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index d0b0feb..6f680f4 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -223,15 +223,28 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>  /*
>   * Figure out how many ring slots we're going to need to send @skb to
>   * the guest. This function is essentially a dry run of
> - * xenvif_gop_frag_copy.
> + * xenvif_gop_skb.
>   */
>  unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>  {
> +	unsigned char *data;
>  	unsigned int count;
>  	int i, copy_off;
>  	struct skb_cb_overlay *sco;
>  
> -	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
> +	count = 0;
> +
> +	data = skb->data;
> +	while (data < skb_tail_pointer(skb)) {
> +		unsigned int offset = offset_in_page(data);
> +		unsigned int len = PAGE_SIZE - offset;
> +
> +		if (data + len > skb_tail_pointer(skb))
> +			len = skb_tail_pointer(skb) - data;
> +
> +		count++;
> +		data += len;
> +	}
>  
>  	copy_off = skb_headlen(skb) % PAGE_SIZE;
>  
> -- 
> 1.7.10.4
