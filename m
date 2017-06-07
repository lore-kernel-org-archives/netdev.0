From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Wed, 07 Jun 2017 17:57:50 +0200
Message-ID: <5938227E.3020601@iogearbox.net>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com> <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com> <20170601234235.iwu55crijtxuq5mp@ast-mbp> <5936DEBD.2050401@iogearbox.net> <92363e1c-09fe-b3dd-9852-e8bb68d1060f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42502 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdFGP55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 11:57:57 -0400
In-Reply-To: <92363e1c-09fe-b3dd-9852-e8bb68d1060f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 12:44 AM, Chenbo Feng wrote:
> On 06/06/2017 09:56 AM, Daniel Borkmann wrote:
>> On 06/02/2017 01:42 AM, Alexei Starovoitov wrote:
>>> On Wed, May 31, 2017 at 06:16:00PM -0700, Chenbo Feng wrote:
>>>> From: Chenbo Feng <fengc@google.com>
>>>>
>>>> Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
>>>> capability while attaching the program to a cgroup only requires the
>>>> user have CAP_NET_ADMIN privilege. We can escape the capability
>>>> check when load the program just like socket filter program to make
>>>> the capability requirement consistent.
>>>>
>>>> Change since v1:
>>>> Change the code style in order to be compliant with checkpatch.pl
>>>> preference
>>>>
>>>> Signed-off-by: Chenbo Feng <fengc@google.com>
>>>
>>> as far as I can see they're indeed the same as socket filters, so
>>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>>>
>>> but I don't quite understand how it helps, since as you said
>>> attaching such unpriv fd to cgroup still requires root.
>>> Do you have more patches to follow?
>>
>> Hmm, when we relax this from capable(CAP_SYS_ADMIN) to unprivileged,
>> then we must at least also zero out the not-yet-initialized memory
>> for the mac header for egress case in __cgroup_bpf_run_filter_skb().
>
> Do you mean something like:
>
> if (type == BPF_CGROUP_INET_EGRESS) {
>
>          offset = skb_network_header(skb) - skb_mac_header(skb);
>
>          memset(skb_mac_header(skb), 0, offset)

That won't work, reason is the same as per 92046578ac88 ("bpf: cgroup
skb progs cannot access ld_abs/ind"), meaning that mac header is not
yet set at that point in time, but more below.

> }
>
> And could you explain more on why we need to do this if we remove the
 > CAP_SYS_ADMIN check? I thought we still cannot directly access the
 > sk_buff without using bpf_skb_load_bytes helper and we still need a
 > CAP_NET_ADMIN in order to attach and run the program on egress side right?

Ok, forget this comment of mine. The __cgroup_bpf_run_filter_skb() does
__skb_push()/__skb_pull(), but for egress case the offset is always 0, so
we don't start at mac header but at network header instead, meaning memset()
is not needed.

Thanks,
Daniel
