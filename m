From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v5 1/2] sctp: check the rto_min and rto_max
Date: Mon, 9 Dec 2013 10:28:25 +0800
Message-ID: <52A52AC9.6050907@huawei.com>
References: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com> <1386400651-21744-2-git-send-email-wangweidong1@huawei.com> <52A36EE1.4010209@gmail.com> <52A522A3.7010201@huawei.com> <52A52894.6060600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:39799 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566Ab3LICbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 21:31:33 -0500
In-Reply-To: <52A52894.6060600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/9 10:19, Vlad Yasevich wrote:
> On 12/08/2013 08:53 PM, Wang Weidong wrote:
>> On 2013/12/8 2:54, Vlad Yasevich wrote:
>>> On 12/07/2013 02:17 AM, Wang Weidong wrote:
>>>> rto_min should be smaller than rto_max while rto_max should be larger
>>>> than rto_min. Add two proc_handler for the checking. Add the check in
>>>> sctp_setsockopt_rtoinfo.
>>>>
>>>> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
>>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>>> ---
>>>>  include/net/sctp/constants.h |  3 ++
>>>>  net/sctp/socket.c            |  5 +++
>>>>  net/sctp/sysctl.c            | 73 ++++++++++++++++++++++++++++++++++++++++----
>>>>  3 files changed, 75 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
>>>> index 2f0a565..d276978 100644
>>>> --- a/include/net/sctp/constants.h
>>>> +++ b/include/net/sctp/constants.h
>>>> @@ -279,6 +279,9 @@ enum { SCTP_MAX_GABS = 16 };
>>>>  #define SCTP_RTO_ALPHA          3   /* 1/8 when converted to right shifts. */
>>>>  #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
>>>>  
>>>> +#define SCTP_ONE                1        /* 1 ms */
>>>> +#define SCTP_TIMER_MAX          86400000 /* ms in one day */
>>>> +
>>>>  /* Maximum number of new data packets that can be sent in a burst.  */
>>>>  #define SCTP_DEFAULT_MAX_BURST		4
>>>>  
>>>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>>>> index 72046b9..13411ad 100644
>>>> --- a/net/sctp/socket.c
>>>> +++ b/net/sctp/socket.c
>>>> @@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
>>>>  	if (copy_from_user(&rtoinfo, optval, optlen))
>>>>  		return -EFAULT;
>>>>  
>>>> +	if (rtoinfo.srto_min < SCTP_ONE ||
>>>> +	    rtoinfo.srto_max > SCTP_TIMER_MAX ||
>>>> +	    rtoinfo.srto_max < rtoinfo.srto_min)
>>>> +		return -EINVAL;
>>>> +
>>>
>>> You can not do the check for srto_min < 1.  The following is the text
>>> from the spec:
>>>    All times are given in milliseconds.  A value of 0, when modifying
>>>    the parameters, indicates that the current value should not be
>>>    changed.
>>>
>> Yes, Your are right, I found it in draft-ietf-tsvwg-sctpsocket-14.txt.
>> Thanks.
>>
>>> So, it is valid for a user to pass in a value of 0.  Also, I am not sure
>>> if it makes sense to bind the upper limit here, as well.
>>>
>>> -vlad
>>>
>> Here, I am not sure as well. I think it should like what we do to the
>> init_net.sctp.rto_max when set larger than timer_max. Just not change the value.
>>
> 
> So, the basic reason that sysctl is limited is that it is a default
> for all sctp association on the system.  It makes some sense to limit
> what the max value here could be.  Limiting it to double suggested
> RTO.MAX would only make it 2 minutes and may be insufficient for some
> of the high latency low-throughput wireless links.  Making it about an
> hour should be fine...  This would be a separate patch though...
> 
Here, you mean that we should use 3600*1000 rather than 86400000? So
we should use another patch to fix that after my patchs?

> Limiting the user-supplied value is not as appropriate since the
> assumption is that user application may know better what it's
> requirements are and it is not up to the stack to limit those.  As
> long as the user value is withing the usable range (and the kernel
> will already knows how and does limit this range), we should not
> limit this further.
> 
> -vlad
> 
Agree, So I should check like this:
!srto_min || !srto_max || srto_min > srto_max ?
And no need to add macros for checking.

Thanks.

