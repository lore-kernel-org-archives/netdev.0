From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC v2 PATCH 1/2] SCTP: Add RCU synchronization around	sctp_localaddr_list
Date: Thu, 13 Sep 2007 09:46:24 -0400
Message-ID: <46E93F30.5040909@hp.com>
References: <11896263983281-git-send-email-vladislav.yasevich@hp.com>	 <11896263982464-git-send-email-vladislav.yasevich@hp.com> <1189638236.27182.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:44841 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378AbXIMNqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 09:46:36 -0400
In-Reply-To: <1189638236.27182.12.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sridhar

Sridhar Samudrala wrote:
> Vlad,
> 
> few minor comments inline.
> otherwise, looks good.
> 
> Thanks
> Sridhar
> 
>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>> index f8aa23d..54ff472 100644
>> --- a/net/sctp/ipv6.c
>> +++ b/net/sctp/ipv6.c
>> @@ -77,13 +77,18 @@
>>
>>  #include <asm/uaccess.h>
>>
>> -/* Event handler for inet6 address addition/deletion events.  */
>> +/* Event handler for inet6 address addition/deletion events.
>> + * This even is part of the atomic notifier call chain
>> + * and thus happens atomically and can NOT sleep.  As a result
>> + * we can't and really don't need to add any locks to guard the
>> + * RCU.
>> + */
> 
> Now that we are adding a spin_lock, the above comment is not valid.
> It should be fixed saying that we still need a lock because we use the 
> same list for both inet and inet6 address events and they can happen in
> parallel.

Yes, I forgot to fix this comment.  Will do.


>> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
>> index e98579b..4688559 100644
>> --- a/net/sctp/protocol.c
>> +++ b/net/sctp/protocol.c
>> @@ -153,6 +153,8 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
>>  			addr->a.v4.sin_family = AF_INET;
>>  			addr->a.v4.sin_port = 0;
>>  			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
>> +			addr->valid = 1;
>> +			INIT_RCU_HEAD(&addr->rcu);
> 
> This has nothing to do with this patch, but i noticed that
> INIT_LIST_HEAD(&addr->list) is missing here when comparing with
> earlier v6 version of this routine.

Hmm...  I thought it looked a little different, but didn't pay too much
attention to it.  I'll add a follow-on patch to fix this.

Thanks
-vlad
