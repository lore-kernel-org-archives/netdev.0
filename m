From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Mon, 11 May 2015 10:15:53 -0700
Message-ID: <5550E3C9.1030306@plumgrid.com>
References: <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia> <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia> <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia> <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net> <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com> <5550A75B.3010003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34218 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbEKRPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:15:54 -0400
Received: by iedfl3 with SMTP id fl3so127507015ied.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:15:54 -0700 (PDT)
In-Reply-To: <5550A75B.3010003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 5:58 AM, Daniel Borkmann wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
>
> -static inline struct sk_buff *handle_ing(struct sk_buff *skb,
> +static __always_inline struct sk_buff *handle_ing(struct sk_buff *skb,
>                        struct packet_type **pt_prev,
>                        int *ret, struct net_device *orig_dev)
>   {
>       struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
> +    int i = 0;
> +
> +    printk("XXX %d\n", i++);
> +    printk("XXX %d\n", i++);
   .. lots of printk...

that an interesting test! Tried it out as well:

current baseline:
37711847pps 18101Mb/sec (18101686560bps) errors: 10000000
37776912pps 18132Mb/sec (18132917760bps) errors: 10000000
37700180pps 18096Mb/sec (18096086400bps) errors: 10000000
37730169pps 18110Mb/sec (18110481120bps) errors: 10000000

with massive printk bloating in _inlined_ handle_ing:
37744223pps 18117Mb/sec (18117227040bps) errors: 10000000
37718786pps 18105Mb/sec (18105017280bps) errors: 10000000
37742087pps 18116Mb/sec (18116201760bps) errors: 10000000
37727777pps 18109Mb/sec (18109332960bps) errors: 10000000

no performance difference as expected and matches what Daniel is seeing.

Then I've tried to do 'noinline' for handle_ing():
36818072pps 17672Mb/sec (17672674560bps) errors: 10000000
36828761pps 17677Mb/sec (17677805280bps) errors: 10000000
36840106pps 17683Mb/sec (17683250880bps) errors: 10000000
36885403pps 17704Mb/sec (17704993440bps) errors: 10000000

this drop when static_key suppose to protect handle_ing()
was totally unexpected.
So I started digging into assembler before and after.
Turned out that with inlined handle_ing GCC can see what is
happening with pt_prev and ret pointers, so with handle_ing
inlined the asm looks like:
movl    $1, %r15d       #, ret
xorl    %r12d, %r12d    # pt_prev

when handle_ing is not inlined, the asm of netif_receive_skb has:
movl    $1, -68(%rbp)   #, ret
movq    $0, -64(%rbp)   #, pt_prev

To test it further I've tried:
+static noinline struct sk_buff *handle_ing_finish(struct sk_buff *skb,
+                                                 struct tcf_proto *cl)
...
static inline struct sk_buff *handle_ing(struct sk_buff *skb,
+                                        struct packet_type **pt_prev,
+                                        int *ret, struct net_device 
*orig_dev)
+{
+       struct tcf_proto *cl = 
rcu_dereference_bh(skb->dev->ingress_cl_list);
+
+       if (!cl)
+               return skb;
+       if (*pt_prev) {
+               *ret = deliver_skb(skb, *pt_prev, orig_dev);
+               *pt_prev = NULL;
+       }
+       return handle_ing_finish(skb, cl);
+}

so tc ingress part would not be inlined, but deliver_skb bits are.
The performance went back to normal:
37701570pps 18096Mb/sec (18096753600bps) errors: 10000000
37752444pps 18121Mb/sec (18121173120bps) errors: 10000000
37719331pps 18105Mb/sec (18105278880bps) errors: 10000000

Unfortunately this last experiment hurts ingress+u32 case
that dropped from 25.2 Mpps to 24.5 Mpps.

Will keep digging into it more. Stay tuned.
