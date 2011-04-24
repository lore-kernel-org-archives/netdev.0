From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v4 4/5] sctp: Add ASCONF operation on the single-homed host
Date: Sun, 24 Apr 2011 18:24:22 +0900
Message-ID: <C4F46092-BF76-482D-8FD5-08F1D6A13866@sfc.wide.ad.jp>
References: <3BDA3586-6A7C-4305-9D41-F146575AC951@sfc.wide.ad.jp> <4DB0FD45.2050709@cn.fujitsu.com> <4DB0FFB1.3010006@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55518 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755851Ab1DXJY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 05:24:27 -0400
In-Reply-To: <4DB0FFB1.3010006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 22, 2011, at 13:10 , Wei Yongjun wrote:

> 
>> 
>> Since the sender MUST NOT use the  new IP address as a source for ANY SCTP
>> packet except on  carrying an ASCONF Chunk. And ASCONF chunk can be bundled.
>> How about this change. If so, you do not need change to sctp_outq_tail();
>> 
>> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
>> index 1c88c89..bd6cc9c 100644
>> --- a/net/sctp/outqueue.c
>> +++ b/net/sctp/outqueue.c
>> @@ -754,6 +754,13 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>> 	 */
>> 
>> 	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
>> +		/* RFC 5061, 5.3
>> +		 * F1) This ...
>> +		 */
>> +		if (q->asoc->src_out_of_asoc_ok &&
>> +		    chunk->chunk_hdr->type != SCTP_CID_ASCONF)
> 
> SCTP_CID_ASCONF_ACK should be also allowed, the peer may
> send ASCONF to do the same thing at the same time.
Sorry for my bad understanding, 
Do you mean the situation: "the peer (ASCONF receiver) may send ASCONF-ACK to the unconfirmed destination"?
Or do you mean following situation?
1. the pear sends ADD/DEL ASCONF to me, 
2. I receive it, 
3. I migrate to the other network and get new address, 
4. I send ASCONF-ACK to the peer from the new address

> 
>> +			continue;
>> +
>> 		list_del_init(&chunk->list);
>> 
>> 		/* Pick the right transport to use. */
>> @@ -881,6 +888,9 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>> 		}
>> 	}
>> 
>> +	if (q->asoc->src_out_of_asoc_ok)
>> +		goto sctp_flush_out;
>> +
>> 	/* Is it OK to send data chunks?  */
>> 	switch (asoc->state) {
>> 	case SCTP_STATE_COOKIE_ECHOED:
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

