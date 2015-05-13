From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len
 before tc_classify
Date: Wed, 13 May 2015 15:43:28 -0700
Message-ID: <1431557008.27831.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
	 <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513213348.GC6179@breakpoint.cc>
	 <1431553132.27831.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5553CFBD.1070204@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37755 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964835AbbEMWna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 18:43:30 -0400
Received: by igbsb11 with SMTP id sb11so58469250igb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 15:43:30 -0700 (PDT)
In-Reply-To: <5553CFBD.1070204@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 15:27 -0700, Alexei Starovoitov wrote:
> On 5/13/15 2:38 PM, Eric Dumazet wrote:
> >
> > One possibility would be to set it in GRO engine.
> >
> > But then we would have to set qdisc_skb_cb(skb)->pkt_len = skb->len for
> > non GRO packets.
> >
> > Also note the DODGY thing might be not needed for ingress,
> > and I am not sure we can currently deliver UDP aggregated packets.
> 
> yeah, current qdisc_pkt_len_init() is certainly TX oriented.
> I'm not sure we can use tcp_hdrlen(skb) on RX which is called as
> part of qdisc_pkt_len_init().

We can, because GRO leave transport header set at the right place.

> I think it's probably better to take Florian's V1 with:
> qdisc_skb_cb(skb)->pkt_len = skb->len;
> to fix immediate breakage of act police and then proceed further?

Yes.

> Like doing qdisc_skb_cb(skb)->pkt_len = skb->len inside GRO engine
> is probably not possible, since cb is used by napi_gro_cb ?

Everything is possible ;)

At the time tcp_gro_complete() is called, we certainly can overwrite 
NAPI_GRO_CB(skb)->frag0, with good documentation and BUILD_BUG_ON()
safet nets.
