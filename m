From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 01:36:00 +0200
Message-ID: <20150429233600.GA7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55413E99.5000807@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.04, Daniel Borkmann wrote:
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
> 

You obviously realize this callchain is fully made up by yourself
because 1/3 of the functions will be optimized away by the compiler,
some are completely gone with this patchset and some are optional
and appear to be present simply to make it appear longer.

The difference is very simple: where we had an indirect call to
q->enqueue before (and a lot of crap that didn't belong there),
we now have a call to nf_hook_slow, followed by the hook invocation.
