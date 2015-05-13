From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len before
 tc_classify
Date: Wed, 13 May 2015 15:27:09 -0700
Message-ID: <5553CFBD.1070204@plumgrid.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>	 <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>	 <20150513213348.GC6179@breakpoint.cc> <1431553132.27831.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35377 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965624AbbEMW1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 18:27:11 -0400
Received: by pabtp1 with SMTP id tp1so63697719pab.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 15:27:10 -0700 (PDT)
In-Reply-To: <1431553132.27831.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/15 2:38 PM, Eric Dumazet wrote:
>
> One possibility would be to set it in GRO engine.
>
> But then we would have to set qdisc_skb_cb(skb)->pkt_len = skb->len for
> non GRO packets.
>
> Also note the DODGY thing might be not needed for ingress,
> and I am not sure we can currently deliver UDP aggregated packets.

yeah, current qdisc_pkt_len_init() is certainly TX oriented.
I'm not sure we can use tcp_hdrlen(skb) on RX which is called as
part of qdisc_pkt_len_init().
I think it's probably better to take Florian's V1 with:
qdisc_skb_cb(skb)->pkt_len = skb->len;
to fix immediate breakage of act police and then proceed further?
Like doing qdisc_skb_cb(skb)->pkt_len = skb->len inside GRO engine
is probably not possible, since cb is used by napi_gro_cb ?
