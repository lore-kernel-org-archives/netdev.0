From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH next-next 4/6] net: Call skb_checksum_init in IPv4
Date: Mon, 07 Apr 2014 10:30:30 -0700
Message-ID: <1396891830.2874.38.camel@joe-AO722>
References: <alpine.DEB.2.02.1404041721170.21628@tomh.mtv.corp.google.com>
	 <20140407.131356.1060173493402786873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0090.hostedemail.com ([216.40.44.90]:60739 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751938AbaDGRae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:30:34 -0400
In-Reply-To: <20140407.131356.1060173493402786873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-07 at 13:13 -0400, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 4 Apr 2014 17:27:36 -0700 (PDT)
> 
> > @@ -1454,6 +1454,13 @@ out_unlock:
> >  	return err;
> >  }
> >  
> > +__wsum inet_pseudo_compute(struct sk_buff *skb, int proto)
> > +{
> > +	return csum_tcpudp_nofold(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
> > +				  skb->len, proto, 0);
> > +}
> > +EXPORT_SYMBOL(inet_pseudo_compute);
> 
> This is just adjusting arguments passed into to another inline
> function, please put this in a header and make it an inline too.

as ip_hdr involves a calculation via 

include/linux/ip.h:static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
include/linux/ip.h-{
include/linux/ip.h-     return (struct iphdr *)skb_network_header(skb);
include/linux/ip.h-}

and

include/linux/skbuff.h:static inline unsigned char *skb_network_header(const struct sk_buff *skb)
include/linux/skbuff.h-{
include/linux/skbuff.h- return skb->head + skb->network_header;
include/linux/skbuff.h-}

I believe you could save an addition by using a temporary for ip_hdr

static inline __wsum inet_pseudo_compute(struct sk_buff *skb, int proto)
{
	const struct iphdr *iph = ip_hdr(skb);

	return csum_tcpudp_nofold(iph->saddr, iph->daddr, skb->len, proto, 0);
}
