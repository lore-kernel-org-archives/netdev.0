From: Karlis Peisenieks <karlis@mt.lv>
Subject: Re: IFF_NOARP & broadcasting [2]
Date: Thu, 25 Jul 2002 16:32:23 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020725163223.A13299@karlis>
References: <20020724190421.A2449@karlis> <200207241652.UAA19057@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200207241652.UAA19057@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Wed, Jul 24, 2002 at 19:52:55 +0300
List-Id: netdev.vger.kernel.org

On 2002.07.24 19:52 kuznet@ms2.inr.ac.ru wrote:

> No, it is surely not impossible. f.e.
> 
> ip neigh add 255.255.255.255 dev dummy0 lladdr ff:ff:ff:ff:ff:ff

Ok, but even in this case there is minor problem. And it lies in
net/ethernet/eth.c - eth_header.

neigh_resolve_output creates header cache with correct ll source and ll
destination as in neighbour, but uses dev->hard_header to build header for
first packet. And eth_header has code:

        if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) 
        {
                memset(eth->h_dest, 0, dev->addr_len);
                return(dev->hard_header_len);
        }

which explicitly sets ll destination to all 0s. For all next packets
hh_cache is used and they get correct ll address (as in neighbour).

Please comment on this patch :) :

--- eth.c.orig	Thu Jul 25 16:16:37 2002
+++ eth.c	Thu Jul 25 16:16:47 2002
@@ -100,7 +100,7 @@
 	 *	Anyway, the loopback-device should never use this
function... 
 	 */
 
-	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) 
+	if (dev->flags & IFF_LOOPBACK) 
 	{
 		memset(eth->h_dest, 0, dev->addr_len);
 		return(dev->hard_header_len);



Karlis
