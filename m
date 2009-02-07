From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_dma: call dmaengine_get only if NET_DMA enabled
Date: Fri, 06 Feb 2009 21:55:33 -0800 (PST)
Message-ID: <20090206.215533.166740686.davem@davemloft.net>
References: <20090206.140912.40800913.davem@davemloft.net>
	<e9c3a7c20902061452r40a97fa2p1fccfa78e3905458@mail.gmail.com>
	<20090206.192910.42610645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anemo@mba.ocn.ne.jp, maciej.sosnowski@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZBGFzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 00:55:36 -0500
In-Reply-To: <20090206.192910.42610645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 06 Feb 2009 19:29:10 -0800 (PST)

> From: Dan Williams <dan.j.williams@intel.com>
> Date: Fri, 6 Feb 2009 15:52:35 -0700
> 
> > Yes, it has been on the todo list for a while, but I eventually want
> > the net case to look more like the raid case.  I.e. have one code path
> > that picks async versus sync at runtime, with the option to compile
> > out async support with header file ifdefs only.
> 
> And how does any of that get us any closer to a fix right now
> for this problem that doesn't require an ifdef?
> 
> Someone please work on this.

I guess that'd end up being me....

How about something like this?

diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 3e0f64c..3e68469 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -282,6 +282,18 @@ static inline void dmaengine_put(void)
 }
 #endif
 
+#ifdef CONFIG_NET_DMA
+#define net_dmaengine_get()	dmaengine_get()
+#define net_dmaengine_put()	dmaengine_put()
+#else
+static inline void net_dmaengine_get(void)
+{
+}
+static inline void net_dmaengine_put(void)
+{
+}
+#endif
+
 dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
 	void *dest, void *src, size_t len);
 dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5379b0c..a17e006 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1090,7 +1090,7 @@ int dev_open(struct net_device *dev)
 		/*
 		 *	Enable NET_DMA
 		 */
-		dmaengine_get();
+		net_dmaengine_get();
 
 		/*
 		 *	Initialize multicasting status
@@ -1172,7 +1172,7 @@ int dev_close(struct net_device *dev)
 	/*
 	 *	Shutdown NET_DMA
 	 */
-	dmaengine_put();
+	net_dmaengine_put();
 
 	return 0;
 }
