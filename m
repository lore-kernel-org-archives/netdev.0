From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Fix skb tail pointer in netpoll_send_udp()
Date: Tue, 12 Jun 2012 15:15:17 +0200
Message-ID: <1339506917.22704.134.camel@edumazet-glaptop>
References: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
	 <1339503766.22704.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38725 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab2FLNPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 09:15:21 -0400
Received: by eeit10 with SMTP id t10so2209799eei.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 06:15:20 -0700 (PDT)
In-Reply-To: <1339503766.22704.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 14:22 +0200, Eric Dumazet wrote:
> On Tue, 2012-06-12 at 13:26 +0300, Bogdan Hamciuc wrote:
> > As skb->tail wasn't updated after skb_copy_to_linear_data(), subsequent
> > calls to skb_realloc_headroom() (as made by an ethernet driver's
> > ndo_start_xmit routine) would only effectively copy the packet headers,
> > leaving garbage in the payload.
> > 
> > In the process, removed some unnecessary code.
> > 
> > Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> > ---
> >  net/core/netpoll.c |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index 3d84fb9..9a08068 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -362,22 +362,22 @@ EXPORT_SYMBOL(netpoll_send_skb_on_dev);
> >  
> >  void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
> >  {
> > -	int total_len, eth_len, ip_len, udp_len;
> > +	int total_len, ip_len, udp_len;
> >  	struct sk_buff *skb;
> >  	struct udphdr *udph;
> >  	struct iphdr *iph;
> >  	struct ethhdr *eth;
> >  
> >  	udp_len = len + sizeof(*udph);
> > -	ip_len = eth_len = udp_len + sizeof(*iph);
> > -	total_len = eth_len + ETH_HLEN + NET_IP_ALIGN;
> > +	ip_len = udp_len + sizeof(*iph);
> > +	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN;
> >  
> >  	skb = find_skb(np, total_len, total_len - len);
> >  	if (!skb)
> >  		return;
> >  
> >  	skb_copy_to_linear_data(skb, msg, len);
> > -	skb->len += len;
> > +	skb_put(skb, len);
> >  
> >  	skb_push(skb, sizeof(*udph));
> >  	skb_reset_transport_header(skb);
> 
> Hmm, real question is why skb_realloc_headroom() is even necessary...
> 
> I suspect we need to reserve more bytes.
> 
> 	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
> 
> or something like that ?
> 
> Which driver triggers the bug ?
> 

Please try the following :

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3d84fb9..1c6fb72 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -362,17 +362,18 @@ EXPORT_SYMBOL(netpoll_send_skb_on_dev);
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 {
-	int total_len, eth_len, ip_len, udp_len;
+	int total_len, ip_len, udp_len;
 	struct sk_buff *skb;
 	struct udphdr *udph;
 	struct iphdr *iph;
 	struct ethhdr *eth;
 
 	udp_len = len + sizeof(*udph);
-	ip_len = eth_len = udp_len + sizeof(*iph);
-	total_len = eth_len + ETH_HLEN + NET_IP_ALIGN;
+	ip_len = udp_len + sizeof(*iph);
+	total_len = ip_len + LL_RESERVED_SPACE(np->dev);
 
-	skb = find_skb(np, total_len, total_len - len);
+	skb = find_skb(np, total_len + np->dev->needed_tailroom,
+		       total_len - len);
 	if (!skb)
 		return;
 
