From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix multihoming retransmission path selection
 to rfc4960
Date: Thu, 20 Feb 2014 20:31:37 +0100
Message-ID: <53065819.6050603@redhat.com>
References: <1392897186-26841-1-git-send-email-dborkman@redhat.com> <530656E7.7010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445AbaBTUGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 15:06:51 -0500
In-Reply-To: <530656E7.7010404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2014 08:26 PM, Vlad Yasevich wrote:
> On 02/20/2014 06:53 AM, Daniel Borkmann wrote:
>> Problem statement: 1) both paths (primary path1 and alternate
>> path2) are up after the association has been established i.e.,
>> HB packets are normally exchanged, 2) path2 gets inactive after
>> path_max_retrans * max_rto timed out (i.e. path2 is down completely),
>> 3) now, if a transmission times out on the only surviving/active
>> path1 (any ~1sec network service impact could cause this like
>> a channel bonding failover), then the retransmitted packets are
>> sent over the inactive path2; this happens with partial failover
>> and without it.
>
> Interesting.  The problem above is actually triggered by
> sctp_retransmit().  When the T3-timeout occurs, we have
> active_patch == retrans_path, and even though the timeout
> occurred on the initial transmission of data, not a retransmit,
> we end up updating retransmit path.
>
> It might be worth adding adding this as a condition.  See below.
>
>> Besides not being optimal in the above scenario, a small failure
>> or timeout in the only existing path has the potential to cause
>> long delays in the retransmission (depending on RTO_MAX) until
>> the still active path is reselected.
>>
>> RFC4960, section 6.4. "Multi-Homed SCTP Endpoints" states under
>> 6.4.1. "Failover from an Inactive Destination Address" the
>> following:
>>
>>    Some of the transport addresses of a multi-homed SCTP endpoint
>>    may become inactive due to either the occurrence of certain
>>    error conditions (see Section 8.2) or adjustments from the
>>    SCTP user.
>>
>>    When there is outbound data to send and the primary path
>>    becomes inactive (e.g., due to failures), or where the SCTP
>>    user explicitly requests to send data to an inactive
>>    destination transport address, before reporting an error to
>>    its ULP, the SCTP endpoint should try to send the data to an
>>    alternate *active* destination transport address if one exists.
>>
>>    When retransmitting data that timed out, if the endpoint is
>>    multihomed, it should consider each source-destination address
>>    pair in its retransmission selection policy. When retransmitting
>>    timed-out data, the endpoint should attempt to pick the most
>>    divergent source-destination pair from the original
>>    source-destination pair to which the packet was transmitted.
>>
>>    Note: Rules for picking the most divergent source-destination
>>    pair are an implementation decision and are not specified
>>    within this document.
>>
>> So, we should first reconsider to take the current active
>> retransmission transport if we cannot find an alternative
>> active one, as otherwise, by sending a user message to an
>> inactive destination transport address while excluding an
>> active destination transport address, we would not comply
>> to RFC4960. If all of that fails, we can still round robin
>> through unkown, partial failover, and inactive ones in the
>> hope to find something still suitable/useful.
>>
>> Commit 4141ddc02a92 ("sctp: retran_path update bug fix") broke
>> that behaviour by selecting the next non-active transport when
>> no other active transport was found besides the current assoc's
>> peer.retran_path. Before commit 4141ddc02a92, we would have
>> traversed through the list until we reach our peer.retran_path
>> again, and in case that is still in state SCTP_ACTIVE, we would
>> take it and return. Only if that is not the case either, we
>> take the next inactive transport. Besides all that, another
>> issue is that transports in state SCTP_UNKNOWN could be preferred
>> over transports in state SCTP_ACTIVE in case a SCTP_ACTIVE
>> transport appears after SCTP_UNKNOWN in the transport list
>> yielding a "weaker" transport state to be used in retransmission.
>>
>> This patch mostly reverts 4141ddc02a92, but also rewrites
>> this function to introduce more clarity and strictness into
>> the code. A strict priority of transport states is enforced
>> in this patch, hence selection is active > unkown > partial
>> failover > inactive.
>>
>> Fixes: 4141ddc02a92 ("sctp: retran_path update bug fix")
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
...
>> -		t = list_entry(pos, struct sctp_transport, transports);
>> +	/* We're done as we only have the one and only path. */
>> +	if (asoc->peer.transport_count == 1)
>> +		return;
>>
>
> I think we should to do one more short circuit here:
>
>          /* If active_path and retrans_path are the same and active,
>           * then this is the only active path.  Use it.
>           */
>          if (asoc->peer.active_path == asoc->peer.retrans_path &&
>              asoc->peer.active_path->state == SCTP_ACTIVE)
>                  return;

Ok, will add and resubmit, thanks Vlad.

>> -		/* We have exhausted the list, but didn't find any
>> -		 * other active transports.  If so, use the next
>> -		 * transport.
>> -		 */
>> -		if (t == asoc->peer.retran_path) {
>> -			t = next;
>> +	/* Iterate from retran_path's successor back to retran_path. */
>> +	for (trans = list_next_entry(trans, transports); 1;
>> +	     trans = list_next_entry(trans, transports)) {
>> +		/* Manually skip the head element. */
>> +		if (&trans->transports == &asoc->peer.transport_addr_list)
>> +			continue;
>
> Alternative way would be:
>      head = &asoc->peer.transport_addr_list;
>      list_for_each_enty_from(trans, head, transport) {
>          ... do the work...
>
>          /* Manually skip head element if it's next */
>          if (list_next_entry(trans, transports) == head)
>              trans = list_first_entry(head);
>      }
>
> It's up to you if you like this better or not.

I tested already the current version, so I'll go for that. ;)

Thanks for your feedback Vlad!
