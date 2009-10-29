From: "Neulinger, Nathan" <nneul@mst.edu>
Subject: RE: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 18:51:01 -0500
Message-ID: <846C5B546E47494CBBD796CA8CA1617EA3B43C@MST-VMAIL1.srv.mst.edu>
References: <20091029130036.1e61f415@nehalam> <846C5B546E47494CBBD796CA8CA1617EA3B439@MST-VMAIL1.srv.mst.edu> <20091029234756.GA1595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnip01-rolla-out.um.umsystem.edu ([209.106.229.55]:20961 "EHLO
	mxnip01-rolla-out.um.umsystem.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755224AbZJ2XvO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 19:51:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091029234756.GA1595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, it looks like it's broke here in ipgre_tunnel_init:

--- net/ipv4/ip_gre.c.orig      2009-10-29 18:45:29.335723326 -0500
+++ net/ipv4/ip_gre.c   2009-10-29 18:45:13.069697015 -0500
@@ -1240,7 +1240,8 @@
        tunnel->dev = dev;
        strcpy(tunnel->parms.name, dev->name);
 
-       memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+       /* assign random mac addr on init */
+       random_ether_addr(dev->dev_addr);
        memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
        if (iph->daddr) {

The above change fixes it for me, but I'm no expert on this chunk of
code. (Perhaps it it shouldn't set dev_addr at all?)

-- Nathan

------------------------------------------------------------
Nathan Neulinger                       nneul@mst.edu
Missouri S&T Information Technology    (573) 612-1412
System Administrator - Principal       KD0DMH


> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> Sent: Thursday, October 29, 2009 6:48 PM
> To: Neulinger, Nathan
> Cc: Stephen Hemminger; netdev@vger.kernel.org
> Subject: Re: How to use gretap with bridge?
> 
> On Thu, Oct 29, 2009 at 05:04:02PM -0500, Neulinger, Nathan wrote:
> > Now I see it - Stephen actually had it right on - the problem is
that
> > the gre tunnel is creating a MAC address on the fly based on the
> tunnel
> > endpoint ip address, so if the tunnel endpoint address starts with
an
> > odd number, it hits the multicast check in the bridging code. (I'm
> sure
> > that's what he meant and I just missed it entirely.)
> >
> > Simplest option would probably be to just mask off the first octet
> with
> > 0xFD or using the ip as the last four octets of the mac instead of
> the
> > first four.
> 
> This looks like a bug in either iproute or the kernel.  It's
> not supposed to set a MAC address unless the user specifically
> gives one.  If one is not given the kernel will generate a valid
> MAC address.
> 
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
