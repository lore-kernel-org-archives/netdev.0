From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3] rps: selective flow shedding during softnet overflow
Date: Tue, 23 Apr 2013 16:30:28 -0400
Message-ID: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
References: <CA+FuTSf-jJc5D_2js1-ZZU8kcaizzuKHjc-BY_Bqqk-9kaU+MA@mail.gmail.com>
 <1366742817-8480-1-git-send-email-willemb@google.com> <1366744738.8964.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:62121 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374Ab3DWUa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 16:30:59 -0400
Received: by mail-ie0-f179.google.com with SMTP id 16so1208130iea.24
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 13:30:58 -0700 (PDT)
In-Reply-To: <1366744738.8964.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 3:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Hi Willem
>
> On Tue, 2013-04-23 at 14:46 -0400, Willem de Bruijn wrote:
>
>> +
>> +static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
>> +{
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +     struct sd_flow_limit *fl;
>> +     struct softnet_data *sd;
>> +     unsigned int old_flow, new_flow;
>> +
>> +     if (qlen < (netdev_max_backlog >> 1))
>> +             return false;
>> +
>> +     sd = &per_cpu(softnet_data, smp_processor_id());
>
> sd = __get_cpu_var(softnet_data);
>
>> +
>> +     rcu_read_lock();
>> +     fl = rcu_dereference(sd->flow_limit);
>> +     if (fl) {
>> +             new_flow = skb_get_rxhash(skb) & (fl->num_buckets - 1);
>> +             old_flow = fl->history[fl->history_head];
>> +             fl->history[fl->history_head] = new_flow;
>> +
>> +             fl->history_head++;
>> +             fl->history_head &= FLOW_LIMIT_HISTORY - 1;
>> +
>> +             if (likely(fl->buckets[old_flow]))
>> +                     fl->buckets[old_flow]--;
>> +
>> +             if (++fl->buckets[new_flow] > (FLOW_LIMIT_HISTORY >> 1)) {
>> +                     fl->count++;
>> +                     rcu_read_unlock();
>> +                     return true;
>> +             }
>> +     }
>> +     rcu_read_unlock();
>> +#endif
>> +     return false;
>> +}
>> +
>
> ...
>
>
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +static DEFINE_MUTEX(flow_limit_update_mutex);
>> +
>> +static int flow_limit_cpu_sysctl(ctl_table *table, int write,
>> +                              void __user *buffer, size_t *lenp,
>> +                              loff_t *ppos)
>> +{
>> +     struct sd_flow_limit *cur;
>> +     struct softnet_data *sd;
>> +     cpumask_var_t mask;
>> +     int i, len, ret = 0;
>> +
>> +     if (!alloc_cpumask_var(&mask, GFP_KERNEL))
>> +             return -ENOMEM;
>> +
>> +     if (write) {
>> +             ret = cpumask_parse_user(buffer, *lenp, mask);
>> +             if (ret)
>> +                     goto done;
>> +
>> +             mutex_lock(&flow_limit_update_mutex);
>> +             len = sizeof(*cur) + netdev_flow_limit_table_len;
>> +             for_each_possible_cpu(i) {
>> +                     sd = &per_cpu(softnet_data, i);
>> +                     cur = rcu_dereference_protected(sd->flow_limit,
>> +                                   lockdep_is_held(flow_limit_update_mutex));
>> +                     if (cur && !cpumask_test_cpu(i, mask)) {
>> +                             RCU_INIT_POINTER(sd->flow_limit, NULL);
>> +                             synchronize_rcu();
>> +                             kfree(cur);
>> +                     } else if (!cur && cpumask_test_cpu(i, mask)) {
>> +                             cur = kzalloc(len, GFP_KERNEL);
>> +                             if (!cur) {
>> +                                     /* not unwinding previous changes */
>> +                                     ret = -ENOMEM;
>> +                                     goto write_unlock;
>> +                             }
>> +                             cur->num_buckets = netdev_flow_limit_table_len;
>> +                             rcu_assign_pointer(sd->flow_limit, cur);
>> +                     }
>> +             }
>> +write_unlock:
>> +             synchronize_rcu();
>
> I believe you do not need this synchronize_rcu() call.

Because in this special case rcu_assign_pointer always replaces a
NULL value, correct? Thanks again for the feedback! I rebased, reran
the tests and will send v4 with these two changes (only).

>
>> +             mutex_unlock(&flow_limit_update_mutex);
>> +     } else {
>> +             if (*ppos || !*lenp) {
>> +                     *lenp = 0;
>> +                     goto done;
>> +             }
>> +
>> +             cpumask_clear(mask);
>> +             rcu_read_lock();
>> +             for_each_possible_cpu(i) {
>> +                     sd = &per_cpu(softnet_data, i);
>> +                     if (rcu_dereference(sd->flow_limit))
>> +                             cpumask_set_cpu(i, mask);
>> +             }
>> +             rcu_read_unlock();
>> +
>> +             len = cpumask_scnprintf(buffer, *lenp, mask);
>> +             *lenp = len + 1;
>> +             *ppos += len + 1;
>> +     }
>> +
>> +done:
>> +     free_cpumask_var(mask);
>> +     return ret;
>> +}
>> +
>
> Thanks !
>
>
