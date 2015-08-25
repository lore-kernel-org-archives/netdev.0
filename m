From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2] sctp: asconf's process should verify address parameter
 is in the beginning
Date: Tue, 25 Aug 2015 12:03:59 -0400
Message-ID: <55DC91EF.8030706@redhat.com>
References: <3ffe8f6b86e33c016dddec672fab23a206c21acf.1440505764.git.lucien.xin@gmail.com> <20150825140113.GD1873@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	network dev <netdev@vger.kernel.org>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbbHYQED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 12:04:03 -0400
In-Reply-To: <20150825140113.GD1873@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2015 10:01 AM, Marcelo Ricardo Leitner wrote:
> On Tue, Aug 25, 2015 at 08:29:24PM +0800, Xin Long wrote:
>> in sctp_process_asconf(), we get address parameter from the beginning of
>> the addip params. but we never check if it's really there. if the addr
>> param is not there, it still can pass sctp_verify_asconf(), then to be
>> handled by sctp_process_asconf(), it will not be safe.
>>
>> so add a code in sctp_verify_asconf() to check the address parameter is in
>> the beginning, or return false to send abort.
>>
>> v1->v2:
>>  * put the check behind the params' length verify.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/sctp/sm_make_chunk.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index 06320c8..89a4d1c 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -3166,6 +3166,13 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>>  		return false;
>>  	if (!addr_param_needed && addr_param_seen)
>>  		return false;
>> +	if (addr_param_needed && addr_param_seen) {
>> +		/* Ensure the address parameter is in the beginning */
>> +		param.v = chunk->skb->data + sizeof(sctp_addiphdr_t);
> 
> Using param.v before the loop made sense but after the loop, it will
> cause all packets that hits here to be reject due to the check below.
> 
>> +		if (param.p->type != SCTP_PARAM_IPV4_ADDRESS &&
>> +		    param.p->type != SCTP_PARAM_IPV6_ADDRESS)
>> +			return false;
>> +	}
>>  	if (param.v != chunk->chunk_end)
>    this one    -----^
> 
> Maybe it's easier if you put this check inside the loop for each ipv4/6,
> and check if it is the first parameter or not by mimicing the way
> sctp_walk_params() finds the first chunk, it's just a pointer
> derreference and that was already checked and performed to reach there.
> 
> (You can have some logic with addr_param_seen so you don't catch the
> multiple parameters in there.)

Exactly!

something like this:
	SCTP_PARAM_IPV4_ADDRESS:
		if (param.v == addip->addip_hdr.params)
			addr_param_seen = true;

Thus making sure that the parameter as seen only when it's at the beginning...

Then later we can do things like:
	SCTP_PARAM_IPV4_ADDRESS:
		if (addr_param_seen) {
			/* peer placed multiple address parameters into the same
			 * asconf. reject it.
			 */
			return false;
		}

-vlad


> 
>   Marcelo
> 
>>  		return false;
>>  
>> -- 
>> 2.1.0
>>
