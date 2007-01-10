From: Christian Praehauser <cpraehaus@cosy.sbg.ac.at>
Subject: [2.4 PATCH] ethernet (net/ethernet/eth.c): eth_header() may produce
 invalid packets (with dest. addr. = 00:00:00:00:00:00)
Date: Wed, 10 Jan 2007 12:53:31 +0100
Message-ID: <45A4D3BB.9080304@cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	wtarreau@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dobermann.cosy.sbg.ac.at ([141.201.2.56]:45856 "EHLO
	dobermann.cosy.sbg.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932793AbXAJMWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 07:22:21 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, and sorry for bothering you with a patch you've already seen ;-).

From: Christian Praehauser, Department of Computer Sciences, University of Salzburg

This patch fixes a problem which has already been corrected in Linux-2.6.16 but was not back-ported to the 2.4 series. It is essentially the 
same as the patch for 2.6.16. An excerpt from the ChangeLog for Linux 2.6.16 is included below.

What is not described in the patch description for 2.6.16 is that this problem also arises when transmitting IP multicast packets. If you 
send an IP multicast stream over an ethernet network interface ethX and turn off ARP on ethX then Linux will produce an ethernet frame with 
a dest. addresses of 00:00:00:00:00:00 (which is invalid). As IP multicast addresses are directly mapped to HW (MAC) addresses without 
invoking any ARP protocol mechanisms - for IP4 this mapping is performed by the function ip_eth_mc_map - it makes perfect sense to do this 
even if ARP is disabled. Further, this problem may occur periodically, everytime the corresponding struct dst_entry is garbage-collected 
(e.g. ~ every 10 minutes).

 >
 >     [NET] ethernet: Fix first packet goes out with MAC 00:00:00:00:00:00
 >         When you turn off ARP on a netdevice then the first packet always goes
 >     out with a dstMAC of all zeroes. This is because the first packet is
 >     used to resolve ARP entries. Even though the ARP entry may be resolved
 >     (I tried by setting a static ARP entry for a host i was pinging from),
 >     it gets overwritten by virtue of having the netdevice disabling ARP.
 >         Subsequent packets go out fine with correct dstMAC address (which may
 >     be why people have ignored reporting this issue).
 >         To cut the story short:         the culprit code is in net/ethernet/eth.c::eth_header()
 >         ----
 >             /*
 >              *      Anyway, the loopback-device should never use this
 >     function...
 >              */
 >                 if (dev->flags & (IFF_LOOPBACK|IFF_NOARP))
 >             {
 >                     memset(eth->h_dest, 0, dev->addr_len);
 >                     return ETH_HLEN;
 >             }
 >             if(daddr)
 >             {
 >                     memcpy(eth->h_dest,daddr,dev->addr_len);
 >                     return ETH_HLEN;
 >             }
 >         ----
 >         Note how the h_dest is being reset when device has IFF_NOARP.
 >         As a note:
 >     All devices including loopback pass a daddr. loopback in fact passes
 >     a 0 all the time ;->     This means i can delete the check totaly or i can remove the IFF_NOARP
 >         Alexey says:
 >     --------------------
 >     I think, it was me who did this crap. It was so long ago I do not remember
 >     why it was made.
 >         I remember some troubles with dummy device. It tried to resolve
 >     addresses, apparently, without success and generated errors instead of
 >     blackholing. I think the problem was eventually solved at neighbour
 >     level.
 >         After some thinking I suspect the deletion of this chunk could change
 >     behaviour of some parts which do not use neighbour cache f.e. packet
 >     socket.
 >         I think safer approach would be to move this chunk after if (daddr).
 >     And the possibility to remove this completely could be analyzed later.
 >     --------------------

Signed-off-by: Christian Praehauser <cpraehaus@cosy.sbg.ac.at>

--- net/ethernet/eth.c.orig     2007-01-10 12:14:23.000000000 +0100
+++ net/ethernet/eth.c  2007-01-10 12:14:57.000000000 +0100
@@ -96,6 +96,12 @@
         else
                 memcpy(eth->h_source,dev->dev_addr,dev->addr_len);

+       if(daddr)
+       {
+               memcpy(eth->h_dest,daddr,dev->addr_len);
+               return dev->hard_header_len;
+       }
+
         /*
          *      Anyway, the loopback-device should never use this function...
          */
@@ -106,12 +112,6 @@
                 return(dev->hard_header_len);
         }

-       if(daddr)
-       {
-               memcpy(eth->h_dest,daddr,dev->addr_len);
-               return dev->hard_header_len;
-       }
-
         return -dev->hard_header_len;
  }

