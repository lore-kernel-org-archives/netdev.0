From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Tue, 6 Jun 2017 15:44:22 -0700
Message-ID: <92363e1c-09fe-b3dd-9852-e8bb68d1060f@gmail.com>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
 <20170601234235.iwu55crijtxuq5mp@ast-mbp> <5936DEBD.2050401@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36731 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751436AbdFFWoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 18:44:24 -0400
Received: by mail-pg0-f66.google.com with SMTP id v18so10854186pgb.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 15:44:24 -0700 (PDT)
In-Reply-To: <5936DEBD.2050401@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/06/2017 09:56 AM, Daniel Borkmann wrote:
> On 06/02/2017 01:42 AM, Alexei Starovoitov wrote:
>> On Wed, May 31, 2017 at 06:16:00PM -0700, Chenbo Feng wrote:
>>> From: Chenbo Feng <fengc@google.com>
>>>
>>> Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
>>> capability while attaching the program to a cgroup only requires the
>>> user have CAP_NET_ADMIN privilege. We can escape the capability
>>> check when load the program just like socket filter program to make
>>> the capability requirement consistent.
>>>
>>> Change since v1:
>>> Change the code style in order to be compliant with checkpatch.pl
>>> preference
>>>
>>> Signed-off-by: Chenbo Feng <fengc@google.com>
>>
>> as far as I can see they're indeed the same as socket filters, so
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>>
>> but I don't quite understand how it helps, since as you said
>> attaching such unpriv fd to cgroup still requires root.
>> Do you have more patches to follow?
>
> Hmm, when we relax this from capable(CAP_SYS_ADMIN) to unprivileged,
> then we must at least also zero out the not-yet-initialized memory
> for the mac header for egress case in __cgroup_bpf_run_filter_skb().
>

Do you mean something like:

if (type == BPF_CGROUP_INET_EGRESS) {

         offset = skb_network_header(skb) - skb_mac_header(skb);

         memset(skb_mac_header(skb), 0, offset)

}

And could you explain more on why we need to do this if we remove the 
CAP_SYS_ADMIN check? I thought we still cannot directly access the 
sk_buff without using bpf_skb_load_bytes helper and we still need a 
CAP_NET_ADMIN in order to attach and run the program on egress side right?
