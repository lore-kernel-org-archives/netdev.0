From: =?iso-8859-1?Q?Michal_Ruzicka?= <michal.ruzicka@comstar.cz>
Subject: Possible leak of multicast source filter sctructure
Date: Thu, 10 Aug 2006 14:07:06 +0200
Message-ID: <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>	<44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi> <20060810.174635.42119608.yoshfuji@linux-ipv6.org> <44DB0870.6000902@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0196_01C6BC86.43766530"
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:9902 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1161193AbWHJMIT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 08:08:19 -0400
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0196_01C6BC86.43766530
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

Hi all!
It seems to me that there is a leak of struct ip_sf_socklist in the 
ip_mc_drop_socket function (in net/ipv4/igmp.c) which is called on socket 
close.

This patch corrects it:

diff -Naur linux-2.6.17.8.orig/net/ipv4/igmp.c 
linux-2.6.17.8/net/ipv4/igmp.c
--- linux-2.6.17.8.orig/net/ipv4/igmp.c 2006-08-07 06:18:54.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c 2006-08-10 10:38:04.000000000 +0200
@@ -2206,9 +2206,10 @@
    (void) ip_mc_leave_src(sk, iml, in_dev);
    ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
    in_dev_put(in_dev);
-  }
-  sock_kfree_s(sk, iml, sizeof(*iml));
+  } else if (iml->sflist != NULL)
+   sock_kfree_s(sk, iml->sflist, IP_SFLSIZE(iml->sflist->sl_max));

+  sock_kfree_s(sk, iml, sizeof(*iml));
  }
  rtnl_unlock();
 }

The leak only happens if there are some multicast source filters set on a 
socket wich are bound to an interface that does not exist any more, as in 
the following scenario:
1. create a temporary interface (say GRE tunnel)
3. join a multicast group an set a source filter on the temporary interface 
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

------=_NextPart_000_0196_01C6BC86.43766530
Content-Type: application/octet-stream;
	name="linux-2.6.17.8-mc_sf_leak.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="linux-2.6.17.8-mc_sf_leak.patch"

diff -Naur linux-2.6.17.8.orig/net/ipv4/igmp.c =
linux-2.6.17.8/net/ipv4/igmp.c=0A=
--- linux-2.6.17.8.orig/net/ipv4/igmp.c	2006-08-07 06:18:54.000000000 =
+0200=0A=
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-10 10:38:04.000000000 +0200=0A=
@@ -2206,9 +2206,10 @@=0A=
 			(void) ip_mc_leave_src(sk, iml, in_dev);=0A=
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);=0A=
 			in_dev_put(in_dev);=0A=
-		}=0A=
-		sock_kfree_s(sk, iml, sizeof(*iml));=0A=
+		} else if (iml->sflist !=3D NULL)=0A=
+			sock_kfree_s(sk, iml->sflist, IP_SFLSIZE(iml->sflist->sl_max));=0A=
 =0A=
+		sock_kfree_s(sk, iml, sizeof(*iml));=0A=
 	}=0A=
 	rtnl_unlock();=0A=
 }=0A=

------=_NextPart_000_0196_01C6BC86.43766530--

