From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Tue, 12 Feb 2008 08:57:14 +0000
Message-ID: <20080212085714.GB2582@ff.dom.local>
References: <20080211.171645.74019568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, paulmck@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:49831 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504AbYBLIuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 03:50:02 -0500
Received: by ug-out-1314.google.com with SMTP id z38so446070ugc.16
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 00:50:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080211.171645.74019568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-02-2008 02:16, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 11 Feb 2008 16:59:54 -0800
> 
> linux-kernel added to CC:, any change to generic kernel infrastructure
> should be posted there
> 
>> Eliminate warnings when rcu_assign_pointer is used with unsigned long.
>> It is reasonable to use RCU with non-pointer values so allow it for general
>> use.  Add a comment to explain the if test.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> ---
>>  include/linux/rcupdate.h |   13 +++++++------
>>  1 files changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
>> index 37a642c..c44ac87 100644
>> --- a/include/linux/rcupdate.h
>> +++ b/include/linux/rcupdate.h
>> @@ -172,14 +172,15 @@ struct rcu_head {
>>   * structure after the pointer assignment.  More importantly, this
>>   * call documents which pointers will be dereferenced by RCU read-side
>>   * code.
>> + *
>> + * If value is the NULL (constant 0), then no barrier is needed.
>>   */
>>  
>> -#define rcu_assign_pointer(p, v) \
>> -	({ \
>> -		if (!__builtin_constant_p(v) || \
>> -		    ((v) != NULL)) \
>> -			smp_wmb(); \
>> -		(p) = (v); \
>> +#define rcu_assign_pointer(p, v)			\
>> +	({						\
>> +		if (!(__builtin_constant_p(v) && v))	\

...But, "If value is the NULL (constant 0)" we have:

if (!(1 && NULL != 0)) ==> if (!(0)) and the barrier is used?!

>> +			smp_wmb();			\
>> +		(p) = (v);				\
>>  	})
>>  
>>  /**


Regards,
Jarek P.
