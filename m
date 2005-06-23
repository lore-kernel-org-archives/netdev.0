From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 08:14:11 -0400
Message-ID: <1119528852.11975.65.camel@localhost.localdomain>
References: <20050622180654.GX14251@wotan.suse.de>
	 <20050622.132241.21929037.davem@davemloft.net>
	 <42B9DA4D.5090103@cosmosbay.com>
	 <20050622.152325.15263910.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, davidm@hpl.hp.com,
        netdev <netdev@oss.sgi.com>, dada1@cosmosbay.com, ak@suse.de,
        leonid.grossman@neterion.com, becker@scyld.com, rick.jones2@hp.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050622.152325.15263910.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-22-06 at 15:23 -0700, David S. Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 22 Jun 2005 23:38:21 +0200
> 
> > Then maybe we could also play with prefetchw() in the case the
> > incoming frame is small enough to be copied to a new skb.
> 
> That's a good idea too.  In fact, this would deal with platforms
> that use non-temporal stores in their memcpy() implementation.

For the fans of the e1000 (or even the tg3 deprived people), heres a 
patch which originated from David Mosberger that i played around (about
9 months back) - it will need some hand patching for the latest driver.
Similar approach: prefetch skb->data,twiddle twiddle not little star,
touch header.

I found the aggressive mode effective on a xeon but i belive David is
using this on x86_64. So Lennert, I lied to you saying it was never
effective on x86. You just have to do the right juju such as factoring
in the memory load-latency and how much cache you have on your specific
CPU.
CCing davidm (in addition To: davem of course ;->) so he may provide
more insight on his tests.

Interesting of course is if you miss the "twiddle here" (as i saw in my
experiments) and do the obvious (such as defining AGGRESSIVE to 0), you
infact end up paying a penalty in performance.

cheers,
jamal

===== drivers/net/e1000/e1000_main.c 1.134 vs edited =====
--- 1.134/drivers/net/e1000/e1000_main.c        2004-09-12 16:52:48
-07:00
+++ edited/drivers/net/e1000/e1000_main.c       2004-09-30 06:05:11
-07:00
@@ -2278,12 +2278,30 @@
        uint8_t last_byte;
        unsigned int i;
        boolean_t cleaned = FALSE;
+#define AGGRESSIVE 1
 
        i = rx_ring->next_to_clean;
+#if AGGRESSIVE
+       prefetch(rx_ring->buffer_info[i].skb->data);
+#endif
        rx_desc = E1000_RX_DESC(*rx_ring, i);
 
        while(rx_desc->status & E1000_RXD_STAT_DD) {
                buffer_info = &rx_ring->buffer_info[i];
+# if AGGRESSIVE
+               {
+                       struct e1000_rx_desc *next_rx;
+                       unsigned int j = i + 1;
+
+                       if (j == rx_ring->count)
+                               j = 0;
+                       next_rx = E1000_RX_DESC(*rx_ring, j);
+                       if (next_rx->status & E1000_RXD_STAT_DD)
+                               prefetch(rx_ring->buffer_info[j].skb->data);
+               }
+# else
+               prefetch(buffer_info->skb->data);
+# endif
 #ifdef CONFIG_E1000_NAPI
                if(*work_done >= work_to_do)
                        break;
