From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: don't break the loop while meeting the active_path
 so as to find the matched transport
Date: Tue, 12 Mar 2013 10:24:02 +0800
Message-ID: <CA+=dFzjXO_W1v2g2VsBF7EKGj=c75ZrZPDx=R42Ug-waVLoGCw@mail.gmail.com>
References: <1362728377-11025-1-git-send-email-xufeng.zhang@windriver.com>
	<20130308142720.GA9873@hmsreliant.think-freely.org>
	<CA+=dFzjyd4av9D1TmrvguRXv-V7JnGWYJcN=ZEDu8Qhz2s+U7Q@mail.gmail.com>
	<20130311133121.GD12682@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Xufeng Zhang <xufeng.zhang@windriver.com>, vyasevich@gmail.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130311133121.GD12682@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>
>> Thanks for your review, Neil!
>>
>> I know what you mean, yes, it's most probably that the searched TSN was
>> transmitted in the currently active_path, but what should we do if not.
>>
>> Check the comment in sctp_assoc_lookup_tsn() function:
>> /* Let's be hopeful and check the active_path first. */
>> /* If not found, go search all the other transports. */
>>
>> It has checked the active_path first and then traverse all the other
>> transports in
>> the transport_addr_list except the active_path.
>>
>> So what I want to fix here is the inconsistency between the function
>> should do and
>> the code actually does.
>>
> I understand what you're doing, and I agree that the fix is functional
> (Hence
> my "This works" statement in my last note).  What I'm suggesting is that,
> since
> you're messing about in that code anyway that you clean it up while your at
> it,
> so that we don't need to have the if (transport == active) check at all.
> We
> trade in some extra work in a non-critical path (sctp_assoc_set_primary),
> for
> the removal of an extra for loop operation and a conditional check in a
> much
> hotter path.  Something like this (completely untested), is what I was
> thinking

Aha, seems I have some misunderstanding previously, now I got your point.
Yeah, it's better to do the clean up by this way, and this fix looks fine to me,
but I didn't have a test case to test this, actually this problem was detected
by code review, so I would like to leave the rest of this work to
determine by you.

Thank you very much for your clarification!


Thanks,
Xufeng

>
>
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 43cd0dd..8ae873c 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -505,6 +505,9 @@ void sctp_assoc_set_primary(struct sctp_association
> *asoc,
>
>  	asoc->peer.primary_path = transport;
>
> +	list_del_rcu(&transport->transports);
> +	list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
> +
>  	/* Set a default msg_name for events. */
>  	memcpy(&asoc->peer.primary_addr, &transport->ipaddr,
>  	       sizeof(union sctp_addr));
> @@ -1040,7 +1043,6 @@ struct sctp_chunk *sctp_get_ecne_prepend(struct
> sctp_association *asoc)
>  struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association
> *asoc,
>  					     __u32 tsn)
>  {
> -	struct sctp_transport *active;
>  	struct sctp_transport *match;
>  	struct sctp_transport *transport;
>  	struct sctp_chunk *chunk;
> @@ -1057,29 +1059,16 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct
> sctp_association *asoc,
>  	 * The general strategy is to search each transport's transmitted
>  	 * list.   Return which transport this TSN lives on.
>  	 *
> -	 * Let's be hopeful and check the active_path first.
> -	 * Another optimization would be to know if there is only one
> -	 * outbound path and not have to look for the TSN at all.
> +	 * Note, that sctp_assoc_set_primary does a move to front operation
> +	 * on the active_path transport, so this code implicitly checks
> +	 * the active_path first, as we most commonly expect to find our TSN
> +	 * there.
>  	 *
>  	 */
>
> -	active = asoc->peer.active_path;
> -
> -	list_for_each_entry(chunk, &active->transmitted,
> -			transmitted_list) {
> -
> -		if (key == chunk->subh.data_hdr->tsn) {
> -			match = active;
> -			goto out;
> -		}
> -	}
> -
> -	/* If not found, go search all the other transports. */
>  	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  			transports) {
>
> -		if (transport == active)
> -			break;
>  		list_for_each_entry(chunk, &transport->transmitted,
>  				transmitted_list) {
>  			if (key == chunk->subh.data_hdr->tsn) {
>
