From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Fwd: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Sun, 23 Oct 2016 11:32:46 -0400
Message-ID: <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Xin Long <lucien.xin@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32770 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcJWPct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 11:32:49 -0400
Received: by mail-it0-f67.google.com with SMTP id k64so7119652itb.0
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 08:32:48 -0700 (PDT)
In-Reply-To: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry - I didnt mean to remove the mailing lists.
Please reply to this email instead.

cheers,
jamal

-------- Forwarded Message --------
Subject: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not 
return ENOMEM err back in sctp_packet_transmit
Date: Sun, 23 Oct 2016 11:03:36 -0400
From: Jamal Hadi Salim <jhs@mojatatu.com>
To: Xin Long <lucien.xin@gmail.com>
CC: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Vlad Yasevich 
<vyasevich@gmail.com>, daniel@iogearbox.net, gabor@mojatatu.com, Brenda 
Butler <bjb@mojatatu.com>, David Miller <davem@davemloft.net>, 
linux-sctp@vger.kernel.org <linux-sctp@vger.kernel.org>, Michael Tuexen 
<tuexen@fh-muenster.de>, Eric Dumazet <edumazet@google.com>



I think the specific use case this patch addresses
seems to have bitten us in an older kernel sctp (3.11?).
A send() on a loaded network box caused the skb to
alloc in what appears to be this code path and fail (problem
is intermittent, so not 100% sure). errno seen was ENOMEM.
Unfortunately the manpage for sendxxx sucks.
It says "no memory available".
[We'll fix the manpage if there is an appropriate answer].

Two questions:
a) Seems like we can safely ignore ENOMEM in user space
at least for this use case. i.e the kernel will retry and
eventually send this message. Is there any other scenario
where we have to worry about ENOMEM showing up in user space?

b) What is the general view of what sendXXX reaction oughta
be from user space in presence of ENOMEM?

cheers,
jamal

On 16-09-08 05:44 AM, Xin Long wrote:
> As David and Marcelo's suggestion, ENOMEM err shouldn't return back to
> user in transmit path. Instead, sctp's retransmit would take care of
> the chunks that fail to send because of ENOMEM.
>
> This patch is only to do some release job when alloc_skb fails, not to
> return ENOMEM back any more.
>
> Besides, it also cleans up sctp_packet_transmit's err path, and fixes
> some issues in err path:
>
>  - It didn't free the head skb in nomem: path.
>  - No need to check nskb in no_route: path.
>  - It should goto err: path if alloc_skb fails for head.
>  - Not all the NOMEMs should free nskb.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/output.c | 47 ++++++++++++++++++++++-------------------------
>  1 file changed, 22 insertions(+), 25 deletions(-)
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 1934933..8f490ff 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -442,14 +442,14 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  			 * time. Application may notice this error.
>  			 */
>  			pr_err_once("Trying to GSO but underlying device doesn't support it.");
> -			goto nomem;
> +			goto err;
>  		}
>  	} else {
>  		pkt_size = packet->size;
>  	}
>  	head = alloc_skb(pkt_size + MAX_HEADER, gfp);
>  	if (!head)
> -		goto nomem;
> +		goto err;
>  	if (gso) {
>  		NAPI_GRO_CB(head)->last = head;
>  		skb_shinfo(head)->gso_type = sk->sk_gso_type;
> @@ -470,8 +470,12 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  		}
>  	}
>  	dst = dst_clone(tp->dst);
> -	if (!dst)
> -		goto no_route;
> +	if (!dst) {
> +		if (asoc)
> +			IP_INC_STATS(sock_net(asoc->base.sk),
> +				     IPSTATS_MIB_OUTNOROUTES);
> +		goto nodst;
> +	}
>  	skb_dst_set(head, dst);
>
>  	/* Build the SCTP header.  */
> @@ -622,8 +626,10 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  		if (!gso)
>  			break;
>
> -		if (skb_gro_receive(&head, nskb))
> +		if (skb_gro_receive(&head, nskb)) {
> +			kfree_skb(nskb);
>  			goto nomem;
> +		}
>  		nskb = NULL;
>  		if (WARN_ON_ONCE(skb_shinfo(head)->gso_segs >=
>  				 sk->sk_gso_max_segs))
> @@ -717,18 +723,13 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	}
>  	head->ignore_df = packet->ipfragok;
>  	tp->af_specific->sctp_xmit(head, tp);
> +	goto out;
>
> -out:
> -	sctp_packet_reset(packet);
> -	return err;
> -no_route:
> -	kfree_skb(head);
> -	if (nskb != head)
> -		kfree_skb(nskb);
> -
> -	if (asoc)
> -		IP_INC_STATS(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
> +nomem:
> +	if (packet->auth && list_empty(&packet->auth->list))
> +		sctp_chunk_free(packet->auth);
>
> +nodst:
>  	/* FIXME: Returning the 'err' will effect all the associations
>  	 * associated with a socket, although only one of the paths of the
>  	 * association is unreachable.
> @@ -737,22 +738,18 @@ no_route:
>  	 * required.
>  	 */
>  	 /* err = -EHOSTUNREACH; */
> -err:
> -	/* Control chunks are unreliable so just drop them.  DATA chunks
> -	 * will get resent or dropped later.
> -	 */
> +	kfree_skb(head);
>
> +err:
>  	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
>  		list_del_init(&chunk->list);
>  		if (!sctp_chunk_is_data(chunk))
>  			sctp_chunk_free(chunk);
>  	}
> -	goto out;
> -nomem:
> -	if (packet->auth && list_empty(&packet->auth->list))
> -		sctp_chunk_free(packet->auth);
> -	err = -ENOMEM;
> -	goto err;
> +
> +out:
> +	sctp_packet_reset(packet);
> +	return err;
>  }
>
>  /********************************************************************
>
