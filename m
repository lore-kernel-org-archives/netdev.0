From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4 - rev 2] Initilize and populate age field
Date: Tue, 21 Aug 2007 16:52:35 +0530
Message-ID: <46CACAFB.8050709@linux.vnet.ibm.com>
References: <20070820134617.1226c97b.varunc@linux.vnet.ibm.com> <20070821105542.GN32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45684 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922AbXHULWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 07:22:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LBM1gf025321
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 07:22:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LBM1Cf433704
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 07:22:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LBLxsG021914
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 07:22:00 -0400
In-Reply-To: <20070821105542.GN32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Varun Chandramohan <varunc@linux.vnet.ibm.com> 2007-08-20 13:46
>   
>> The age field is filled with the current time at the time of creation of the route. When the routes are dumped
>> then the age value stored in the route structure is subtracted from the current time value and the difference is the age expressed in secs.
>>
>> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
>> @@ -985,6 +987,14 @@ int fib_dump_info(struct sk_buff *skb, u
>>  			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
>>  #endif
>>  	}
>> +
>> +	do_gettimeofday(&tv);
>> +	if (!*age) {
>> +		*age = timeval_to_sec(&tv);
>> +		NLA_PUT_U32(skb, RTA_AGE, *age);
>>     
>
> Why don't you take the timestamp at the time of allocating the alias?
> This time-since-first-dump is very confusing.
>
>   
I know its a bit confusing but let me explain the reason. In my first
version patch i used fn_hash_insert() (place where alias is created)as
place to insert my current time in the age field.
This will eventually call fib_dump_info() for inserting the age filed
attribute into the skb. Now in both places i have to call
do_gettimeofday(). Its obvious that i need it in fn_hash_insert(), its
also need in fib_dump_info() as it is the same function called for
retrieving and dumping the age value to the userspace. So as you are
aware that before we dump it to userspace we need to subtract the value
with current time i need to call do_gettimeofday() twice. To avoid this
i did as above.
>> +	} else {
>> +		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
>> +	}
>>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>>  	if (fi->fib_nhs > 1) {
>>  		struct rtnexthop *rtnh;
>>     
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
Regards,
Varun