>>
>> Regards.
>> Wang
>>
>>>>  	asoc = sctp_id2assoc(sk, rtoinfo.srto_assoc_id);
>>>>  
>>>>  	/* Set the values to the specific association */
>>>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>>>> index 6b36561..33c56c6 100644
>>>> --- a/net/sctp/sysctl.c
>>>> +++ b/net/sctp/sysctl.c
>>>> @@ -40,8 +40,8 @@
>>>>  #include <linux/sysctl.h>
>>>>  
>>>>  static int zero = 0;
>>>> -static int one = 1;
>>>> -static int timer_max = 86400000; /* ms in one day */
>>>> +static int one = SCTP_ONE;
>>>> +static int timer_max = SCTP_TIMER_MAX;
>>>>  static int int_max = INT_MAX;
>>>>  static int sack_timer_min = 1;
>>>>  static int sack_timer_max = 500;
>>>> @@ -61,6 +61,13 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>>>  				void __user *buffer, size_t *lenp,
>>>>  
>>>>  				loff_t *ppos);
>>>> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
>>>> +				void __user *buffer, size_t *lenp,
>>>> +				loff_t *ppos);
>>>> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>>>> +				void __user *buffer, size_t *lenp,
>>>> +				loff_t *ppos);
>>>> +
>>>>  static struct ctl_table sctp_table[] = {
>>>>  	{
>>>>  		.procname	= "sctp_mem",
>>>> @@ -102,17 +109,17 @@ static struct ctl_table sctp_net_table[] = {
>>>>  		.data		= &init_net.sctp.rto_min,
>>>>  		.maxlen		= sizeof(unsigned int),
>>>>  		.mode		= 0644,
>>>> -		.proc_handler	= proc_dointvec_minmax,
>>>> +		.proc_handler	= proc_sctp_do_rto_min,
>>>>  		.extra1         = &one,
>>>> -		.extra2         = &timer_max
>>>> +		.extra2         = &init_net.sctp.rto_max
>>>>  	},
>>>>  	{
>>>>  		.procname	= "rto_max",
>>>>  		.data		= &init_net.sctp.rto_max,
>>>>  		.maxlen		= sizeof(unsigned int),
>>>>  		.mode		= 0644,
>>>> -		.proc_handler	= proc_dointvec_minmax,
>>>> -		.extra1         = &one,
>>>> +		.proc_handler	= proc_sctp_do_rto_max,
>>>> +		.extra1         = &init_net.sctp.rto_min,
>>>>  		.extra2         = &timer_max
>>>>  	},
>>>>  	{
>>>> @@ -342,6 +349,60 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>>>  	return ret;
>>>>  }
>>>>  
>>>> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
>>>> +				void __user*buffer, size_t *lenp,
>>>> +				loff_t *ppos)
>>>> +{
>>>> +	struct net *net = current->nsproxy->net_ns;
>>>> +	int new_value;
>>>> +	struct ctl_table tbl;
>>>> +	unsigned int min = *(unsigned int *) ctl->extra1;
>>>> +	unsigned int max = *(unsigned int *) ctl->extra2;
>>>> +	int ret;
>>>> +
>>>> +	memset(&tbl, 0, sizeof(struct ctl_table));
>>>> +	tbl.maxlen = sizeof(unsigned int);
>>>> +
>>>> +	if (write)
>>>> +		tbl.data = &new_value;
>>>> +	else
>>>> +		tbl.data = &net->sctp.rto_min;
>>>> +	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
>>>> +	if (write) {
>>>> +		if (ret || new_value > max || new_value < min)
>>>> +			return -EINVAL;
>>>> +		net->sctp.rto_min = new_value;
>>>> +	}
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>>>> +				void __user*buffer, size_t *lenp,
>>>> +				loff_t *ppos)
>>>> +{
>>>> +	struct net *net = current->nsproxy->net_ns;
>>>> +	int new_value;
>>>> +	struct ctl_table tbl;
>>>> +	unsigned int min = *(unsigned int *) ctl->extra1;
>>>> +	unsigned int max = *(unsigned int *) ctl->extra2;
>>>> +	int ret;
>>>> +
>>>> +	memset(&tbl, 0, sizeof(struct ctl_table));
>>>> +	tbl.maxlen = sizeof(unsigned int);
>>>> +
>>>> +	if (write)
>>>> +		tbl.data = &new_value;
>>>> +	else
>>>> +		tbl.data = &net->sctp.rto_max;
>>>> +	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
>>>> +	if (write) {
>>>> +                if (ret || new_value > max || new_value < min)
>>>> +			return -EINVAL;
>>>> +		net->sctp.rto_max = new_value;
>>>> +	}
>>>> +	return ret;
>>>> +}
>>>> +
>>>>  int sctp_sysctl_net_register(struct net *net)
>>>>  {
>>>>  	struct ctl_table *table;
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> .
>>>
>>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
