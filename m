From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 1/8] bpf: Recursively apply cgroup sock filters
Date: Wed, 23 Aug 2017 09:33:09 -0700
Message-ID: <3a2e5263-354a-0496-a033-8b16901ba423@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
 <1503447621-27997-2-git-send-email-dsahern@gmail.com>
 <20170823014005.6riceht5iwv7zzxh@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35066 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754139AbdHWQdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 12:33:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id a74so23646pfg.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 09:33:13 -0700 (PDT)
In-Reply-To: <20170823014005.6riceht5iwv7zzxh@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/17 6:40 PM, Alexei Starovoitov wrote:
>> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
>> index df2e0f14a95d..7480cebab073 100644
>> --- a/kernel/cgroup/cgroup.c
>> +++ b/kernel/cgroup/cgroup.c
>> @@ -5186,4 +5186,22 @@ int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
>>  	mutex_unlock(&cgroup_mutex);
>>  	return ret;
>>  }
>> +
>> +int cgroup_bpf_run_filter_sk(struct sock *sk,
>> +			     enum bpf_attach_type type)
>> +{
>> +	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
>> +	int ret = 0;
>> +
>> +	while (cgrp) {
>> +		ret = __cgroup_bpf_run_filter_sk(cgrp, sk, type);
>> +		if (ret < 0)
>> +			break;
>> +
>> +		cgrp = cgroup_parent(cgrp);
>> +	}
> 
> I think this walk changes semantics for existing setups, so we cannot do it
> by default and have to add new attach flag.

I can add a flag similar to the override.

> Also why break on (ret < 0) ?

Because __cgroup_bpf_run_filter_sk returns either 0 or -EPERM.

> The caller of this does:
>   err = BPF_CGROUP_RUN_PROG_INET_SOCK(sk);
>   if (err) {
>           sk_common_release(sk);
> so we should probably break out of the loop on if (ret) too.
> 

I'll do that in v2.
