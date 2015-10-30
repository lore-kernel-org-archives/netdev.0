From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] tcp: attach SYNACK messages to request sockets instead
 of listener
Date: Fri, 30 Oct 2015 13:18:51 -0700
Message-ID: <1446236331.6254.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446159521.6254.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB0770DDDA95027A39BF078CE6CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446235356.6254.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34472 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760747AbbJ3USx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:18:53 -0400
Received: by padhk11 with SMTP id hk11so83644132pad.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:18:53 -0700 (PDT)
In-Reply-To: <1446235356.6254.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 13:02 -0700, Eric Dumazet wrote:

> So it looks like you have a device with a very big hh_len
> 
> MAX_TCP_HEADER is not enough space to hold all headers, and this is the
> bug that needs to be fixed. This is scary to realloc all tcp packets !
> 

drivers/net/hyperv/netvsc_drv.c sets a needed_headroom of 220 bytes :(

Could you try :

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ac653b7b8ac..7dbdd29076be 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -132,8 +132,10 @@ static inline bool dev_xmit_complete(int rc)
  *	used.
  */
 
-#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
-# if defined(CONFIG_MAC80211_MESH)
+#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25) || IS_ENABLED(CONFIG_HYPERV_NET)
+# if IS_ENABLED(CONFIG_HYPERV_NET)
+# define LL_MAX_HEADER 384
+# elif defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
 # else
 #  define LL_MAX_HEADER 96
