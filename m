From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 3/5] igb: fix race accessing page->_count
Date: Thu, 9 Oct 2014 22:54:56 -0700
Message-ID: <CAL3LdT7XkGju-10a8G3=nH+EgFdKeu4qE1V3M3DJoMBMG44JEQ@mail.gmail.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
	<1412918694-22882-4-git-send-email-edumazet@google.com>
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
Received: from mail-oi0-f44.google.com ([209.85.218.44]:64639 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaJJFy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:54:57 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so5605201oia.17
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 22:54:57 -0700 (PDT)
In-Reply-To: <1412918694-22882-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 10:24 PM, Eric Dumazet <edumazet@google.com> wrote:
> This is illegal to use atomic_set(&page->_count, 2) even if we 'own'
> the page. Other entities in the kernel need to use get_page_unless_zero()
> to get a reference to the page before testing page properties, so we could
> loose a refcount increment.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Change the title to :ixgbe: ...", then you have my ACK.
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Since this is apart of a series, if the changes to skbuff are ok, then
the changes to the Intel drivers are ok.

> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d677b5a23b58..fec5212d4337 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1865,12 +1865,10 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
>         /* flip page offset to other buffer */
>         rx_buffer->page_offset ^= truesize;
>
> -       /*
> -        * since we are the only owner of the page and we need to
> -        * increment it, just set the value to 2 in order to avoid
> -        * an unecessary locked operation
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
