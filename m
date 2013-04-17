From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/9] net: sctp: sctp_ssnmap: remove 'malloced'
 element from struct
Date: Wed, 17 Apr 2013 14:52:34 +0200
Message-ID: <516E9B12.3040300@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com> <1366146438-8815-2-git-send-email-dborkman@redhat.com> <20130417124539.GA5149@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966116Ab3DQMwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 08:52:43 -0400
In-Reply-To: <20130417124539.GA5149@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 02:45 PM, Neil Horman wrote:
> On Tue, Apr 16, 2013 at 11:07:10PM +0200, Daniel Borkmann wrote:
>> sctp_ssnmap_init() can only be called from sctp_ssnmap_new()
>> where malloced is always set to 1. Thus, when we call
>> sctp_ssnmap_free() the test for map->malloced evaluates always
>> to true.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   include/net/sctp/structs.h |  1 -
>>   net/sctp/ssnmap.c          | 23 ++++++++++++-----------
>>   2 files changed, 12 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
>> index e12aa77..3c1bb8d 100644
>> --- a/include/net/sctp/structs.h
>> +++ b/include/net/sctp/structs.h
>> @@ -399,7 +399,6 @@ struct sctp_stream {
>>   struct sctp_ssnmap {
>>   	struct sctp_stream in;
>>   	struct sctp_stream out;
>> -	int malloced;
>>   };
>>
>>   struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
>> diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
>> index 825ea94..da86035 100644
>> --- a/net/sctp/ssnmap.c
>> +++ b/net/sctp/ssnmap.c
>> @@ -74,7 +74,6 @@ struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
>>   	if (!sctp_ssnmap_init(retval, in, out))
>>   		goto fail_map;
>>
>> -	retval->malloced = 1;
>>   	SCTP_DBG_OBJCNT_INC(ssnmap);
>>
>>   	return retval;
>> @@ -118,14 +117,16 @@ void sctp_ssnmap_clear(struct sctp_ssnmap *map)
>>   /* Dispose of a ssnmap.  */
>>   void sctp_ssnmap_free(struct sctp_ssnmap *map)
>>   {
>> -	if (map && map->malloced) {
>> -		int size;
>> -
>> -		size = sctp_ssnmap_size(map->in.len, map->out.len);
>> -		if (size <= KMALLOC_MAX_SIZE)
>> -			kfree(map);
>> -		else
>> -			free_pages((unsigned long)map, get_order(size));
>> -		SCTP_DBG_OBJCNT_DEC(ssnmap);
>> -	}
>> +	int size;
>> +
>> +	if (unlikely(!map))
>> +		return;
>> +
>> +	size = sctp_ssnmap_size(map->in.len, map->out.len);
>> +	if (size <= KMALLOC_MAX_SIZE)
>> +		kfree(map);
>> +	else
>> +		free_pages((unsigned long)map, get_order(size));
>> +
>> +	SCTP_DBG_OBJCNT_DEC(ssnmap);
>>   }
>> --
>> 1.7.11.7
>>
> I definately like what you're doing here, as the use of the ->malloced member
> always struck me as a half-assed way to try and avoid a double free that someone
> couldn't track down during this code's initial development.  That said, I'm
> wondering if the !map check is going to fail at some point, given that the call
> site for sctp_ssnmap_free never sets asoc->ssnmap to NULL after its call.  Maybe
> worthwhile adding such a NULL assoginment to the call site to ensure that we
> don't accidentally trigger a double free?

I'll test that with lksctp-tools suite and come back to you today.

Thanks,
Daniel
