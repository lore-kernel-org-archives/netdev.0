From: Andreas Jaggi <aj@open.ch>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Tue, 14 Jul 2009 16:21:51 +0200
Message-ID: <20090714142151.GA8461@urbino.open.ch>
References: <20090713133225.GA20946@urbino.open.ch> <20090713.104433.244099298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	davem@davemloft.net
To: Wojtek Sawasciuk <voyo@no-ip.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:56300 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbZGNOVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 10:21:40 -0400
Content-Disposition: inline
In-Reply-To: <20090713.104433.244099298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2009 at 01:39:48PM +0100, Wojtek Sawasciuk wrote:
> I think I have similar problems to yours, and I spotted your email on  
> the lists when googling :)
> Andreas, sorry but I think your patch is unnecessary, at last in this form.
> From long time there is possibility to create tunnel with tos options,  
> you can use "inherit" or any other value to set it to encapsulated 
> packets.
>
> ip tun add mode gre name tun1 remote 1.2.3.5 local 10.0.0.234 tos inherit
> or
> ip tun add mode gre name tun2 remote 1.2.3.6 local 10.0.0.234 tos 2
>
> and its working, *almost* ok.
> only problem is when you set tos value with bit 1 set in it, regarding  
> this fragment of code from ip_gre.c , in ipgre_tunnel_xmit function:
>
>        tos = tiph->tos;
>        if (tos&1) {
>                if (skb->protocol == htons(ETH_P_IP))
>                        tos = old_iph->tos;
>                tos &= ~1;
>        }
>
> (ie. set tos to 2 - it will replicate it to 2, set tos to 3 - it will  
> change it to 2).
>
> IHMO it should be replaced to use maybe MBZ bit (look on RFC1349) ,  
> instead of bit 1 , to pass on value of tos , from tunnel parameter to IP  
> header.
> and this should be sufficient to make it work properly.

You're right, my patch in this form is not necessary.

But as you point out, there is a bug in the handling of the ToS/DiffServ
bits in GRE.
iproute2 and the Linux GRE driver use a tos value of 1 to indicate an
'inherit'/'copy-tos' behavior (and then clear this bit before using the
tos value in the IP header of the encapsulation GRE packet).

This was fine for RFC1349 where this bit is defined as MBZ/must-be-zero.
But with RFC3168, this bit (and the other previously unused one in the tos field)
are used for the ECN bits (ECT + CE). Therefore a tos value of 1 is 'legal' and
conflicts with the 'inherit'/'copy-tos' indication of iproute2 and the
Linux GRE driver.

This creates the problem you described, where IP packets who have a tos
value of 1 (with the ECT bit set to 1) are handled with the 'inherit'/'copy-tos'
mechanism and the resulting GRE IP header has a tos value of 0! (the ECT bit
set to 0 instead of 1)
