From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows SACK when bundling
Date: Mon, 23 Jul 2012 22:27:47 -0400
Message-ID: <42fcd21f-68bd-4dc7-8460-0cb968eb512e@email.android.com>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com> <500CDE35.6000009@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: xufengzhang.main@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xufeng zhang <xufeng.zhang@windriver.com>, sri@us.ibm.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44270 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab2GXC1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 22:27:51 -0400
In-Reply-To: <500CDE35.6000009@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xufeng zhang <xufeng.zhang@windriver.com> wrote:

>On 07/19/2012 01:57 PM, xufengzhang.main@gmail.com wrote:
>> When "Invalid Stream Identifier" ERROR happens after process the
>> received DATA chunks, this ERROR chunk is enqueued into outqueue
>> before SACK chunk, so when bundling ERROR chunk with SACK chunk,
>> the ERROR chunk is always placed first in the packet because of
>> the chunk's position in the outqueue.
>> This violates sctp specification:
>>      RFC 4960 6.5. Stream Identifier and Stream Sequence Number
>>      ...The endpoint may bundle the ERROR chunk in the same
>>      packet as the SACK as long as the ERROR follows the SACK.
>> So we must place SACK first when bundling "Invalid Stream Identifier"
>> ERROR and SACK in one packet.
>> Although we can do that by enqueue SACK chunk into outqueue before
>> ERROR chunk, it will violate the side-effect interpreter processing.
>> It's easy to do this job when dequeue chunks from the outqueue,
>> by this way, we introduce a flag 'has_isi_err' which indicate
>> whether or not the "Invalid Stream Identifier" ERROR happens.
>>
>> Signed-off-by: Xufeng Zhang<xufeng.zhang@windriver.com>
>> ---
>>   include/net/sctp/structs.h |    2 ++
>>   net/sctp/output.c          |   26 ++++++++++++++++++++++++++
>>   2 files changed, 28 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
>> index 88949a9..5adf4de 100644
>> --- a/include/net/sctp/structs.h
>> +++ b/include/net/sctp/structs.h
>> @@ -842,6 +842,8 @@ struct sctp_packet {
>>   	    has_sack:1,		/* This packet contains a SACK chunk. */
>>   	    has_auth:1,		/* This packet contains an AUTH chunk */
>>   	    has_data:1,		/* This packet contains at least 1 DATA chunk */
>> +	    has_isi_err:1,	/* This packet contains a "Invalid Stream
>> +				 * Identifier" ERROR chunk */
>>   	    ipfragok:1,		/* So let ip fragment this packet */
>>   	    malloced:1;		/* Is it malloced? */
>>   };
>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>> index 817174e..77fb1ae 100644
>> --- a/net/sctp/output.c
>> +++ b/net/sctp/output.c
>> @@ -79,6 +79,7 @@ static void sctp_packet_reset(struct sctp_packet
>*packet)
>>   	packet->has_sack = 0;
>>   	packet->has_data = 0;
>>   	packet->has_auth = 0;
>> +	packet->has_isi_err = 0;
>>   	packet->ipfragok = 0;
>>   	packet->auth = NULL;
>>   }
>> @@ -267,6 +268,7 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct
>sctp_packet *pkt,
>>   sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
>>   				     struct sctp_chunk *chunk)
>>   {
>> +	struct sctp_chunk *lchunk;
>>   	sctp_xmit_t retval = SCTP_XMIT_OK;
>>   	__u16 chunk_len = WORD_ROUND(ntohs(chunk->chunk_hdr->length));
>>
>> @@ -316,7 +318,31 @@ sctp_xmit_t sctp_packet_append_chunk(struct
>sctp_packet *packet,
>>   		packet->has_cookie_echo = 1;
>>   		break;
>>
>> +	    case SCTP_CID_ERROR:
>> +		if (chunk->subh.err_hdr->cause&  SCTP_ERROR_INV_STRM)
>> +			packet->has_isi_err = 1;
>> +		break;
>> +
>>   	    case SCTP_CID_SACK:
>> +		/* RFC 4960
>> +		 * 6.5 Stream Identifier and Stream Sequence Number
>> +		 * The endpoint may bundle the ERROR chunk in the same
>> +		 * packet as the SACK as long as the ERROR follows the SACK.
>> +		 */
>> +		if (packet->has_isi_err) {
>> +			if (list_is_singular(&packet->chunk_list))
>> +				list_add(&chunk->list,&packet->chunk_list);
>> +			else {
>> +				lchunk = list_first_entry(&packet->chunk_list,
>> +						struct sctp_chunk, list);
>> +				list_add(&chunk->list,&lchunk->list);
>> +			}
>>    
>And I should clarify the above judgment code.
>AFAIK, there should be two cases for the bundling when invalid stream 
>identifier error happens:
>1). COOKIE_ACK ERROR SACK
>2). ERROR SACK
>So I need to deal with the two cases differently.
>

Sorry but I just don't buy that the above are the only 2 cases.  What if there are addip chunks as well?  What if there are some other extensions also.  This code has to be generic enough to handle any condition.

- vlad

>
>Thanks,
>Xufeng Zhang
>> +			packet->size += chunk_len;
>> +			chunk->transport = packet->transport;
>> +			packet->has_sack = 1;
>> +			goto finish;
>> +		}
>> +
>>   		packet->has_sack = 1;
>>   		break;
>>
>>    


-- 
Sent from my Android phone with SkitMail. Please excuse my brevity.
