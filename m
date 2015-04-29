From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Wed, 29 Apr 2015 22:27:05 +0200
Message-ID: <55413E99.5000807@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1430333589-4940-7-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/2015 08:53 PM, Pablo Neira Ayuso wrote:
> Port qdisc ingress on top of the Netfilter ingress allows us to detach the
> qdisc ingress filtering code from the core, so now it resides where it really
> belongs.

Hm, but that means, in case you have a tc ingress qdisc attached
with one single (ideal) or more (less ideal) classifier/actions,
the path we _now_ have to traverse just to a single tc classifier
invocation is, if I spot this correctly, f.e.:

  __netif_receive_skb_core()
  `-> nf_hook_ingress()
   `-> nf_hook_do_ingress()
    `-> nf_hook_slow()
     `-> [for each entry in hook list]
      `-> nf_iterate()
       `-> (*elemp)->hook()
        `-> handle_ing()
         `-> ing_filter()
          `-> qdisc_enqueue_root()
           `-> sch->enqueue()
            `-> ingress_enqueue()
             `-> tc_classify()
              `-> tc_classify_compat()
               `-> [for each attached classifier]
                `-> tp->classify()
                 `-> f.e. cls_bpf_classify()
                  `-> [for each classifier from plist]
                   `-> BPF_PROG_RUN()

What was actually mentioned in the other thread where we'd like to
see a more lightweight ingress qdisc is to cut that down tremendously
to increase pps rate, as provided, that we would be able to process
a path roughly like:

  __netif_receive_skb_core()
  `-> tc_classify()
   `-> tc_classify_compat()
     `-> [for each attached classifier]
       `-> tp->classify()
         `-> f.e. cls_bpf_classify()
           `-> [for each classifier from plist]
             `-> BPF_PROG_RUN()

Therefore, I think it would be better to not wrap that ingress qdisc
part of the patch set into even more layers. What do you think?

Thanks,
Daniel
