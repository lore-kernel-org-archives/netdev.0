From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/3] XFRM: Drop packets when replay counter would
	overflow
Date: Fri, 21 Dec 2007 09:28:26 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0712210928180.27551@us.intercode.com.au>
References: <20071220214200.12122.89628.stgit@flek.lan>
	<20071220214230.12122.77900.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071220214230.12122.77900.stgit@flek.lan>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Dec 2007, Paul Moore wrote:

> According to RFC4303, section 3.3.3 we need to drop outgoing packets which
> cause the replay counter to overflow:
> 
>    3.3.3.  Sequence Number Generation
> 
>    The sender's counter is initialized to 0 when an SA is established.
>    The sender increments the sequence number (or ESN) counter for this
>    SA and inserts the low-order 32 bits of the value into the Sequence
>    Number field.  Thus, the first packet sent using a given SA will
>    contain a sequence number of 1.
> 
>    If anti-replay is enabled (the default), the sender checks to ensure
>    that the counter has not cycled before inserting the new value in the
>    Sequence Number field.  In other words, the sender MUST NOT send a
>    packet on an SA if doing so would cause the sequence number to cycle.
>    An attempt to transmit a packet that would result in sequence number
>    overflow is an auditable event.  The audit log entry for this event
>    SHOULD include the SPI value, current date/time, Source Address,
>    Destination Address, and (in IPv6) the cleartext Flow ID.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org> 


> ---
> 
>  net/xfrm/xfrm_output.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index eb3333b..284eeef 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -57,8 +57,11 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
>  
>  		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
>  			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
> -			if (unlikely(x->replay.oseq == 0))
> +			if (unlikely(x->replay.oseq == 0)) {
> +				x->replay.oseq--;
>  				xfrm_audit_state_replay_overflow(x, skb);
> +				goto error;
> +			}
>  			if (xfrm_aevent_is_on())
>  				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
>  		}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
