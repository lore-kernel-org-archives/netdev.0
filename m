From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Wed, 08 Apr 2015 20:05:13 -0700
Message-ID: <5525EC69.1080606@plumgrid.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36536 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbbDIDFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 23:05:16 -0400
Received: by pdea3 with SMTP id a3so136938974pde.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 20:05:15 -0700 (PDT)
In-Reply-To: <20150408.224404.1913719826015357860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/15 7:44 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Wed,  8 Apr 2015 16:26:15 -0700
>
>> index 4cd5cf1aedf8..887033fbdfa6 100644
>> --- a/net/sched/act_csum.c
>> +++ b/net/sched/act_csum.c
>> @@ -565,6 +565,8 @@ static struct tc_action_ops act_csum_ops = {
>>   	.act		= tcf_csum,
>>   	.dump		= tcf_csum_dump,
>>   	.init		= tcf_csum_init,
>> +	/* todo: fix pskb_may_pull in tcf_csum to not assume L2 */
>> +	.flags		= TCA_NEEDS_L2,
>>   };
>>
>>   MODULE_DESCRIPTION("Checksum updating actions");
>
>
> All this module really cares about is where skb_network_header() is
> for data accesses.  And a simple offset would allow it to calculate
> the pskb_may_pull() length argument correctly.
>
> And it would therefore work without all of these expensive SKB share
> check calls etc.

yes. act_csum can be fixed. I mentioned that in the commit log.
I can drop markings for anything other than cls_bpf/act_bpf if you like?

> I really don't like your approach, and I'd rather you propagate the
> offset into the BPF programs you generate.  I bet you can do it in
> an efficient way, and just haven't put in the effort to discover
> how.

I'm sure there is a way to propagate the offset into the programs.
It's not about efficiency of programs, but about consistency.
Programs should know nothing about kernel. Sending network offset
into them is exposing this very specific kernel behavior.
As soon as we do that all programs need to be written with this
offset in mind, so they can work with ingress and egress. It would
also break sockex1_kern.c, sockex2_kern.c and all other bpf programs.
That's not acceptable to me.
As I said I'd rather disable them attaching to ingress than force
all program authors to always use network_offset.
Offset 0 points to L2 was always fundamental assumption of BPF.
Both in classic and now carried over into extended.
We cannot change that.
We can cheat and say 'bpf for ingress' has to use new rules, but
that's just wrong. Imagine documenting it everywhere and all
confusion it will cause.

I still don't understand why you don't like it.
bridge is doing skb_share_check and that's acceptable there.
What's wrong with doing it for ingress here under flag?
Will 'early_ingress_l2' hook and flag be better?
Like adding:
skb = early_handle_ing(skb, &pt_prev, &ret, orig_dev);
right before taps in __netif_receive_skb_core ?
This way we can safely push/pull without share check.
