From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH v5 1/2] sctp: check the rto_min and rto_max
Date: Sat, 07 Dec 2013 21:13:32 +0800
Message-ID: <52A31EFC.4080805@gmail.com>
References: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com> <1386400651-21744-2-git-send-email-wangweidong1@huawei.com> <52A31805.8020305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>,
	Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:51866 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab3LGNNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 08:13:23 -0500
In-Reply-To: <52A31805.8020305@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From Wang Weidong <wangweidong1@huawei.com>

On 2013/12/7 20:43, Daniel Borkmann wrote:
> On 12/07/2013 08:17 AM, Wang Weidong wrote:
>> rto_min should be smaller than rto_max while rto_max should be larger
>> than rto_min. Add two proc_handler for the checking. Add the check in
>> sctp_setsockopt_rtoinfo.
>>
>> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>
> Thanks Wang, also for your second patch.
>
> Second one looks good to me, thanks for the cleanup!
>
> I was wondering where 86400000 comes from? Looking through the git
> history didn't give much clues and the RFC4960 neither. Clearly,
> section 15 of RFC4960 *recommends* as initial values ...
>
>    RTO.Initial - 3 seconds
>    RTO.Min - 1 second
>    RTO.Max - 60 seconds
>
> ... which we have as constants in [1] and are assigned to globals
> initially in [2,3] with those recommended values. That's all good.
>
> But still [not *directly* related to your patch though], where does
> 86400000 come from? I expect that's for the max SCTP heartbeat
> interval or max cookie lifetime?
>
Sorry, I don't know 86400000 come form as well.

> Hence, timer_max is used in multiple contexts for timers here,
> which seems a bit confusing. If it really makes sense to have such
> a huge RTO max though, then it at least needs a comment explaining
> so. ;)
>
> Wang, just a minor nitpick, I would much rather name them those
> defines like ...
>
>    SCTP_RTO_MIN_LIMIT
>    SCTP_RTO_MAX_LIMIT
>
> ... just so that we have recommended and upper limit constants with
> a more clear naming as obviously SCTP_ONE doesn't make much sense.
>
>   [1] include/net/sctp/constants.h +269
>   [2] include/net/netns/sctp.h +39
>   [3] net/sctp/protocol.c +1169
>
> More below ...
>
>>   include/net/sctp/constants.h |  3 ++
>>   net/sctp/socket.c            |  5 +++
>>   net/sctp/sysctl.c            | 73 ++++++++++++++++++++++++++++++++++++++++----
>>   3 files changed, 75 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
>> index 2f0a565..d276978 100644
>> --- a/include/net/sctp/constants.h
>> +++ b/include/net/sctp/constants.h
>> @@ -279,6 +279,9 @@ enum { SCTP_MAX_GABS = 16 };
>>   #define SCTP_RTO_ALPHA          3   /* 1/8 when converted to right shifts. */
>>   #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
>>
>> +#define SCTP_ONE                1        /* 1 ms */
>> +#define SCTP_TIMER_MAX          86400000 /* ms in one day */
>> +
>>   /* Maximum number of new data packets that can be sent in a burst.  */
>>   #define SCTP_DEFAULT_MAX_BURST        4
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 72046b9..13411ad 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
>>       if (copy_from_user(&rtoinfo, optval, optlen))
>>           return -EFAULT;
>>
>> +    if (rtoinfo.srto_min < SCTP_ONE ||
>> +        rtoinfo.srto_max > SCTP_TIMER_MAX ||
>> +        rtoinfo.srto_max < rtoinfo.srto_min)
>> +        return -EINVAL;
>> +
>>       asoc = sctp_id2assoc(sk, rtoinfo.srto_assoc_id);
>>
>>       /* Set the values to the specific association */
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index 6b36561..33c56c6 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -40,8 +40,8 @@
>>   #include <linux/sysctl.h>
>>
>>   static int zero = 0;
>> -static int one = 1;
>> -static int timer_max = 86400000; /* ms in one day */
>> +static int one = SCTP_ONE;
>> +static int timer_max = SCTP_TIMER_MAX;
>
> So here, I'd do something like this ...
>
> static int one = 1;              (leaving this as is)
> static int timer_max = 86400000; /* Max 1 day for HB interval, cookie life-time*/
>
> static int rto_timer_min = SCTP_RTO_MIN_LIMIT;
> static int rto_timer_max = SCTP_RTO_MAX_LIMIT;
>
> ... so that we have sack_timer_{min,max} and rto_timer_{min,max}.
>
> Opinions, thoughts?
>
Agree. Your Opinions is very good.

