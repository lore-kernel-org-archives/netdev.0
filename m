From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] skb: Add documentation for skb_clone_sk
Date: Mon, 08 Sep 2014 10:11:37 -0700
Message-ID: <1410196297.11872.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33822 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177AbaIHRLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 13:11:43 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so3504893pab.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 10:11:43 -0700 (PDT)
In-Reply-To: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 12:18 -0400, Alexander Duyck wrote:
> This change adds some documentation to the call skb_clone_sk.  This is
> meant to help clarify the purpose of the function for other developers.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/core/skbuff.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index a18dfb0..3f83a8a 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3511,6 +3511,17 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sock_dequeue_err_skb);
>  
> +/**
> + * skb_clone_sk - create clone of skb, and take reference to socket
> + * @skb: the skb to clone
> + *
> + * For functions such as timestamping it is necessary to clone an skb and
> + * hold a reference to the socket for it until the hardware delivers the
> + * actual timestamp or the timestamp is timed out.  As as such this
> + * function is useful for creating a clone to later be handed off to
> + * skb_complete_tx_timestamp or kfree_skb to take care of cleaning up
> + * the reference handling for the socket.
> + */
>  struct sk_buff *skb_clone_sk(struct sk_buff *skb)
>  {
>  	struct sock *sk = skb->sk;

Note that I have serious doubts about the atomic_inc_not_zero() here.

At this point, we need to have consistent refcounting on the socket.

If we decide the reference is against sk_refcnt, then current sk_refcnt
cannot be 0 at this point.

This might hide a very serious bug.

In TCP tx path for example, we do not take reference on sk_refcnt for
each packet, but a reference on sk_wmem_alloc

If skb destructor is sock_wfree() or tcp_wfree(), then we should take an
extra reference on sk_wmem_alloc instead of sk_refcnt.
