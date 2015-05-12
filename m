From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Mon, 11 May 2015 20:21:51 -0700
Message-ID: <555171CF.70106@plumgrid.com>
References: <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia>	 <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia>	 <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia>	 <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net>	 <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com>	 <20150511133245.GA4430@salvia>	 <1431354912.566.15.camel@edumazet-glaptop2.roam.corp.google.com>	 <555134F4.80007@plumgrid.com> <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36625 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbbELDVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 23:21:52 -0400
Received: by pdea3 with SMTP id a3so166346309pde.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:21:52 -0700 (PDT)
In-Reply-To: <1431387038.566.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 4:30 PM, Eric Dumazet wrote:
>
> For example , commit 7866a621043fbaca3d7389e9b9f69dd1a2e5a855
> helped a given workload, but probably made things slower for most common
> cases.

yes, indeed. reverting it improves netif_receive + drop in ip_rcv
from 41.1 to 42.6. I've been trying to come up with a simple way
to roll global ptype_all into skb->dev->ptype_all, but registering
device notifier seems overkill to remove one loop from netif_receive.
Also tried to partially remove pt_prev logic from the first half
of netif_receive and keep it only for deliver_ptype_list_skb() part,
but that didn't help.
Then tried this:
-static int __netif_receive_skb(struct sk_buff *skb)
+static inline int __netif_receive_skb(struct sk_buff *skb)
...
-static int netif_receive_skb_internal(struct sk_buff *skb)
+static inline int netif_receive_skb_internal(struct sk_buff *skb)

it helped to go from 41.1 to 43.1, but size increase not negligible:
    text	   data	    bss	    dec	    hex	filename
   55990	   1667	   2856	  60513	   ec61	dev.o.base
   56403	   1907	   2856	  61166	   eeee	dev.o.inline

inlining only one of them (either __netif_receive_skb or
netif_receive_skb_internal) gives minimal gain.
Still exploring...