Thanks a lot, you help me so much.  I think I should wait for the
explanation of the 86400000, then send the v6.

Regards.
Wang

>>   static int int_max = INT_MAX;
>>   static int sack_timer_min = 1;
>>   static int sack_timer_max = 500;
>> @@ -61,6 +61,13 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>                   void __user *buffer, size_t *lenp,
>>
>>                   loff_t *ppos);
>> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
>> +                void __user *buffer, size_t *lenp,
>> +                loff_t *ppos);
>> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>> +                void __user *buffer, size_t *lenp,
>> +                loff_t *ppos);
>> +
>>   static struct ctl_table sctp_table[] = {
>>       {
>>           .procname    = "sctp_mem",
>> @@ -102,17 +109,17 @@ static struct ctl_table sctp_net_table[] = {
>>           .data        = &init_net.sctp.rto_min,
>>           .maxlen        = sizeof(unsigned int),
>>           .mode        = 0644,
>> -        .proc_handler    = proc_dointvec_minmax,
>> +        .proc_handler    = proc_sctp_do_rto_min,
>>           .extra1         = &one,
>> -        .extra2         = &timer_max
>> +        .extra2         = &init_net.sctp.rto_max
>>       },
>>       {
>>           .procname    = "rto_max",
>>           .data        = &init_net.sctp.rto_max,
>>           .maxlen        = sizeof(unsigned int),
>>           .mode        = 0644,
>> -        .proc_handler    = proc_dointvec_minmax,
>> -        .extra1         = &one,
>> +        .proc_handler    = proc_sctp_do_rto_max,
>> +        .extra1         = &init_net.sctp.rto_min,
>>           .extra2         = &timer_max
>>       },
>>       {
>> @@ -342,6 +349,60 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
>>       return ret;
>>   }
>>
>> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
>> +                void __user*buffer, size_t *lenp,
>> +                loff_t *ppos)
>> +{
>> +    struct net *net = current->nsproxy->net_ns;
>> +    int new_value;
>> +    struct ctl_table tbl;
>> +    unsigned int min = *(unsigned int *) ctl->extra1;
>> +    unsigned int max = *(unsigned int *) ctl->extra2;
>> +    int ret;
>> +
>> +    memset(&tbl, 0, sizeof(struct ctl_table));
>> +    tbl.maxlen = sizeof(unsigned int);
>> +
>> +    if (write)
>> +        tbl.data = &new_value;
>> +    else
>> +        tbl.data = &net->sctp.rto_min;
>> +    ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
>> +    if (write) {
>> +        if (ret || new_value > max || new_value < min)
>> +            return -EINVAL;
>> +        net->sctp.rto_min = new_value;
>> +    }
>> +    return ret;
>> +}
>> +
>> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>> +                void __user*buffer, size_t *lenp,
>> +                loff_t *ppos)
>> +{
>> +    struct net *net = current->nsproxy->net_ns;
>> +    int new_value;
>> +    struct ctl_table tbl;
>> +    unsigned int min = *(unsigned int *) ctl->extra1;
>> +    unsigned int max = *(unsigned int *) ctl->extra2;
>> +    int ret;
>> +
>> +    memset(&tbl, 0, sizeof(struct ctl_table));
>> +    tbl.maxlen = sizeof(unsigned int);
>> +
>> +    if (write)
>> +        tbl.data = &new_value;
>> +    else
>> +        tbl.data = &net->sctp.rto_max;
>> +    ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
>> +    if (write) {
>> +                if (ret || new_value > max || new_value < min)
>> +            return -EINVAL;
>> +        net->sctp.rto_max = new_value;
>> +    }
>> +    return ret;
>> +}
>> +
>>   int sctp_sysctl_net_register(struct net *net)
>>   {
>>       struct ctl_table *table;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
