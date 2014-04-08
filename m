From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 11:28:43 -0400
Message-ID: <534415AB.80108@redhat.com>
References: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	Neil Horman <nhorman@tuxdriver.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756369AbaDHP3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 11:29:49 -0400
In-Reply-To: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2014 11:26 AM, Daniel Borkmann wrote:
> SCTP charges chunks for wmem accounting via skb->truesize in
> sctp_set_owner_w(), and sctp_wfree() respectively as the
> reverse operation. If a sender runs out of wmem, it needs to
> wait via sctp_wait_for_sndbuf(), and gets woken up by a call
> to __sctp_write_space() mostly via sctp_wfree().
> 
> __sctp_write_space() is being called per association. Although
> we assign sk->sk_write_space() to sctp_write_space(), which
> is then being done per socket, it is only used if send space
> is increased per socket option (SO_SNDBUF), as SOCK_USE_WRITE_QUEUE
> is set and therefore not invoked in sock_wfree().
> 
> Commit 4c3a5bdae293 ("sctp: Don't charge for data in sndbuf
> again when transmitting packet") fixed an issue where in case
> sctp_packet_transmit() manages to queue up more than sndbuf
> bytes, sctp_wait_for_sndbuf() will never be woken up again
> unless it is interrupted by a signal. However, a still
> remaining issue is that if net.sctp.sndbuf_policy=0, that is
> accounting per socket, and one-to-many sockets are in use,
> the reclaimed write space from sctp_wfree() is 'unfairly'
> handed back on the server to the association that is the lucky
> one to be woken up again via __sctp_write_space(), while
> the remaining associations are never be woken up again
> (unless by a signal).
> 
> The effect disappears with net.sctp.sndbuf_policy=1, that
> is wmem accounting per association, as it guarantees a fair
> share of wmem among associations.
> 
> Therefore, if we have reclaimed memory in case of per socket
> accounting, wake all related associations to a socket in a
> fair manner, that is, traverse the socket association list
> starting from the current neighbour of the association and
> issue a __sctp_write_space() to everyone until we end up
> waking ourselves. This guarantees that no association is
> preferred over another and even if more associations are
> taken into the one-to-many session, all receivers will get
> messages from the server and are not stalled forever on
> high load. This setting still leaves the advantage of per
> socket accounting in touch as an association can still use
> up global limits if unused by others.
> 
> Fixes: 4eb701dfc618 ("[SCTP] Fix SCTP sendbuffer accouting.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  [ When net-next opens up again, we need to think how
>    we can ideally make a new list interface and simplify
>    both open-coded list traversals. ]
> 
>  v1->v2:
>   - Improved comment, included note about locking
> 
>  net/sctp/socket.c | 36 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 981aaf8..96cfaba 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6593,6 +6593,40 @@ static void __sctp_write_space(struct sctp_association *asoc)
>  	}
>  }
>  
> +static void sctp_wake_up_waiters(struct sock *sk,
> +				 struct sctp_association *asoc)
> +{
> +	struct sctp_association *tmp = asoc;
> +
> +	/* We do accounting for the sndbuf space per association,
> +	 * so we only need to wake our own association.
> +	 */
> +	if (asoc->ep->sndbuf_policy)
> +		return __sctp_write_space(asoc);
> +
> +	/* Accounting for the sndbuf space is per socket, so we
> +	 * need to wake up others, try to be fair and in case of
> +	 * other associations, let them have a go first instead
> +	 * of just doing a sctp_write_space() call.
> +	 *
> +	 * Note that we reach sctp_wake_up_waiters() only when
> +	 * associations free up queued chunks, thus we are under
> +	 * lock and the list of associations on a socket is
> +	 * guaranteed not to change.
> +	 */
> +	for (tmp = list_next_entry(tmp, asocs); 1;
> +	     tmp = list_next_entry(tmp, asocs)) {
> +		/* Manually skip the head element. */
> +		if (&tmp->asocs == &((sctp_sk(sk))->ep->asocs))
> +			continue;
> +		/* Wake up association. */
> +		__sctp_write_space(tmp);
> +		/* We've reached the end. */
> +		if (tmp == asoc)
> +			break;
> +	}
> +}
> +
>  /* Do accounting for the sndbuf space.
>   * Decrement the used sndbuf space of the corresponding association by the
>   * data size which was just transmitted(freed).
> @@ -6620,7 +6654,7 @@ static void sctp_wfree(struct sk_buff *skb)
>  	sk_mem_uncharge(sk, skb->truesize);
>  
>  	sock_wfree(skb);
> -	__sctp_write_space(asoc);
> +	sctp_wake_up_waiters(sk, asoc);
>  
>  	sctp_association_put(asoc);
>  }
> 
