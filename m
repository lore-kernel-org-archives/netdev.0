From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: __napi_alloc_skb failures locking up the box
Date: Sat, 30 Apr 2016 12:54:12 -0700
Message-ID: <1462046052.5535.190.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160430192402.GA8366@raspberrypi.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160430192402.GA8366@raspberrypi.musicnaut.iki.fi>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-04-30 at 22:24 +0300, Aaro Koskinen wrote:
> Hi,
> 
> I have old NAS box (Thecus N2100) with 512 MB RAM, where rsync from NFS ->
> disk reliably results in temporary out-of-memory conditions.
> 
> When this happens the dmesg gets flooded with below logs. If the serial
> console logging is enabled, this will lock up the box completely and
> the backup is not making any progress.
> 
> Shouldn't these allocation failures be ratelimited somehow (or even made
> silent)? It doesn't sound right if I can lock up the system simply by
> copying files...

Agreed.

All napi_alloc_skb() callers handle failure just fine.

If they did not, a NULL deref would produce a proper stack dump.

When memory gets this tight, other traces will be dumped anyway.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 15d0df943466..0652709fe81a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2423,7 +2423,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
 static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
 					     unsigned int length)
 {
-	return __napi_alloc_skb(napi, length, GFP_ATOMIC);
+	return __napi_alloc_skb(napi, length, GFP_ATOMIC | __GFP_NOWARN);
 }
 void napi_consume_skb(struct sk_buff *skb, int budget);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
