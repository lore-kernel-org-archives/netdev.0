From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: fix locking bug in the rfcomm socket cleanup handling
Date: Thu, 29 May 2008 08:49:53 +0200
Message-ID: <AD9D7FA8-9626-473B-838F-B05ED91742D8@holtmann.org>
References: <20080528213006.02964148@infradead.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60684 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbYE2GuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 02:50:01 -0400
In-Reply-To: <20080528213006.02964148@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arjan,

> From: Arjan van de Ven <arjan@linux.intel.com>
> Subject: [PATCH] bluetooth: fix locking bug in the rfcomm socket  
> cleanup handling
>
> in net/bluetooth/rfcomm/sock.c, rfcomm_sk_state_change() does the
> following operation:
>
>      if (parent && sock_flag(sk, SOCK_ZAPPED)) {
>              /* We have to drop DLC lock here, otherwise
>               * rfcomm_sock_destruct() will dead lock. */
>              rfcomm_dlc_unlock(d);
>              rfcomm_sock_kill(sk);
>              rfcomm_dlc_lock(d);
>      }
> }
>
> which is fine, since rfcomm_sock_kill() will call sk_free() which  
> will call
> rfcomm_sock_destruct() which takes the rfcomm_dlc_lock()... so far  
> so good.
>
> HOWEVER, this assumes that the rfcomm_sk_state_change() function  
> always gets
> called with the rfcomm_dlc_lock() taken. This is the case for all  
> but one
> case, and in that case where we don't have the lock, we do a double  
> unlock
> followed by an attempt to take the lock, which due to underflow isn't
> going anywhere fast.
>
> This patch fixes this by moving the stragling case inside the lock,  
> like
> the other usages of the same call are doing in this code.
>
> This was found with the help of the www.kerneloops.org project,  
> where this
> deadlock was observed 51 times at this point in time:
> http://www.kerneloops.org/search.php?search=rfcomm_sock_destruct
>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
> net/bluetooth/rfcomm/core.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
> index eb62558..0c2c937 100644
> --- a/net/bluetooth/rfcomm/core.c
> +++ b/net/bluetooth/rfcomm/core.c
> @@ -423,8 +423,8 @@ static int __rfcomm_dlc_close(struct rfcomm_dlc  
> *d, int err)
>
> 		rfcomm_dlc_lock(d);
> 		d->state = BT_CLOSED;
> -		rfcomm_dlc_unlock(d);
> 		d->state_change(d, err);
> +		rfcomm_dlc_unlock(d);
>
> 		skb_queue_purge(&d->tx_queue);
> 		rfcomm_dlc_unlink(d);

this is really embarrassing, but a good catch on your side. I simply  
never realized that mistake when going through that part of the code.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

David, you might wanna queue this up for stable, too.

Regards

Marcel

