From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] rps: selective flow shedding during softnet overflow
Date: Tue, 23 Apr 2013 14:45:32 -0400
Message-ID: <CA+FuTSf-jJc5D_2js1-ZZU8kcaizzuKHjc-BY_Bqqk-9kaU+MA@mail.gmail.com>
References: <CA+FuTSfyo5YdtLpyXPawYoppM7zj5cp1_k1hD7+qWL6DUpNd4Q@mail.gmail.com>
 <1366663561-12305-1-git-send-email-willemb@google.com> <1366669808.16391.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:40359 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab3DWSqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 14:46:03 -0400
Received: by mail-ia0-f177.google.com with SMTP id y26so855395iab.22
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 11:46:02 -0700 (PDT)
In-Reply-To: <1366669808.16391.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 6:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-04-22 at 16:46 -0400, Willem de Bruijn wrote:
>
>> +             len = sizeof(*cur) + netdev_flow_limit_table_len;
> [1]
>> +             mutex_lock(&flow_limit_update_mutex);
> [2]
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
>> +                             cur->num_buckets = netdev_flow_limit_table_len;
> [3]
>
> Its a bit tricky, but the value of netdev_flow_limit_table_len could
> change between [1] and [3]
>
> So you should read its value once, or protect the whole thing using
> mutex_lock(&flow_limit_update_mutex) in sysctl code ( and move [1] after
> [2])

Thanks for the detailed explanation. I implemented the second
solution: make writes to the two sysctls mutually exclusive.
>
>
