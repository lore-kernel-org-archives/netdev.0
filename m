From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2]  vhost: fix check for # of outstanding buffers
Date: Thu, 21 Jul 2011 11:06:17 +0300
Message-ID: <20110721080617.GA20360@redhat.com>
References: <1311182592.8573.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab1GUIFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 04:05:52 -0400
Content-Disposition: inline
In-Reply-To: <1311182592.8573.45.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 10:23:12AM -0700, Shirley Ma wrote:
> Fix the check for number of outstanding buffers returns incorrect
> results due to vq->pend_idx wrap around;
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

OK, the logic's right now, and it's not worse
than what we had, so I applied this after
fixing up the comment (it's upend_idx and English
sentences don't need to end with a semicolumn ;)

However, I would like to see the effect of the bug
noted in the log in the future.

And the reason I mention this here, is that
I think that the whole VHOST_MAX_PEND thing
does not work as advertised: this logic only
triggers when the ring is empty, so we will happily push
more than VHOST_MAX_PEND packets if the guest manages
to give them to us.

I'm not sure why we have the limit, either: the wmem
limit in the socket still applies and seems more
effective to prevent denial of service by a malicious guest.

> ---
> 
>  drivers/vhost/net.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 70ac604..946a71e 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -182,15 +182,21 @@ static void handle_tx(struct vhost_net *net)
>  			break;
>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
>  		if (head == vq->num) {
> +			int num_pends;
> +
>  			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>  			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
>  				tx_poll_start(net, sock);
>  				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>  				break;
>  			}
> -			/* If more outstanding DMAs, queue the work */
> -			if (unlikely(vq->upend_idx - vq->done_idx >
> -				     VHOST_MAX_PEND)) {
> +			/* If more outstanding DMAs, queue the work
> +			 * handle upend_idx wrap around
> +			 */
> +			num_pends = (vq->upend_idx >= vq->done_idx) ?
> +				    (vq->upend_idx - vq->done_idx) :
> +				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
> +			if (unlikely(num_pends > VHOST_MAX_PEND)) {
>  				tx_poll_start(net, sock);
>  				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>  				break;
> 
