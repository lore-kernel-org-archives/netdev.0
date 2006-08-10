From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Possible leak of multicast source filter sctructure #2
Date: Thu, 10 Aug 2006 17:57:38 +0100
Message-ID: <200608101557.k7AFvc6u004054@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:61885 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1161362AbWHJP6Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 11:58:16 -0400
Content-Disposition: inline
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Took some time but this time the inlined patch should be OK.

Hi all!
It seems to me that there is a leak of struct ip_sf_socklist in the 
ip_mc_drop_socket function (in net/ipv4/igmp.c) which is called on socket 
close.

This patch corrects it:

diff -Naur linux-2.6.17.8.orig/net/ipv4/igmp.c linux-2.6.17.8/net/ipv4/igmp.c
--- linux-2.6.17.8.orig/net/ipv4/igmp.c	2006-08-07 06:18:54.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-10 10:38:04.000000000 +0200
@@ -2206,9 +2206,10 @@
 			(void) ip_mc_leave_src(sk, iml, in_dev);
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 			in_dev_put(in_dev);
-		}
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		} else if (iml->sflist != NULL)
+			sock_kfree_s(sk, iml->sflist, IP_SFLSIZE(iml->sflist->sl_max));
 
+		sock_kfree_s(sk, iml, sizeof(*iml));
 	}
 	rtnl_unlock();
 }


The leak only happens if there are some multicast source filters set on a 
socket wich are bound to an interface that does not exist any more, as in 
the following scenario:
1. create a temporary interface (say GRE tunnel)
2. create a socket
3. join a multicast group and set a source filter on the temporary interface 
via MCAST_JOIN_SOURCE_GROUP setsockopt call
4. destroy the temporary interface
5. close the socket

This sequence of things eventually leads to a call of ip_mc_drop_socket 
function, which fails to free the soucre filter structure ip_sf_socklist 
pointed to from members of socket's multicast addresses list. This structure 
is normally freed in ip_mc_leave_src function but this function is not 
called in this scenario because the interface that the multicast group is 
joined on does not exist any more.

Thanks
Michal Ruzicka 

