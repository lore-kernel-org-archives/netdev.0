From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 2/6] cgroup: add support for eBPF programs
Date: Wed, 7 Sep 2016 10:04:38 +0200
Message-ID: <50f28eb4-647b-9152-57af-2877c69589d2@zonque.org>
References: <1473169568-30525-1-git-send-email-daniel@zonque.org>
 <1473169568-30525-3-git-send-email-daniel@zonque.org>
 <57CEFA48.6010101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57CEFA48.6010101-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/06/2016 07:18 PM, Daniel Borkmann wrote:
> On 09/06/2016 03:46 PM, Daniel Mack wrote:
>> This patch adds two sets of eBPF program pointers to struct cgroup.
>> One for such that are directly pinned to a cgroup, and one for such
>> that are effective for it.
>>
>> To illustrate the logic behind that, assume the following example
>> cgroup hierarchy.
>>
>>    A - B - C
>>          \ D - E
>>
>> If only B has a program attached, it will be effective for B, C, D
>> and E. If D then attaches a program itself, that will be effective for
>> both D and E, and the program in B will only affect B and C. Only one
>> program of a given type is effective for a cgroup.
>>
>> Attaching and detaching programs will be done through the bpf(2)
>> syscall. For now, ingress and egress inet socket filtering are the
>> only supported use-cases.
>>
>> Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
> [...]
>> +/**
>> + * __cgroup_bpf_run_filter() - Run a program for packet filtering
>> + * @sk: The socken sending or receiving traffic
>> + * @skb: The skb that is being sent or received
>> + * @type: The type of program to be exectuted
>> + *
>> + * If no socket is passed, or the socket is not of type INET or INET6,
>> + * this function does nothing and returns 0.
>> + *
>> + * The program type passed in via @type must be suitable for network
>> + * filtering. No further check is performed to assert that.
>> + *
>> + * This function will return %-EPERM if any if an attached program was found
>> + * and if it returned != 1 during execution. In all other cases, 0 is returned.
>> + */
>> +int __cgroup_bpf_run_filter(struct sock *sk,
>> +			    struct sk_buff *skb,
>> +			    enum bpf_attach_type type)
>> +{
>> +	struct bpf_prog *prog;
>> +	struct cgroup *cgrp;
>> +	int ret = 0;
>> +
>> +	if (!sk)
>> +		return 0;
> 
> Doesn't this also need to check || !sk_fullsock(sk)?

Ah, yes. We should limit it to full sockets. Thanks!


Daniel
