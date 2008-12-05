From: Pekka Savola <pekkas@netcore.fi>
Subject: IPv6 multicast bind(), esp. v4-mapped addresses
Date: Fri, 5 Dec 2008 08:42:37 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0812050820380.28482@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:46416 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbYLEGml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 01:42:41 -0500
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id mB56gbRp029252
	for <netdev@vger.kernel.org>; Fri, 5 Dec 2008 08:42:37 +0200
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id mB56gbxN029248
	for <netdev@vger.kernel.org>; Fri, 5 Dec 2008 08:42:37 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Java multicast API uses IPv6 sockets internally unless IPv6 is 
disabled.  In other APIs as well it might be beneficial to be able to 
use IPv4 through IPv6 mapped addresses.  This works fine with unicast, 
but there are problems with this in multicast (I've also included 
broadcast here because ipv4 side does that, I don't see the case for 
it myself).

Specifically, bind() to a v6-mapped v4 multicast address fails with 
EADDRNOTAVAIL:

bind(7, {sa_family=AF_INET6, sin6_port=htons(2000), 
inet_pton(AF_INET6, "::ffff:233.12.174.101", &sin6_addr), 
sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot 
assign requested address).

Two questions:

  1) should this be supported?  I think we're talking about a change in
     net/ipv6/af_inet6.c, replacing something like (not tested, adapted
     from net/ipv4/af_inet.c):

273         if (addr_type == IPV6_ADDR_MAPPED) {
274                 v4addr = addr->sin6_addr.s6_addr32[3];
275                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
276                         err = -EADDRNOTAVAIL;
277                         goto out;
278                 }
279         } else {

with:

          if (addr_type == IPV6_ADDR_MAPPED) {
                  v4addr = addr->sin6_addr.s6_addr32[3];
 		 if (inet_addr_type(net, v4addr) == RTN_MULTICAST ||
 		     inet_addr_type(net, v4addr) == RTN_BROADCAST) {
 			inet->saddr = 0; /* Use device */
                  } else {
 	                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
 	                         err = -EADDRNOTAVAIL;
 	                         goto out;
 	                 }
 		}
          } else {


  2) it appears that ip_nonlocal_bind sysctl only supports ipv4.
     Similar option or applying the same for v6 may be useful,
     especially if 1) is not changed, such a toggle might be useful
     with v6 as well.

You can see some specification discussion on this topic here:
http://www.mail-archive.com/ipng@sunroof.eng.sun.com/msg02134.html

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
