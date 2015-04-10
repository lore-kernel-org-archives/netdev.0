From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 15:35:36 -0700
Message-ID: <55285038.3060806@plumgrid.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com> <5526B0E0.7060000@plumgrid.com> <5527C6AE.6010301@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33417 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbbDJWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:35:38 -0400
Received: by pdbnk13 with SMTP id nk13so36129619pdb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 15:35:38 -0700 (PDT)
In-Reply-To: <5527C6AE.6010301@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 5:48 AM, Jamal Hadi Salim wrote:
>
> That doesnt give you L2 at offset 0 for _some devices_ which is what you
> say you need. In some devices it adds a second L2 header.

ok. fair point. will add a check to make sure such ingress_l2 qdisc
doesn't get applied to devices without header_ops.
Same check is done by af_packet.

>
> To your "bugs" comments:
> - updating csum; earlier i said i was conflicted it being a
> useful "feature".
> You are repeating again that it is a bug. It is not.
> This action is intended to  mirror or redirect packets, period.

without updating skb->csum act_mirred is breaking csum for
checksum_complete devices. If these redirected skbs are eventually
seen by stack, the stack will drop them. I cannot use such
'feature', so I would need to find a way to do mirred without fixing
act_mirred. Fine.

> +        needs_l2 = q->flags & TCQ_F_INGRESS_L2;
> +        if (needs_l2) {
> ..
> ....
> +        if (needs_l2)
>
> That is executed for _every_ packet going after ingress qdisc.

and there is hugely expensive spin_lock/unlock around ingress.
Comparing to lock cmpxchg the cost of branch is a noise.
But fine, I'll find a way to optimize the whole thing without
adding extra branches.

> They have to know whether their code
> will run on ingress or egress and the type of device etc.
> The AT_XXX provides that signal and dev->type fills in the other gap.

True. The program authors may want to know whether the packet is seen
on ingress or egress and take different actions inside the program,
but forcing them to _always_ parse the packet differently because of
it is not acceptable.
