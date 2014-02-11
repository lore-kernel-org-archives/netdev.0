From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Tue, 11 Feb 2014 09:52:04 -0500
Message-ID: <52FA3914.90002@gmail.com>
References: <52F72AFE.4060802@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>
To: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:40341 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaBKOwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 09:52:08 -0500
In-Reply-To: <52F72AFE.4060802@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matija

On 02/09/2014 02:15 AM, Matija Glavinic Pecotic wrote:
>
> Proposed solution:
>
> Both problems share the same root cause, and that is improper scaling
of socket
> buffer with rwnd. Solution in which sizeof(sk_buff) is taken into
concern while
> calculating rwnd is not possible due to fact that there is no linear
> relationship between amount of data blamed in increase/decrease with
IP packet
> in which payload arrived. Even in case such solution would be followed,
> complexity of the code would increase. Due to nature of current rwnd
handling,
> slow increase (in sctp_assoc_rwnd_increase) of rwnd after pressure
state is
> entered is rationale, but it gives false representation to the sender
of current
> buffer space. Furthermore, it implements additional congestion control
mechanism
> which is defined on implementation, and not on standard basis.
>
> Proposed solution simplifies whole algorithm having on mind definition
from rfc:
>
> o  Receiver Window (rwnd): This gives the sender an indication of the
space
>    available in the receiver's inbound buffer.
>
> Core of the proposed solution is given with these lines:
>
> sctp_assoc_rwnd_update:
> 	if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
> 		asoc->rwnd = (asoc->base.sk->sk_rcvbuf - rx_count) >> 1;
> 	else
> 		asoc->rwnd = 0;
>
> We advertise to sender (half of) actual space we have. Half is in the
braces
> depending whether you would like to observe size of socket buffer as
SO_RECVBUF
> or twice the amount, i.e. size is the one visible from userspace, that is,
> from kernelspace.
> In this way sender is given with good approximation of our buffer space,
> regardless of the buffer policy - we always advertise what we have.
Proposed
> solution fixes described problems and removes necessity for rwnd
restoration
> algorithm. Finally, as proposed solution is simplification, some lines
of code,
> along with some bytes in struct sctp_association are saved.
>
> Signed-off-by: Matija Glavinic Pecotic
<matija.glavinic-pecotic.ext@nsn.com>
> Reviewed-by: Alexander Sverdlin <alexander.sverdlin@nsn.com>
>
> --- net-next.orig/net/sctp/associola.c
> +++ net-next/net/sctp/associola.c
> @@ -1367,44 +1367,35 @@ static inline bool sctp_peer_needs_updat
>  	return false;
>  }
>
> -/* Increase asoc's rwnd by len and send any window update SACK if
needed. */
> -void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned
int len)
> +/* Update asoc's rwnd for the approximated state in the buffer,
> + * and check whether SACK needs to be sent.
> + */
> +void sctp_assoc_rwnd_update(struct sctp_association *asoc, bool
update_peer)
>  {
> +	int rx_count;
>  	struct sctp_chunk *sack;
>  	struct timer_list *timer;
>
> -	if (asoc->rwnd_over) {
> -		if (asoc->rwnd_over >= len) {
> -			asoc->rwnd_over -= len;
> -		} else {
> -			asoc->rwnd += (len - asoc->rwnd_over);
> -			asoc->rwnd_over = 0;
> -		}
> -	} else {
> -		asoc->rwnd += len;
> -	}
> +	if (asoc->ep->rcvbuf_policy)
> +		rx_count = atomic_read(&asoc->rmem_alloc);
> +	else
> +		rx_count = atomic_read(&asoc->base.sk->sk_rmem_alloc);
>
> -	/* If we had window pressure, start recovering it
> -	 * once our rwnd had reached the accumulated pressure
> -	 * threshold.  The idea is to recover slowly, but up
> -	 * to the initial advertised window.
> -	 */
> -	if (asoc->rwnd_press && asoc->rwnd >= asoc->rwnd_press) {
> -		int change = min(asoc->pathmtu, asoc->rwnd_press);
> -		asoc->rwnd += change;
> -		asoc->rwnd_press -= change;
> -	}
> +	if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
> +		asoc->rwnd = (asoc->base.sk->sk_rcvbuf - rx_count) >> 1;
> +	else
> +		asoc->rwnd = 0;
>
> -	pr_debug("%s: asoc:%p rwnd increased by %d to (%u, %u) - %u\n",
> -		 __func__, asoc, len, asoc->rwnd, asoc->rwnd_over,
> -		 asoc->a_rwnd);
> +	pr_debug("%s: asoc:%p rwnd=%u, rx_count=%d, sk_rcvbuf=%d\n",
> +		 __func__, asoc, asoc->rwnd, rx_count,
> +		 asoc->base.sk->sk_rcvbuf);
>
>  	/* Send a window update SACK if the rwnd has increased by at least the
>  	 * minimum of the association's PMTU and half of the receive buffer.
>  	 * The algorithm used is similar to the one described in
>  	 * Section 4.2.3.3 of RFC 1122.
>  	 */
> -	if (sctp_peer_needs_update(asoc)) {
> +	if (update_peer && sctp_peer_needs_update(asoc)) {
>  		asoc->a_rwnd = asoc->rwnd;
>
>  		pr_debug("%s: sending window update SACK- asoc:%p rwnd:%u "
> @@ -1426,45 +1417,6 @@ void sctp_assoc_rwnd_increase(struct sct
>  	}
>  }
>
> -/* Decrease asoc's rwnd by len. */
> -void sctp_assoc_rwnd_decrease(struct sctp_association *asoc, unsigned
int len)
> -{
> -	int rx_count;
> -	int over = 0;
> -
> -	if (unlikely(!asoc->rwnd || asoc->rwnd_over))
> -		pr_debug("%s: association:%p has asoc->rwnd:%u, "
> -			 "asoc->rwnd_over:%u!\n", __func__, asoc,
> -			 asoc->rwnd, asoc->rwnd_over);
> -
> -	if (asoc->ep->rcvbuf_policy)
> -		rx_count = atomic_read(&asoc->rmem_alloc);
> -	else
> -		rx_count = atomic_read(&asoc->base.sk->sk_rmem_alloc);
> -
> -	/* If we've reached or overflowed our receive buffer, announce
> -	 * a 0 rwnd if rwnd would still be positive.  Store the
> -	 * the potential pressure overflow so that the window can be restored
> -	 * back to original value.
> -	 */
> -	if (rx_count >= asoc->base.sk->sk_rcvbuf)
> -		over = 1;
> -
> -	if (asoc->rwnd >= len) {
> -		asoc->rwnd -= len;
> -		if (over) {
> -			asoc->rwnd_press += asoc->rwnd;
> -			asoc->rwnd = 0;
> -		}
> -	} else {
> -		asoc->rwnd_over = len - asoc->rwnd;
> -		asoc->rwnd = 0;
> -	}
> -
> -	pr_debug("%s: asoc:%p rwnd decreased by %d to (%u, %u, %u)\n",
> -		 __func__, asoc, len, asoc->rwnd, asoc->rwnd_over,
> -		 asoc->rwnd_press);
> -}
>
>  /* Build the bind address list for the association based on info from the
>   * local endpoint and the remote peer.
> --- net-next.orig/include/net/sctp/structs.h
> +++ net-next/include/net/sctp/structs.h
> @@ -1653,17 +1653,6 @@ struct sctp_association {
>  	/* This is the last advertised value of rwnd over a SACK chunk. */
>  	__u32 a_rwnd;
>
> -	/* Number of bytes by which the rwnd has slopped.  The rwnd is allowed
> -	 * to slop over a maximum of the association's frag_point.
> -	 */
> -	__u32 rwnd_over;
> -
> -	/* Keeps treack of rwnd pressure.  This happens when we have
> -	 * a window, but not recevie buffer (i.e small packets).  This one
> -	 * is releases slowly (1 PMTU at a time ).
> -	 */
> -	__u32 rwnd_press;
> -
>  	/* This is the sndbuf size in use for the association.
>  	 * This corresponds to the sndbuf size for the association,
>  	 * as specified in the sk->sndbuf.
> @@ -1892,8 +1881,7 @@ void sctp_assoc_update(struct sctp_assoc
>  __u32 sctp_association_get_next_tsn(struct sctp_association *);
>
>  void sctp_assoc_sync_pmtu(struct sock *, struct sctp_association *);
> -void sctp_assoc_rwnd_increase(struct sctp_association *, unsigned int);
> -void sctp_assoc_rwnd_decrease(struct sctp_association *, unsigned int);
> +void sctp_assoc_rwnd_update(struct sctp_association *, bool);
>  void sctp_assoc_set_primary(struct sctp_association *,
>  			    struct sctp_transport *);
>  void sctp_assoc_del_nonprimary_peers(struct sctp_association *,
> --- net-next.orig/net/sctp/sm_statefuns.c
> +++ net-next/net/sctp/sm_statefuns.c
> @@ -6176,7 +6176,7 @@ static int sctp_eat_data(const struct sc
>  	 * PMTU.  In cases, such as loopback, this might be a rather
>  	 * large spill over.
>  	 */
> -	if ((!chunk->data_accepted) && (!asoc->rwnd || asoc->rwnd_over ||
> +	if ((!chunk->data_accepted) && (!asoc->rwnd ||
>  	    (datalen > asoc->rwnd + asoc->frag_point))) {
>
>  		/* If this is the next TSN, consider reneging to make
> --- net-next.orig/net/sctp/socket.c
> +++ net-next/net/sctp/socket.c
> @@ -2092,12 +2092,6 @@ static int sctp_recvmsg(struct kiocb *io
>  		sctp_skb_pull(skb, copied);
>  		skb_queue_head(&sk->sk_receive_queue, skb);
>
> -		/* When only partial message is copied to the user, increase
> -		 * rwnd by that amount. If all the data in the skb is read,
> -		 * rwnd is updated when the event is freed.
> -		 */
> -		if (!sctp_ulpevent_is_notification(event))
> -			sctp_assoc_rwnd_increase(event->asoc, copied);
>  		goto out;
>  	} else if ((event->msg_flags & MSG_NOTIFICATION) ||
>  		   (event->msg_flags & MSG_EOR))
> --- net-next.orig/net/sctp/ulpevent.c
> +++ net-next/net/sctp/ulpevent.c
> @@ -989,7 +989,7 @@ static void sctp_ulpevent_receive_data(s
>  	skb = sctp_event2skb(event);
>  	/* Set the owner and charge rwnd for bytes received.  */
>  	sctp_ulpevent_set_owner(event, asoc);
> -	sctp_assoc_rwnd_decrease(asoc, skb_headlen(skb));
> +	sctp_assoc_rwnd_update(asoc, false);
>
>  	if (!skb->data_len)
>  		return;
> @@ -1035,8 +1035,9 @@ static void sctp_ulpevent_release_data(s
>  	}
>
>  done:
> -	sctp_assoc_rwnd_increase(event->asoc, len);
> -	sctp_ulpevent_release_owner(event);
> +	atomic_sub(event->rmem_len, &event->asoc->rmem_alloc);
> +	sctp_assoc_rwnd_update(event->asoc, true);
> +	sctp_association_put(event->asoc)

Can't we simply change the order of window update and release instead
of open coding it like this?


-vlad

>  }
>
>  static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
