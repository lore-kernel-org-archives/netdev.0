From: Florian Westphal <fw@strlen.de>
Subject: Re: Problems with fragments since gso skb forwarding changes in
 virtual environment
Date: Tue, 8 Apr 2014 17:36:19 +0200
Message-ID: <20140408153619.GE31953@breakpoint.cc>
References: <5342CC9A.6040800@strongswan.org>
 <20140407234640.GB31953@breakpoint.cc>
 <5343EA79.8030104@strongswan.org>
 <20140408143318.GD31953@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tobias Brunner <tobias@strongswan.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49624 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756839AbaDHPgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 11:36:23 -0400
Content-Disposition: inline
In-Reply-To: <20140408143318.GD31953@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:

[ cc'd Eric ]

> Thanks for clarifying. In this case there is another problem as well as
> no fragments should be generated in the forwarding path if the outgoing mtu
> is not reduced.
> 
> Most likely a problem with udp gso + skb_gso_network_seglen().

Indeed, the problem is here:

unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
{
       const struct skb_shared_info *shinfo = skb_shinfo(skb);
       unsigned int hdr_len;

       if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
               hdr_len = tcp_hdrlen(skb);
       else
               hdr_len = sizeof(struct udphdr);
       return hdr_len + shinfo->gso_size;
}

For large GSO UDP packet received via virtio shinfo->gso_size is 1480 (mtu 1500).

Thus skb_gso_transport_seglen() claims transport seglen of 1488 which makes fwd
path think we're trying to send 1508 byte segments.

I am not familiar with UFO; setting hdr_len = 0 in else clause makes things
work for me.  I'll see if the sizeof(struct udphdr) is bogus for ufo or if ->gso_size
is wrong.
