From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 01:32:05 +0200
Message-ID: <20150429233205.GA3416@salvia>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55413E99.5000807@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 29, 2015 at 10:27:05PM +0200, Daniel Borkmann wrote:
> On 04/29/2015 08:53 PM, Pablo Neira Ayuso wrote:
> >Port qdisc ingress on top of the Netfilter ingress allows us to detach the
> >qdisc ingress filtering code from the core, so now it resides where it really
> >belongs.
> 
> Hm, but that means, in case you have a tc ingress qdisc attached
> with one single (ideal) or more (less ideal) classifier/actions,
> the path we _now_ have to traverse just to a single tc classifier
> invocation is, if I spot this correctly, f.e.:
> 
>  __netif_receive_skb_core()
>  `-> nf_hook_ingress()
>   `-> nf_hook_do_ingress()
>    `-> nf_hook_slow()
>     `-> [for each entry in hook list]
>      `-> nf_iterate()
>       `-> (*elemp)->hook()
>        `-> handle_ing()
>         `-> ing_filter()
>          `-> qdisc_enqueue_root()
>           `-> sch->enqueue()
>            `-> ingress_enqueue()
>             `-> tc_classify()
>              `-> tc_classify_compat()
>               `-> [for each attached classifier]
>                `-> tp->classify()
>                 `-> f.e. cls_bpf_classify()
>                  `-> [for each classifier from plist]
>                   `-> BPF_PROG_RUN()

Actually, the extra cost is roughly (getting inlined stuff away and
other non-relevant stuff):

    `-> nf_hook_slow()
     `-> [for each entry in hook list]
      `-> nf_iterate()
       `-> (*elemp)->hook()

as part of the generic hook infrastructure, which comes with extra
flexibility in return. I think the main concern so far was not to harm
the critical netif_receive_core() path, and this patchset proves not
to affect this.

BTW, the sch->enqueue() can easily go away after this patchset, see
attached patch.

> What was actually mentioned in the other thread where we'd like to
> see a more lightweight ingress qdisc is to cut that down tremendously
> to increase pps rate, as provided, that we would be able to process
> a path roughly like:
> 
>  __netif_receive_skb_core()
>  `-> tc_classify()
>   `-> tc_classify_compat()
>     `-> [for each attached classifier]
>       `-> tp->classify()
>         `-> f.e. cls_bpf_classify()
>           `-> [for each classifier from plist]
>             `-> BPF_PROG_RUN()
> 
> Therefore, I think it would be better to not wrap that ingress qdisc
> part of the patch set into even more layers. What do you think?

I think the main front to improve performance in qdisc ingress is to
remove the central spinlock that is harming scalability. There's also
the built-in rule counters there that look problematic. So I would
focus on improving performance from the qdisc ingress core
infrastructure itself.

On the bugfix front, the illegal mangling of shared skb from actions
like stateless nat and bpf look also important to be addressed to me.
David already suggested to propagate some state object that keeps a
pointer to the skb that is passed to the action. Thus, the action can
clone it and get the skb back to the ingress path. I started a
patchset to do so here, it's a bit large since it requires quite a lot
of function signature adjustment.

I can also see there were also intentions to support userspace
queueing at some point since TC_ACT_QUEUED has been there since the
beginning.  That should be possible at some point using this
infrastructure (once there are no further concerns on the
netif_receive_core_finish() patch as soon as gcc 4.9 and follow up
versions keep inlining this new function).
