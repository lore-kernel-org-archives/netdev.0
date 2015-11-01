From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Sun, 01 Nov 2015 09:20:59 -0800
Message-ID: <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446159521.6254.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB0770DDDA95027A39BF078CE6CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446235356.6254.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446236331.6254.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33271 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbKARVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:21:02 -0500
Received: by padhy1 with SMTP id hy1so116996316pad.0
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 09:21:01 -0800 (PST)
In-Reply-To: <1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

My recent commit, attaching SYNACK messages to request sockets
exposed a too small LL_MAX_HEADER when netvsc_drv.c is in use,
because this driver sets a needed_headroom of 220 bytes.

Increase LL_MAX_HEADER in this case, to avoid a realloc of all
TCP frames.

In another patch, I'll make skb_set_owner_w() more robust.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Bisected-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 include/linux/netdevice.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ac653b7b8ac..04e3864e660e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -132,8 +132,10 @@ static inline bool dev_xmit_complete(int rc)
  *	used.
  */
 
-#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
-# if defined(CONFIG_MAC80211_MESH)
+#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25) || IS_ENABLED(CONFIG_HYPERV_NET)
+# if IS_ENABLED(CONFIG_HYPERV_NET)
+# define LL_MAX_HEADER 256
+# elif defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
 # else
 #  define LL_MAX_HEADER 96
