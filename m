From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Mon, 29 Apr 2013 16:14:21 +0300
Message-ID: <517E722D.4060808@freescale.com>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de> <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org> <1353800616.2590.4562.camel@edumazet-glaptop> <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de> <1353950255.7553.6.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de> <1354019816.7553.1585.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de> <1354023162.7553.1708.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de> <CAP=VYLrbFz4UBMthg+FOqc4g0jW_4=etE+jJK6YE_EaSj8cNLA@mail.gmail.com> <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BE@Exchange1.lawo.d
 e>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tino Keitel <tino.keitel@tikei.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:44174
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757638Ab3D2NOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 09:14:55 -0400
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BE@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I think I found a way to reproduce this easily, by forcing
timestamping on Tx with the following code change:

"""
drivers/net/ethernet/freescale/gianfar.c:
@@ -1210,6 +1210,8 @@ static int gfar_probe(struct platform_device *ofdev)
         /* Create all the sysfs files */
         gfar_init_sysfs(dev);

+       priv->hwts_tx_en = 1;
+
         /* Print out the device info */
         netdev_info(dev, "mac: %pM\n", dev->dev_addr);

@@ -2084,6 +2087,7 @@ static int gfar_start_xmit(struct sk_buff *skb, 
struct net_device *dev)
         txq = netdev_get_tx_queue(dev, rq);
         base = tx_queue->tx_bd_base;
         regs = tx_queue->grp->regs;
+       skb_shinfo(skb)->tx_flags |= SKBTX_HW_TSTAMP;

         /* check if time stamp should be generated */
         if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
"""

With this change, tx timeout triggers with the first packet sent.
I tested it on p1020/ p1010 boards, so it's not related to a specific
board.

The proposed fix (passes this test):
http://patchwork.ozlabs.org/patch/240365/

Does it work for you?
I'm a bit concerned about BQL support being added to Gianfar. Seems that
it only adds an overhead to this driver and possible failure points.
I'm not sure whether Gianfar has the issue of excessive H/W queuing.
I'm also wondering why only 5 or 6 eth drivers integrated BQL to date.

Regards,
Claudiu

On 2/6/2013 5:20 PM, Keitel, Tino (ALC NetworX GmbH) wrote:
> On Di, 2013-02-05 at 20:55 -0500, Paul Gortmaker wrote:
>> How critical is ptp2 for this?  And/or the platform details?  I can
>> try and reproduce it on an mpc8349 system and/or an mpc8548
>> system (and even an mpc8641D system) but I'd rather know that
>> was a meaningful chase and not a snipe hunt before going there.
>>
>> So, in that respect, a "If you run this, you will get this" type of
>> error message would be good.   I understand that may be too
>> idealistic, though.
>
> Hi,
>
> I'm using an MPC8313ERDB board and was able to reproduce it with a
> vanilla 3.6.7 kernel. There are some modifications to the device tree,
> though. I'll try to reproduce this with as few changes to the device
> tree as possible.
>
> Ptp2 is critical for the desired use. So far I also only was able to
> reproduce it with this ptp2 client.
>
> If it is a possible option for you, I could provide an affected device
> to make the issue easy to reproduce.
>
> Regards,
> Tino
