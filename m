From: Jeff Liu <jeff.liu@oracle.com>
Subject: Re: [rds-devel] [patch] RDS: fix an integer overflow check
Date: Sat, 13 Oct 2012 21:45:53 +0800
Message-ID: <50797091.800@oracle.com>
References: <20121012073146.GA9543@elgon.mountain> <50796BD4.4000608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:31276 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab2JMNqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 09:46:07 -0400
In-Reply-To: <50796BD4.4000608@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2012 09:25 PM, Jeff Liu wrote:
> On 10/12/2012 03:31 PM, Dan Carpenter wrote:
>> "len" is an int.  We verified that len was postive already.  Since
>> PAGE_SIZE is specified as an unsigned long, the type it promoted to
>> unsigned and the condition is never true.
>>
>> I'm not sure this check is actually needed.  It might be that we could
>> just remove it?
>>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>
>> diff --git a/net/rds/info.c b/net/rds/info.c
>> index 9a6b4f6..4d62618 100644
>> --- a/net/rds/info.c
>> +++ b/net/rds/info.c
>> @@ -176,7 +176,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
>>    
>>    	/* check for all kinds of wrapping and the like */
>>    	start = (unsigned long)optval;
>> -	if (len < 0 || len + PAGE_SIZE - 1 < len || start + len < start) {
> Looks the original thought is to check up len + (PAGE_SIZE - 1) < len to
> avoid integer overflow, but lack of a "()".
>
> However, we only have one add operation in this function which were
> shown as following:
>           nr_pages = (PAGE_ALIGN(start + len) - (start & PAGE_MASK))
>                           >> PAGE_SHIFT;
>
> I also gone through the call chains, there is no other (start + len)
Sorry, here is a typo.  "start + len" is already well-checked.
Actually, I means there is no other "len + (PAGE_SIZE - 1)" operations.

Thanks,
-Jeff
> operations for all transport, I think it's safe to remove this check up
> if so.
>
> Thanks,
> -Jeff
>> +	if (len < 0 || len > INT_MAX - (PAGE_SIZE - 1) || start + len < start) {
>>    		ret = -EINVAL;
>>    		goto out;
>>    	}
>> --
>> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> _______________________________________________
> rds-devel mailing list
> rds-devel@oss.oracle.com
> https://oss.oracle.com/mailman/listinfo/rds-devel
