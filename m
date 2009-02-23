From: Ben McKeegan <ben@netservers.co.uk>
Subject: [PATCH] ppp_generic: fix multilink fragment MTU calculation
Date: Mon, 23 Feb 2009 17:31:35 +0000
Message-ID: <49A2DD77.10400@netservers.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When using MLPPP, the maximum size of a fragment is incorrectly 
calculated with an offset of +2.  When the MTU of underlying channels 
minus the multilink overhead is less than the MTU of the MLPPP bundle 
divided by the number of channels, the fragmentation algorithm is 
supposed to send maximally sized fragments down the channels and 
generate additional fragment(s) for the remainder, but due to the error 
in the fragment size calculation the earlier fragments exceed the 
underlying MTU and are lost.   This patch reduces the maximum fragment 
size by 2.

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>
---

We have successfully been running this patch on production routers for 
several months now using PPPoE as an underlying channel.  We are 
configuring a high MTU on a multilink enabled PPP device with a single 
underlying PPPoE channel running over an Ethernet device with a much 
lower MTU.  Thus our larger PPP frames get ML-fragmented with all 
fragments being sent down the same channel.  Without this patch the link 
does not work correctly, and tcpdump shows the kernel generating PPPoE 
frames 2 bytes longer than the MTU of the Ethernet which obviously do 
not make it out.  With this patch, the maximum size of the PPPoE frames 
correctly matches the Ethernet MTU and the link works correctly.

We believe this issue should affect other types of underlying channel in 
the same way, and more usually causing problems when a multilink bundle 
is running in a degraded state (i.e. with fewer than normal channels). 
I cannot see why the '+2' was put in the MTU calculation in the original 
code, but it looks like this feature might have always been broken.


--- linux-2.6.27.7.orig/drivers/net/ppp_generic.c       2008-11-20 
23:02:37.000000000 +0000
+++ linux-2.6.27.7/drivers/net/ppp_generic.c    2008-12-03 
14:43:21.000000000 +0000
@@ -1342,14 +1342,14 @@

                 /*
                  * Create a fragment for this channel of
-                * min(max(mtu+2-hdrlen, 4), fragsize, len) bytes.
-                * If mtu+2-hdrlen < 4, that is a ridiculously small
+                * min(max(mtu-hdrlen, 4), fragsize, len) bytes.
+                * If mtu-hdrlen < 4, that is a ridiculously small
                  * MTU, so we use mtu = 2 + hdrlen.
                  */
                 if (fragsize > len)
                         fragsize = len;
                 flen = fragsize;
-               mtu = pch->chan->mtu + 2 - hdrlen;
+               mtu = pch->chan->mtu - hdrlen;
                 if (mtu < 4)
                         mtu = 4;
                 if (flen > mtu)


-- 
Ben McKeegan
Netservers Limited


