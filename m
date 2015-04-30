From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Wed, 29 Apr 2015 23:02:57 -0700
Message-ID: <20150430060256.GA12790@Alexeis-MBP.westell.com>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <20150430003740.GF7025@acer.localdomain>
 <55417F80.4000506@iogearbox.net>
 <20150430014316.GB7956@acer.localdomain>
 <554194E9.5040002@mojatatu.com>
 <20150430032921.GB8950@acer.localdomain>
 <20150430040535.GH8950@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150430040535.GH8950@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 30, 2015 at 06:05:37AM +0200, Patrick McHardy wrote:

> 06:05:37AM

do you ever sleep? ;)

> For the sake of completeness - on ingress, this alternativ means simply
> ditching TC. 

I'm sure 'ditching TC' doesn't mean to kill ingress qdisc
completely. Compatibility needs to be preserved.

What I'm doing in my 'experimental ingress qdisc' acceleration
boils down to:
@@ -1649,6 +1649,7 @@ struct net_device {
        rx_handler_func_t __rcu *rx_handler;
        void __rcu              *rx_handler_data;

-       struct netdev_queue __rcu *ingress_queue;
+       struct tcf_proto __rcu  *ingress_filter_list;

so to call tc_classify() and reach cls_bpf I don't need to walk
down skb->dev->ingress_queue->qdisc->enqueue/qdisc_priv->filter_list
and can just do skb->dev->ingress_filter_list
and can skip several unnecessary deref like sch->stab, skb->len, etc.
Both ingress_queue and ingress qdisc are no longer allocated
and stay only as a shim to preserve uapi.

My point is that I agree that cleanup of ingress qdisc is needed.
I disagree with drastic measures.
Just add your nf_hook to ingress and let's see how things evolve.
We have rx_handler and all of ptype hooks in there. One can argue
that rx_handler overlaps with nf_hook too ? ;)
We cannot generalize them all under one 'hook' infra.
nf needs to do nf_hook_state_init() and pass it around which
no one else needs. That's the cost others should not pay.

