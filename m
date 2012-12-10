From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: ipgre rss is broken since gro
Date: Mon, 10 Dec 2012 08:54:31 -0800
Message-ID: <1355158471.27891.44.camel@edumazet-glaptop>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
	 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
	 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:58993 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab2LJQyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 11:54:35 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1302984dak.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 08:54:35 -0800 (PST)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 11:32 +0000, Dmitry Kravkov wrote:

> CPU is not loaded at all 
> 
> > cat /proc/net/softnet_stat
> Please find attached.
> 
> For gre interface RX and DROP statistics are advancing simultaneously (by one each ICMP request):
> 
> [root@ ~]# ifconfig gre
> gre       Link encap:UNSPEC  HWaddr C0-A8-0A-40-73-72-83-D2-00-00-00-00-00-00-00-00
>           inet addr:8.0.0.1  P-t-P:8.0.0.1  Mask:255.255.255.0
>           inet6 addr: fe80::5efe:c0a8:a40/64 Scope:Link
>           UP POINTOPOINT RUNNING NOARP  MTU:1476  Metric:1
>           RX packets:1646824 errors:0 dropped:51610 overruns:0 frame:0
>           TX packets:140519 errors:1 dropped:0 overruns:0 carrier:1
>           collisions:0 txqueuelen:0
>           RX bytes:2357650904 (2.1 GiB)  TX bytes:7309072 (6.9 MiB)


dropped:51610  so obviously  one cpu is fully loaded.

I believe performance problem might come from the
skb_set_queue_mapping(skb, 0); in __skb_tunnel_rx()

So all packets are queued into a single GRO queue, instead of being
split as intended in multiple queues.

I cant find why we must clear queue_mapping, so could you try :


diff --git a/include/net/dst.h b/include/net/dst.h
index 9a78810..4cb27df 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -329,7 +329,6 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (!skb->l4_rxhash)
 		skb->rxhash = 0;
-	skb_set_queue_mapping(skb, 0);
 	skb_dst_drop(skb);
 	nf_reset(skb);
 }
