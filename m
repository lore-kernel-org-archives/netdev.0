From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Thu, 20 Dec 2012 13:51:39 +0100
Message-ID: <1797374383.20121220135139@eikelenboom.it>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:34370
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab2LTMvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 07:51:51 -0500
In-Reply-To: <1355933869.21834.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, December 19, 2012, 5:17:49 PM, you wrote:

> On Wed, 2012-12-19 at 12:34 +0100, Sander Eikelenboom wrote:

>> Hi Ian,
>> 
>> It ran overnight and i haven't seen the warn_once trigger.
>> (but i also didn't with the previous patch)
>> 

> As I said, the miminum value to not trigger the warning was what Ian
> patch was doing, but it was still a not accurate estimation.

> Doing the real accounting might trigger slow transferts, or dropped
> packets because of socket limits (SNDBUF / RCVBUF) being hit sooner.

> So the real question was : If accounting for full pages, is your
> applications run as smooth as before, with no huge performance
> regression ?

Ok i have added some extra debug info (see diff's below), the code still uses the old calculation for truesize (in the hope to trigger the warn_on_once again), but also calculates the variants IanC came up with.

I haven't got a clear test case to trigger the warn_on_once, it happens just every once in a while during my normal usage and i'm not a netperf expert :-)
So at the moment i haven't been able to trigger the warn_on_once yet, but the results so far do seem to shed some light ..

- The first variant (current code) seems to be the most effcient and a good estimation *most* of the the, but sometimes triggers the warn_on_once in skb_try_coalesce.
- The first variant (current code) seems to always substract from the truesize for small packets.
- The second variant always seems keep the truesize as is for most of the small network traffic, but it also seems to work ok for larger packets.
- The third variant seems to be a pretty wasteful estimation.

So the last variant seems to be rather wasteful, and the second one the most accurate so far.

Eric:
     From the warn_on_once, delta should be smaller than len, but probably they should be as close together as possible.
     When you say "accurate estimation", what would be a acceptable difference between DELTA and LEN ?



[  116.965062] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  117.094538] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.094707] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.094869] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.095058] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.095216] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.096102] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.096311] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.096373] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.150398] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.150459] eth0: mtu:1500 data_len:54 len before:0 len after:54 truesize before:896 truesize after:694 nr_frags:1 variant1:-202(694) variant2:0(896) variant3:4096(4992)
[  117.536901] eth0: mtu:1500 data_len:53642 len before:0 len after:53642 truesize before:896 truesize after:54282 nr_frags:14 variant1:53386(54282) variant2:53386(54282) variant3:57344(58240)
[  117.537463] eth0: mtu:1500 data_len:15994 len before:0 len after:15994 truesize before:896 truesize after:16634 nr_frags:5 variant1:15738(16634) variant2:15738(16634) variant3:20480(21376)
[  117.537915] eth0: mtu:1500 data_len:17442 len before:0 len after:17442 truesize before:896 truesize after:18082 nr_frags:5 variant1:17186(18082) variant2:17186(18082) variant3:20480(21376)
[  117.538543] eth0: mtu:1500 data_len:18890 len before:0 len after:18890 truesize before:896 truesize after:19530 nr_frags:6 variant1:18634(19530) variant2:18634(19530) variant3:24576(25472)
[  117.539223] eth0: mtu:1500 data_len:13098 len before:0 len after:13098 truesize before:896 truesize after:13738 nr_frags:4 variant1:12842(13738) variant2:12842(13738) variant3:16384(17280)
[  117.539283] eth0: mtu:1500 data_len:7306 len before:0 len after:7306 truesize before:896 truesize after:7946 nr_frags:2 variant1:7050(7946) variant2:7050(7946) variant3:8192(9088)
[  117.539403] skbuff: to: (null) from: (null)  skb_try_coalesce: DELTA - LEN > 100 delta:7690 len:7240 from->truesize:7946 skb_headlen(from):190 skb_shinfo(to)->nr_frags:5 skb_shinfo(from)->nr_frags:2
[  117.540035] eth0: mtu:1500 data_len:4410 len before:0 len after:4410 truesize before:896 truesize after:5050 nr_frags:3 variant1:4154(5050) variant2:4304(5200) variant3:12288(13184)
[  117.540153] eth0: mtu:1500 data_len:1018 len before:0 len after:1018 truesize before:896 truesize after:1658 nr_frags:1 variant1:762(1658) variant2:762(1658) variant3:4096(4992)
[  121.981917] net_ratelimit: 27 callbacks suppressed
[  121.981960] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  122.985019] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  123.988308] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  124.991961] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  125.995003] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)
[  126.998324] eth0: mtu:1500 data_len:42 len before:0 len after:42 truesize before:896 truesize after:682 nr_frags:1 variant1:-214(682) variant2:0(896) variant3:4096(4992)



diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index c26e28b..8833e38 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -964,6 +964,7 @@ static int xennet_poll(struct napi_struct *napi, int budget)
        struct sk_buff_head tmpq;
        unsigned long flags;
        int err;
+       int tsz,len;

        spin_lock(&np->rx_lock);

@@ -1037,9 +1038,22 @@ err:
                 * receive throughout using the standard receive
                 * buffer size was cut by 25%(!!!).
                 */
-               skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
+
+
+
+
+                tsz = skb->truesize;
+                len = skb->len;
+                /* skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags; */
+                skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
                skb->len += skb->data_len;

+               net_warn_ratelimited("%s: mtu:%d data_len:%d len before:%d len after:%d truesize before:%d truesize after:%d nr_frags:%d variant1:%d(%d) variant2:%d(%d) variant3:%d(%d) \n",
+                        skb->dev->name, skb->dev->mtu, skb->data_len, len,  skb->len,tsz, skb->truesize, skb_shinfo(skb)->nr_frags,
+                        skb->data_len - RX_COPY_THRESHOLD, tsz + skb->data_len - RX_COPY_THRESHOLD ,
+                        skb->data_len - NETFRONT_SKB_CB(skb)->pull_to, tsz + skb->data_len - NETFRONT_SKB_CB(skb)->pull_to,
+                        PAGE_SIZE * skb_shinfo(skb)->nr_frags, tsz + (PAGE_SIZE * skb_shinfo(skb)->nr_frags));
+
                if (rx->flags & XEN_NETRXF_csum_blank)
                        skb->ip_summed = CHECKSUM_PARTIAL;
                else if (rx->flags & XEN_NETRXF_data_validated)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3ab989b..6d0cd86 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3471,6 +3471,16 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,

        WARN_ON_ONCE(delta < len);

+       if(delta < len) {
+               net_warn_ratelimited("to: %s from: %s  skb_try_coalesce: DELTA < LEN delta:%d len:%d from->truesize:%d skb_headlen(from):%d skb_shinfo(to)->nr_frags:%d skb_shinfo(from)->nr_frags:%d \n",
+                        to->dev->name, from->dev->name, delta, len, from->truesize, skb_headlen(from), skb_shinfo(to)->nr_frags, skb_shinfo(from)->nr_frags);
+       }
+
+       if (delta > len && delta - len > 100) {
+               net_warn_ratelimited("to: %s from: %s  skb_try_coalesce: DELTA - LEN > 100 delta:%d len:%d from->truesize:%d skb_headlen(from):%d skb_shinfo(to)->nr_frags:%d skb_shinfo(from)->nr_frags:%d \n",
+                        to->dev->name,from->dev->name, delta, len, from->truesize, skb_headlen(from), skb_shinfo(to)->nr_frags, skb_shinfo(from)->nr_frags);
+       }
+
        memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
               skb_shinfo(from)->frags,
               skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
