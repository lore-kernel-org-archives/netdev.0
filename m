From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Mon, 12 May 2008 20:17:51 -0700 (PDT)
Message-ID: <20080512.201751.114868351.davem@davemloft.net>
References: <20080502.163334.148944203.davem@davemloft.net>
	<1209807477.3987.9.camel@johannes.berg>
	<1209824720.1475.6.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754270AbYEMDR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 23:17:57 -0400
In-Reply-To: <1209824720.1475.6.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 03 May 2008 16:25:20 +0200

[ Ok, I'm going through all of this, we'll solve the problems one at
  a time and get this all taken care of.  ]

> The worst case is probably prism54 usb devices which by itself need 76
> bytes headroom for the USB buffer, and then when we say run mesh on top
> of it we'll need a total of 122 bytes. Needless to say, it cannot do s/g
> operation.
 ...
> Should we increase the LL_MAX_HEADER constant to 40 (no mesh networking)
> or 46 for when 802.11 (with mesh networking) is configured into the
> kernel? Most people probably don't run an IPIP tunnel over wireless yet
> configure them in (especially distros) so that might be why we never saw
> the problem before.

Thanks for these numbers.

Based upon them I will adjust LL_MAX_HEADER as follows:

net: Set LL_MAX_HEADER properly for wireless.

Wireless networking, particularly with MESH enabled, has
quite strong requirements for link-layer header space.

Based upon some numbers and descriptions from Johannes Berg
we use 96 (same as AX25) for plain wireless, and with
mesh enabled we use 128.

In the process, simplify the cpp conditional logic here by
ordering the cases by those needing the most space down
to those needing the least case.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7469017..a3fb57f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -93,14 +93,16 @@ struct wireless_dev;
  *	used.
  */
  
-#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(CONFIG_TR)
-#define LL_MAX_HEADER	32
+#if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+# if defined(CONFIG_MAC80211_MESH)
+#  define LL_MAX_HEADER 128
+# else
+#  define LL_MAX_HEADER 96
+# endif
+#elif defined(CONFIG_TR)
+# define LL_MAX_HEADER 48
 #else
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-#define LL_MAX_HEADER	96
-#else
-#define LL_MAX_HEADER	48
-#endif
+# define LL_MAX_HEADER 32
 #endif
 
 #if !defined(CONFIG_NET_IPIP) && !defined(CONFIG_NET_IPIP_MODULE) && \
-- 
1.5.5.1.57.g5909c

