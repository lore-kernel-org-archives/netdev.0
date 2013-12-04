From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v3] sctp: check the rto_min and rto_max
Date: Wed, 4 Dec 2013 10:46:58 +0800
Message-ID: <529E97A2.4020003@huawei.com>
References: <529BE620.8090004@huawei.com> <529C9D13.10107@gmail.com> <529D3ABB.8040908@huawei.com> <529D7A0F.50201@huawei.com> <529DD113.6070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:20633 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359Ab3LDCr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 21:47:59 -0500
In-Reply-To: <529DD113.6070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/3 20:39, Vlad Yasevich wrote:
> On 12/03/2013 01:28 AM, Wang Weidong wrote:
>> rto_min should be smaller than rto_max while rto_max should be larger
>> than rto_min. Add two proc_handler for the checking. Add the check in
>> sctp_setsockopt_rtoinfo.
>>
>> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/sctp/socket.c |  5 +++++
>>  net/sctp/sysctl.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>>  2 files changed, 56 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 72046b9..2e1af1b 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
>>  	if (copy_from_user(&rtoinfo, optval, optlen))
>>  		return -EFAULT;
>>  
>> +	if (rtoinfo.srto_min < 1 ||
>> +	    rtoinfo.srto_max > 86400000 ||
>> +	    rtoinfo.srto_max < rtoinfo.srto_min)
>> +		return -EINVAL;
>> +
>>  	asoc = sctp_id2assoc(sk, rtoinfo.srto_assoc_id);
>>  
>>  	/* Set the values to the specific association */
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index 6b36561..525b06d 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -59,8 +59,16 @@ extern int sysctl_sctp_wmem[3];
>>  static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>  				int write,
>>  				void __user *buffer, size_t *lenp,
>> -
>>  				loff_t *ppos);
>> +static int proc_sctp_check_rtomin(struct ctl_table *ctl,
>> +				int write,
>> +				void __user *buffer, size_t *lenp,
>> +				loff_t *ppos);
>> +static int proc_sctp_check_rtomax(struct ctl_table *ctl,
>> +				int write,
>> +				void __user *buffer, size_t *lenp,
>> +				loff_t *ppos);
>> +
>>  static struct ctl_table sctp_table[] = {
>>  	{
>>  		.procname	= "sctp_mem",
>> @@ -102,18 +110,14 @@ static struct ctl_table sctp_net_table[] = {
>>  		.data		= &init_net.sctp.rto_min,
>>  		.maxlen		= sizeof(unsigned int),
>>  		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec_minmax,
>> -		.extra1         = &one,
>> -		.extra2         = &timer_max
>> +		.proc_handler	= proc_sctp_check_rtomin,
>>  	},
>>  	{
>>  		.procname	= "rto_max",
>>  		.data		= &init_net.sctp.rto_max,
>>  		.maxlen		= sizeof(unsigned int),
>>  		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec_minmax,
>> -		.extra1         = &one,
>> -		.extra2         = &timer_max
>> +		.proc_handler	= proc_sctp_check_rtomax,
>>  	},
>>  	{
>>  		.procname	= "rto_alpha_exp_divisor",
>> @@ -342,6 +346,46 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>  	return ret;
>>  }
>>  
>> +static int proc_sctp_check_rtomin(struct ctl_table *ctl,
>> +				int write,
>> +				void __user *buffer, size_t *lenp,
>> +				loff_t *ppos)
>> +{
>> +	int old_value = *(int *) ctl->data;
>> +	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
>> +
>> +	if (write) {
>> +		int new_value = *(int *) ctl->data;
>> +		if (ret || new_value < one || new_value > init_net.sctp.rto_max) {
>> +			init_net.sctp.rto_min = old_value;
>> +			return -EINVAL;
>> +		}
>> +		init_net.sctp.rto_min = new_value;
>> +	}
>> +
>> +	return ret;
>> +}
>> +
>> +static int proc_sctp_check_rtomax(struct ctl_table *ctl,
>> +				int write,
>> +				void __user*buffer, size_t *lenp,
>> +				loff_t *ppos)
>> +{
>> +	int old_value = *(int *) ctl->data;
>> +	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
>> +
>> +	if (write) {
>> +		int new_value = *(int *) ctl->data;
>> +		if (ret || new_value > timer_max || new_value < init_net.sctp.rto_min) {
>> +			init_net.sctp.rto_max = old_value;
>> +			return -EINVAL;
>> +		}
>> +		init_net.sctp.rto_max = new_value;
>> +	}
>> +
>> +	return ret;
>> +}
>> +
> 
> 
> You can't used init_net directly.  You have to use .data as the target
> of assignment and .extra1 and .extra2 as the min and max boundries.
> Otherwise, this has the same problem as before where assignments for
> created namespace try to change the values in the initial namespace.
> 
> -vlad

Hi, Vlad

Do You mean like below?

For rto_max:
	.procname	= "rto_max",
	.data		= &init_net.sctp.rto_max,
	.maxlen		= sizeof(unsigned int),
	.mode		= 0644,
	.proc_handler	= &proc_sctp_check_rtomax,
	.extra1         = &init_net.sctp.rto_min,
	.extra2         = &timer_max

proc_sctp_check_rtomax()
        *net = current->nsproxy->net_ns;
        min = *(unsigned int *) ctl->extra1;
        max = *(unsigned int *) ctl->extra2;
	if (write)
		tbl.data = &new_value;
	else
		tbl.data = &net->sctp.rto_max;
	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
	if (write) {
		if (ret || new_value > max || new_value < min) {
			return -EINVAL;
		}
		net->sctp.rto_max = new_value;
	}

and as the same as rto_min.
Thanks!

>>  int sctp_sysctl_net_register(struct net *net)
>>  {
>>  	struct ctl_table *table;
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
