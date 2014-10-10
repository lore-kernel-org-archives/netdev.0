From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 1/5] fm10k: fix race accessing page->_count
Date: Thu, 9 Oct 2014 22:53:28 -0700
Message-ID: <CAL3LdT5utMR0cZUBY8jVqHNVxA-Set+GEeYYn2nuomoZWPCQZQ@mail.gmail.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
	<1412918694-22882-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:65250 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaJJFx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:53:29 -0400
Received: by mail-oi0-f48.google.com with SMTP id g201so5541262oib.21
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 22:53:28 -0700 (PDT)
In-Reply-To: <1412918694-22882-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 10:24 PM, Eric Dumazet <edumazet@google.com> wrote:
> This is illegal to use atomic_set(&page->_count, 2) even if we 'own'
> the page. Other entities in the kernel need to use get_page_unless_zero()
> to get a reference to the page before testing page properties, so we could
> loose a refcount increment.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Since this is apart of a series, if the changes to skbuff are ok, then
the changes to the Intel drivers are ok.

> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> index 6c800a330d66..9d7118a0d67a 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> @@ -219,11 +219,10 @@ static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
>         /* flip page offset to other buffer */
>         rx_buffer->page_offset ^= FM10K_RX_BUFSZ;
>
> -       /* since we are the only owner of the page and we need to
> -        * increment it, just set the value to 2 in order to avoid
> -        * an unnecessary locked operation
> +       /* Even if we own the page, we are not allowed to use atomic_set()
> +        * This would break get_page_unless_zero() users.
>          */
> -       atomic_set(&page->_count, 2);
> +       atomic_inc(&page->_count);
>  #else
>         /* move offset up to the next cache line */
>         rx_buffer->page_offset += truesize;
> --
> 2.1.0.rc2.206.gedb03e5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cheers,
Jeff
