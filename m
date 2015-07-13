From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 12:47:42 -0700
Message-ID: <55A415DE.8020806@plumgrid.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com> <20150711.212917.1463596559900301434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33555 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbbGMTrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:47:31 -0400
Received: by pdbqm3 with SMTP id qm3so85289435pdb.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 12:47:31 -0700 (PDT)
In-Reply-To: <20150711.212917.1463596559900301434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/15 9:29 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Fri, 10 Jul 2015 17:10:11 -0700
>
>> TC actions need to check for very unlikely event skb->users != 1,
>> otherwise subsequent pskb_may_pull/pskb_expand_head will crash.
>> When skb_shared() just drop the packet, since in the middle of actions
>> it's too late to call skb_share_check(), since classifiers/actions assume
>> the same skb pointer.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> I think whatever creates this skb->users != 1 situation should be fixed,
> they should clone the packet.

In all normal cases skb->users == 1, but pktgen is using trick:
atomic_add(burst, &skb->users);
so when testing something like:
tc filter add dev $dev root pref 10 u32 match u32 0 0 flowid 1:2 \
   action vlan push id 2 action drop

it will crash:
[   31.999519] kernel BUG at ../net/core/skbuff.c:1130!
[   31.999519] invalid opcode: 0000 [#1] PREEMPT SMP
[   31.999519] Modules linked in: act_gact act_vlan cls_u32 sch_ingress 
veth pktgen
[   31.999519] CPU: 0 PID: 339 Comm: kpktgend_0 Not tainted 4.1.0+ #730
[   31.999519] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), [ 
   31.999519] Call Trace:
[   31.999519]  [<ffffffff8160eea7>] skb_vlan_push+0x1d7/0x200
[   31.999519]  [<ffffffffa0017108>] tcf_vlan+0x108/0x110 [act_vlan]
[   31.999519]  [<ffffffff81650d26>] tcf_action_exec+0x46/0x80
[   31.999519]  [<ffffffffa001f4fe>] u32_classify+0x30e/0x740 [cls_u32]
[   31.999519]  [<ffffffff810bcc6f>] ? __lock_acquire+0xbcf/0x1e80
[   31.999519]  [<ffffffff810bcc6f>] ? __lock_acquire+0xbcf/0x1e80
[   31.999519]  [<ffffffff8161f392>] ? __netif_receive_skb_core+0x1b2/0xce0
[   31.999519]  [<ffffffff8164c0c3>] tc_classify_compat+0xa3/0xb0
[   31.999519]  [<ffffffff8164ca03>] tc_classify+0x33/0x90
[   31.999519]  [<ffffffff8161f674>] __netif_receive_skb_core+0x494/0xce0
[   31.999519]  [<ffffffff8161f274>] ? __netif_receive_skb_core+0x94/0xce0
[   31.999519]  [<ffffffff810bf10d>] ? trace_hardirqs_on_caller+0xad/0x1d0
[   31.999519]  [<ffffffff8161fee1>] __netif_receive_skb+0x21/0x70
[   31.999519]  [<ffffffff81620b43>] netif_receive_skb_internal+0x23/0x1c0
[   31.999519]  [<ffffffff816219a9>] netif_receive_skb_sk+0x49/0x1e0
[   31.999519]  [<ffffffffa0006e8d>] pktgen_thread_worker+0x111d/0x1fa0 
[pktgen]

> In fact, it would really help enormously if you could explain in detail
> how this situation can actually arise.  Especially since I do not consider
> it acceptable to drop the packet in this situation.

It's not pretty to drop, but it's better than crash.
I don't think we can get rid of 'skb->users += burst' trick, since
that's where all performance comes from (for both TX and RX testing).

So the only cheap way I see to avoid crash is to do this
if (unlikely(skb_shared(skb)))
check in actions that call pskb_expand_head.

In all normal scenarios it won't be triggered and pktgen tests
won't be crashing.
Yes. pktgen numbers will be a bit meaningless, since act_vlan will be
dropping instead of adding vlan, so users cannot make any performance
conclusions, but still better than crash.

> the rules specified here:
> Documentation/networking/tc-actions-env-rules.txt
> insufficient?

Jamal,
that doc definitely needs updating. :)
It says:
"If you munge any packet thou shalt call pskb_expand_head in the case
someone else is referencing the skb. After that you "own" the skb."
that's incorrect. If somebody 'referencing' skb via skb->users > 1
it's too late to call pskb_expand_head. As you can see in the
crash trace above.
