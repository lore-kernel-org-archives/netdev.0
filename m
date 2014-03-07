From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [Bug] net/fec on i.MX28: promiscuous mode lost after reconnecting
 network cable
Date: Fri, 07 Mar 2014 17:00:04 +0100
Message-ID: <5319ED04.9070003@i2se.com>
References: <5318400C.8060508@i2se.com>	<CAOMZO5B-1koJdQRdE7SQU07K9McZZaiPAa+rookdxVL5vvPJvA@mail.gmail.com> <CAHrpEqQewTSAWveoGdRvUF-R-uYAC7ZDAAYDH8DKg8EgmYpM0w@mail.gmail.com> <f7c8b4dab2114552b919310c2a5bb444@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.arm.linux.org.uk"
	<linux-arm-kernel@lists.arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Sascha Hauer <kernel@pengutronix.de>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Frank Li <lznuaa@gmail.com>, Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:49637 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbaCGQAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 11:00:04 -0500
In-Reply-To: <f7c8b4dab2114552b919310c2a5bb444@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 07.03.2014 03:10, schrieb fugang.duan@freescale.com:
> From: Frank Li <lznuaa@gmail.com>
> Data: Friday, March 07, 2014 1:43 AM
>
>> To: Fabio Estevam
>> Cc: Stefan Wahren; David Miller; netdev@vger.kernel.org; linux-arm-
>> kernel@lists.arm.linux.org.uk; Shawn Guo; Estevam Fabio-R49496; Li Frank-B20596;
>> Duan Fugang-B38611; Sascha Hauer
>> Subject: Re: [Bug] net/fec on i.MX28: promiscuous mode lost after reconnecting
>> network cable
>>
>> On Thu, Mar 6, 2014 at 4:30 AM, Fabio Estevam <festevam@gmail.com> wrote:
>>> Adding some more folks on Cc.
>>>
>>> On Thu, Mar 6, 2014 at 6:29 AM, Stefan Wahren <stefan.wahren@i2se.com> wrote:
>>>> Hello,
>>>>
>>>> i'm using a i.MX28 custom board (I2SE Duckbill) with 2 different
>>>> Ethernet interfaces. Both interfaces should be used as bridge using
>>>> bridge utils. One Ethernet interface is the buildin fec and the other
>>>> is connect by spi. The board runs under Linux mainline 3.10. But the
>>>> following problem still occurs on 3.14-rc4.
>>>>
>>>> Here is the problem, if i disconnect and reconnect the Ethernet cable
>>>> on the buildin fec (eth0), the bridge says the port comes up, but it doesn't
>> work.
>>>> After that any traffic to the fec is okay, but traffic "through" the
>>>> bridge is lost. But i expect no traffic is lost, after reconnect the network
>> cable.
>>>> If i reset the board without disconnecting the cables, the traffic "through"
>>>> the bridge works. If i force the promiscuous mode on the fec (eth0)
>>>> after the reconnect, the bridge works too:
>>>>
>>>> ifconfig eth0 promisc
>>>>
>>>> After that, i made some research and probably found the cause of the
>>>> problem. In the case that the bridge works (link state connected
>>>> since
>>>> reboot) the register HW_ENET_MAC_RCR of the i.MX28 returns 0x45EE011C
>>>> (PROM=1, promiscuous mode on). Then I disconnect the ethernet cable
>>>> and reconnect it. After that the register returns 0x45EE0114 (PROM=0,
>>>> promiscuous mode off) and the bridge doesn't work.
>>>>
>>>> Based on this information, i created a patch against Linux 3.10. I'm
>>>> not sure it's a good solution but it works. After a fec reset all
>>>> register values of HW_ENET_MAC_RCR must be restored, but fec_restart
>>>> do not handle them at all. So set_multicast_list is called after
>>>> fec_restart to restore the promiscuous mode of the fec.
>>>>
>>>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>>>> b/drivers/net/ethernet/freescale/fec_main.c
>>>> index d48099f..cb6b66e 100644
>>>> --- a/drivers/net/ethernet/freescale/fec_main.c
>>>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>>>> @@ -1063,6 +1063,8 @@ static void fec_get_mac(struct net_device
>>>> *ndev)
>>>>
>>>>   /*
>>>> ---------------------------------------------------------------------
>>>> ---- */
>>>>
>>>> +static void set_multicast_list(struct net_device *ndev);
>>>> +
>>>>   /*
>>>>    * Phy section
>>>>    */
>>>> @@ -1093,8 +1095,10 @@ static void fec_enet_adjust_link(struct
>>>> net_device
>>>> *ndev)
>>>>           }
>>>>
>>>>           /* if any of the above changed restart the FEC */
>>>> -        if (status_change)
>>>> +        if (status_change) {
>>>>               fec_restart(ndev, phy_dev->duplex);
>>>> +            set_multicast_list(ndev);
>>>> +        }
>>>>       } else {
>>>>           if (fep->link) {
>>>>               fec_stop(ndev);
>>>>
>>>> Is this solution correct?
>> There are many places to call fec_resart.
>> I suggest call set_multicase_list in fec_restart function.
>>
> Yes, we had called set_multicase_list() in fec_restart() function.
> The patch is redundant.

thanks for the review. I didn't look too long at the linux-3.14-rc4, so 
i didn't see that. I only know that my problem is still reproducable in 
linux-3.14-rc5.

But i think i know why the problem still occurs. Both functions 
set_multicast_list() and fec_restart() write into the register 
FEC_R_CNTRL. The call of set_multicast_list() is too soon and has no 
effect in my case. The reason is that the register FEC_R_CNTRL is 
completly overwritten by the local variable rcntl of fec_restart.

Here is a patch against linux-3.14-rc5 which fixes my problem. I moved 
the function call to set_multicast_list() behind the register write to 
FEC_R_CNTRL.

--- linux-3.14-rc5-old/drivers/net/ethernet/freescale/fec_main.c 
2014-03-03 03:56:16.000000000 +0100
+++ linux-3.14-rc5/drivers/net/ethernet/freescale/fec_main.c 2014-03-07 
16:38:16.564026150 +0100
@@ -527,13 +527,6 @@
      /* Clear any outstanding interrupt. */
      writel(0xffc00000, fep->hwp + FEC_IEVENT);

-    /* Setup multicast filter. */
-    set_multicast_list(ndev);
-#ifndef CONFIG_M5272
-    writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
-    writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-#endif
-
      /* Set maximum receive buffer size. */
      writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);

@@ -654,6 +647,13 @@

      writel(rcntl, fep->hwp + FEC_R_CNTRL);

+    /* Setup multicast filter. */
+    set_multicast_list(ndev);
+#ifndef CONFIG_M5272
+    writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+    writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
+#endif
+
      if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
          /* enable ENET endian swap */
          ecntl |= (1 << 8);

Is this better? If so i'll create a proper patch.

BR Stefan

>>>> Do you need more information?
>>>>
>>>> Best regards
>>>> Stefan Wahren
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org More majordomo
>>>> info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org More majordomo info
>>> at  http://vger.kernel.org/majordomo-info.html
