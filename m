From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: netfilter: work around shared nfct struct
Date: Tue, 30 Aug 2011 15:08:13 +0200
Message-ID: <4E5CE0BD.7040103@trash.net>
References: <1314701827-21702-1-git-send-email-fw@strlen.de> <4E5CDADC.7000902@trash.net> <20110830125453.GC7548@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110830125453.GC7548@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.08.2011 14:54, Florian Westphal wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>> On 30.08.2011 12:57, Florian Westphal wrote:
>>> When incoking iptables hooks from bridge netfilter, the assumption
>>> that non-confirmed skb->nfct is never shared does no longer hold,
>>> as bridge code clones skbs when e.g. forwarding packets to multiple
>>> bridge ports.
>>>
>>> When NFQUEUE is used, we can BUG because nf_nat_setup_info can be
>>> invoked simultaneously for the same conntrack:
>>
>> I'm wondering how this can happen, when flooding packets to multiple
>> ports, they are still processed by the same CPU one after another,
>> so for the second and further packets, nf_nat should notice that
>> the mappings are already set up.
> 
> Main problem is that we end up with same ->nfct in both
> INPUT and POSTROUTING (br_pass_frame_up vs. br_forward).
> 
> its extremely unlikely but reproduceable with something like
> hping2 -i u1200 -2 -p 138 -d 128 192.168.0.255
> 
> (assuming bridge interface has an address within that network).
> 
> Also, with recent change nf_reinject can be run in parallel.
> (the original problem was observed on 2.6.32.24, but i can
>  reproduce it with nf-next, too).

I see. We still need to avoid the module dependency on nf_conntrack
though, so I think this will have to be fixed in nf_nat_fn().
