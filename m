From: lepton <ytht.net@gmail.com>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Wed, 19 Sep 2007 23:55:54 +0800
Message-ID: <20070919155554.GA11710@router.lepton.home>
References: <20070919093648.GA7491@router.lepton.home> <46F13999.30700@trash.net> <46F13D7D.6010603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lepton <ytht.net@gmail.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:10280 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbXISP5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:57:03 -0400
Received: by rv-out-0910.google.com with SMTP id k20so222087rvb
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 08:57:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <46F13D7D.6010603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, you are right.
What do you think about this:
For all packets can be sent out, we just disable 
all things in sk_route_caps in ip_route_me_harder

diff -X linux-2.6.22.6/Documentation/dontdiff -pru linux-2.6.22.6/net/ipv4/netfilter.c linux-2.6.22.6-lepton/net/ipv4/netfilter.c
--- linux-2.6.22.6/net/ipv4/netfilter.c	2007-09-14 17:41:18.000000000 +0800
+++ linux-2.6.22.6-lepton/net/ipv4/netfilter.c	2007-09-19 23:52:11.000000000 +0800
@@ -57,6 +57,10 @@ int ip_route_me_harder(struct sk_buff **
 	if ((*pskb)->dst->error)
 		return -1;
 
+	if((*pskb)->sk&&sk->sk_route_caps) 
+		/* This is overkill, but it is safe and simple */
+		sk->sk_route_caps=0;
+
 #ifdef CONFIG_XFRM
 	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED) &&
 	    xfrm_decode_session(*pskb, &fl, AF_INET) == 0)

On Wed, Sep 19, 2007 at 05:17:17PM +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > lepton wrote:
> > 
> >>Hi,
> >>  For local src packets, it is better to update sk_route_caps in
> >>  ip_route_me_harder.
> > 
> > 
> > 
> > This seems like a good idea to me. But why only for local src
> > (address) packets? This function can also be used for locally
> > generated packet that have been (f.i.) NATed to a foreign
> > address ...
> 
> 
> Actually, I'm afraid it might break some setups. Rerouting is
> done per packet, but if we cache the dst_entry for the socket,
> all packets from that socket will be routed similar.
> 
