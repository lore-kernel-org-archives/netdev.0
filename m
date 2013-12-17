From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Tue, 17 Dec 2013 13:34:39 -0800
Message-ID: <1387316079.19078.291.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52AB322B.7030802@redhat.com>
	 <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131217201930.GA27460@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:56386 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab3LQVem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:34:42 -0500
Received: by mail-qc0-f172.google.com with SMTP id e16so5391059qcx.17
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 13:34:42 -0800 (PST)
In-Reply-To: <20131217201930.GA27460@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 21:19 +0100, Hannes Frederic Sowa wrote:
> Hi Eric!
> 
> On Mon, Dec 16, 2013 at 06:31:23AM -0800, Eric Dumazet wrote:
> > In the future, we probably want to extend the MTU check to do the
> > right thing for GSO packets...
> 
> How could that look like?

I think I already posted a draft for this.

Idea would be to have a helper to compute the mtu of each segment :

static inline unsigned int gso_size_with_headers(const struct sk_buff *skb)
{
       unsigned int hdrlen = skb_transport_header(skb) - skb_network_header(skb);

       if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))
               hdrlen += tcp_hdrlen(skb);
       else
               hdrlen += 8; // sizeof(struct udphdr)

       return skb_shinfo(skb)->gso_size + hdrlen;
}

...

       len = skb_is_gso(skb) ? gso_size_with_headers(skb) : skb->len;

       if (unlikely(len > dst_mtu(&rt->dst) && ...
