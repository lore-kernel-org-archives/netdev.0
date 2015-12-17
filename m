From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: sctp should release assoc when
 sctp_make_abort_user return NULL in sctp_close
Date: Thu, 17 Dec 2015 17:01:15 -0200
Message-ID: <5673067B.6080001@gmail.com>
References: <48cc5cc3af81404dffc6121f075c05e6b8c5171c.1450362652.git.lucien.xin@gmail.com>
 <5672FF06.2030803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, davem@davemloft.net
To: Vlad Yasevich <vyasevich@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33099 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbbLQTBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 14:01:22 -0500
In-Reply-To: <5672FF06.2030803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 17-12-2015 16:29, Vlad Yasevich escreveu:
> On 12/17/2015 09:30 AM, Xin Long wrote:
>> In sctp_close, sctp_make_abort_user may return NULL because of memory
>> allocation failure. If this happens, it will bypass any state change
>> and never free the assoc. The assoc has no chance to be freed and it
>> will be kept in memory with the state it had even after the socket is
>> closed by sctp_close().
>>
>> So if sctp_make_abort_user fails to allocate memory, we should just
>> free the asoc, as there isn't much else that we can do.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> ---
>>   net/sctp/socket.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 9b6cc6d..267b8f8 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -1513,8 +1513,12 @@ static void sctp_close(struct sock *sk, long timeout)
>>   			struct sctp_chunk *chunk;
>>
>>   			chunk = sctp_make_abort_user(asoc, NULL, 0);
>> -			if (chunk)
>> +			if (chunk) {
>>   				sctp_primitive_ABORT(net, asoc, chunk);
>> +			} else {
>> +				sctp_unhash_established(asoc);
>> +				sctp_association_free(asoc);
>> +			}
>
> I don't think you can do that for an association that has not been closed.
>
> I think a cleaner approach might be to update abort primitive handlers
> to handle a NULL chunk value and unconditionally call the primitive.
>
> This guarantees that any timers or waitqueues that might be active are
> stopped correctly.

sctp_association_free() is the one who does that job, even that way. All 
in between the primitive call and then the call to 
sctp_association_free() is just status changes and packet xmit, which 
doing this way we cut out when we are in memory pressure. pkt xmit or 
ULP events are likely going to fail too anyway.

sctp_sf_do_9_1_prm_abort() -> SCTP_CMD_ASSOC_FAILED ->
   sctp_cmd_assoc_failed -> ULP events, send abort, and 
SCTP_CMD_DELETE_TCB ->
     sctp_cmd_delete_tcb ->
       sctp_unhash_established(asoc);
       sctp_association_free(asoc);
and returns.

There is a check on sctp_cmd_delete_tcb() that avoids calling that on 
temp assocs on listening sockets, but that condition is false due to the 
check on sk_shutdown so it will call those two functions anyway.

   Marcelo
