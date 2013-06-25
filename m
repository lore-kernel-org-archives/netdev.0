From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 5/6] net: sctp: decouple cleaning some socket
 data from endpoint
Date: Tue, 25 Jun 2013 17:38:46 +0200
Message-ID: <51C9B986.2030104@redhat.com>
References: <1372173221-15244-1-git-send-email-dborkman@redhat.com> <1372173221-15244-6-git-send-email-dborkman@redhat.com> <51C9B80C.6070905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab3FYPiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 11:38:50 -0400
In-Reply-To: <51C9B80C.6070905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 05:32 PM, Vlad Yasevich wrote:
> On 06/25/2013 11:13 AM, Daniel Borkmann wrote:
>> Rather instead of having the endpoint clean the garbage from the
>> socket, use a sk_destruct handler sctp_destruct_sock(), that does
>> the job for that when there are no more references on the socket.
>> At least do this for our crypto transform through crypto_free_hash()
>> that is allocated when in listening state. Also, for now, move the
>> sctp_put_port() into the sk if body.
>
> This sentence is hard to parse without looking at the patch.  Can
> you rephrase.  May be say that we perform sctp_put_port() only when
> sk is valid.
>
>> At a later point in time we
>> can still determine if there's an option of placing this into
>> unhash() or sctp_endpoint_free() without any races. For now, leave
>> it in sctp_endpoint_destroy() though.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/sctp/endpointola.c | 18 +++++++++---------
>>   net/sctp/socket.c      | 16 +++++++++++++++-
>>   2 files changed, 24 insertions(+), 10 deletions(-)
>>
>> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
>> index a8b2674..8ad7781 100644
>> --- a/net/sctp/endpointola.c
>> +++ b/net/sctp/endpointola.c
>> @@ -247,10 +247,9 @@ void sctp_endpoint_free(struct sctp_endpoint *ep)
>>   /* Final destructor for endpoint.  */
>>   static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>>   {
>> -    SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
>> +    struct sock *sk;
>>
>> -    /* Free up the HMAC transform. */
>> -    crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
>> +    SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
>>
>>       /* Free the digest buffer */
>>       kfree(ep->digest);
>> @@ -271,13 +270,14 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>>
>>       memset(ep->secret_key, 0, sizeof(ep->secret_key));
>>
>> -    /* Remove and free the port */
>> -    if (sctp_sk(ep->base.sk)->bind_hash)
>> -        sctp_put_port(ep->base.sk);
>> -
>>       /* Give up our hold on the sock. */
>> -    if (ep->base.sk)
>> -        sock_put(ep->base.sk);
>> +    if ((sk = ep->base.sk)) {
>
> Can you either split the above into separate assignment and test (this is what checkpatchs.pl recommends) or at least comment that you mean to do assign and test in the above statement.

Ok, sure, I can make this separate and rephrase the above sentence for the log.

Thanks,

Daniel
