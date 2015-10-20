From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Mon, 19 Oct 2015 23:16:33 -0700
Message-ID: <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36047 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbJTGQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 02:16:53 -0400
Received: by ykba4 with SMTP id a4so1170481ykb.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 23:16:52 -0700 (PDT)
In-Reply-To: <1445112865-31523-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
> [ CC netdev since patch #2 isn't nf-specific.  Dave, if you want
>   I can resubmit that one after the next nf-pull request; let me know if
>   you would prefer that ].
>
> Openvswitch seems broken wrt. to defragmentation, it doesn't call
> nf_ct_frag6_consume_orig to free the original fragments.

This will need to be fixed for 'net' as well, do you have a path in
mind for that?

> Moreover, openvswitch design seems to require that it can reuse current
> skb rather than work with a new skb pointer (it uses skb_morph for this).
>
> Instead of OVS-side fix this series tries to alter netfilter ipv6 defrag
> accordingly.
>
> 1. nf_ct_frag6_consume_orig is removed, since
> commit 6aafeef03b9d9ecf ("netfilter: push reasm skb through instead of
> original frag skbs") nothing needs the original fragments so there is no
> reason why we need to clone+store original skb -- just stash original
> skbs in the frag_list.
>
> 2. Use skb_morph to make the last skb processed (not necessarily last
> fragment) the reassembled one.
>
> 3. remove the no-longer needed recursion into nf_iterate, we can now just
> return ACCEPT/STOLEN as needed instead of NF_HOOK_THRESH()+NF_STOLEN.
>
> Tested with flood-ping6+ fault-injection framework 'failslab' type.

Overall, I like it in that it seems to make the IPv6 code more
consistent with IPv4, and it's a net negative LoC, simplifying the
code.

Patch 3 when taken independently from patch 4 hides user-visible error
codes on the OVS side. The OVS conntrack action hides -EINPROGRESS
from userspace, treating it as a successful execution. All other
errors are returned up. With that patch, all errors will be hidden. I
see that it's fixed in Patch 4, so maybe it's not a biggie but those
two patches should be tightly coupled.
