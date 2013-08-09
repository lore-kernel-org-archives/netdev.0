From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: sctp_transport_destroy{,_rcu}: fix
 potential pointer corruption
Date: Fri, 09 Aug 2013 15:59:15 +0200
Message-ID: <5204F5B3.7020800@redhat.com>
References: <1376054842-376-1-git-send-email-dborkman@redhat.com> <5204F55B.2040704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568Ab3HIN7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 09:59:22 -0400
In-Reply-To: <5204F55B.2040704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 03:57 PM, Vlad Yasevich wrote:
> On 08/09/2013 09:27 AM, Daniel Borkmann wrote:
>> Probably this one is quite unlikely to be triggered, but it's more safe
>> to hold a pointer to asoc (instead of dereferencing), free the packet
>> chunks first, and access asoc though the pointer after we have called
>> sctp_transport_destroy_rcu() where the transport is being kfree()'d.
>> Introduced by commit 8c98653f ("sctp: sctp_close: fix release of bindings
>> for deferred call_rcu's"). I also did the 8c98653f regression test and
>> it's fine that way.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   v1->v2: do sctp_packet_free before call_rcu
>>
>>   net/sctp/transport.c | 10 ++++++----
>>   1 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
>> index bdbbc3f..c691455 100644
>> --- a/net/sctp/transport.c
>> +++ b/net/sctp/transport.c
>> @@ -176,17 +176,19 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
>>    */
>>   static void sctp_transport_destroy(struct sctp_transport *transport)
>>   {
>> +    struct sctp_association *asoc = transport->asoc;
>> +
>>       if (unlikely(!transport->dead)) {
>>           WARN(1, "Attempt to destroy undead transport %p!\n", transport);
>>           return;
>>       }
>>
>> -    call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
>> -
>>       sctp_packet_free(&transport->packet);
>>
>> -    if (transport->asoc)
>> -        sctp_association_put(transport->asoc);
>> +    call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
>> +
>> +    if (asoc != NULL)
>> +        sctp_association_put(asoc);
>
> I think it is safe to move call_rcu to be the last call in this function. This should never be a last ref on the association.  If
> by some chance it is, we'll get the same warning.
>
> And if you move call_rcu(), this becomes an ever smaller patch :)

Ok, that's also a way to go. Will send v3. :-)

> -vlad
>>   }
>>
>>   /* Start T3_rtx timer if it is not already running and update the heartbeat
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
