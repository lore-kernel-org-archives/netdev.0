From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: Re: [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Thu, 5 Apr 2007 12:59:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: irda-users@lists.sourceforge.net, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, a simple analysis reveals the recursive spinlock:

On Thu, 5 Apr 2007, Guennadi Liakhovetski wrote:

> [<bf12b220>] (ppp_channel_push+0x0/0xc8 [ppp_generic]) from [<bf12bf98>] (ppp_output_wakeup+0x18/0x1c [ppp_generic])
===>		^^^^^^^^^^^^^^^^
>  r7 = C38F42BC  r6 = C38F4200  r5 = C38F4200  r4 = 00000000

===>	spin_lock_bh(&pch->downl);

> [<bf12bf80>] (ppp_output_wakeup+0x0/0x1c [ppp_generic]) from [<bf132c98>] (irnet_flow_indication+0x38/0x3c [irnet])
> [<bf132c60>] (irnet_flow_indication+0x0/0x3c [irnet]) from [<bf104e4c>] (irttp_run_tx_queue+0x1c0/0x1d4 [irda])
> [<bf104c8c>] (irttp_run_tx_queue+0x0/0x1d4 [irda]) from [<bf104f88>] (irttp_data_request+0x128/0x4f8 [irda])
>  r8 = BF121560  r7 = 00000002  r6 = C38F4200  r5 = C21418B8
>  r4 = C21418B8 
> [<bf104e60>] (irttp_data_request+0x0/0x4f8 [irda]) from [<bf1321bc>] (ppp_irnet_send+0x134/0x238 [irnet])
> [<bf132088>] (ppp_irnet_send+0x0/0x238 [irnet]) from [<bf12a600>] (ppp_push+0x80/0xb8 [ppp_generic])
>  r7 = C3A436E0  r6 = 00000000  r5 = C21418B8  r4 = C1489600
> [<bf12a580>] (ppp_push+0x0/0xb8 [ppp_generic]) from [<bf12a8d8>] (ppp_xmit_process+0x34/0x50c [ppp_generic])
===>		^^^^^^^^
>  r7 = 00000021  r6 = C21418B8  r5 = C1489600  r4 = 00000000

===>		spin_lock_bh(&pch->downl);

> [<bf12a8a4>] (ppp_xmit_process+0x0/0x50c [ppp_generic]) from [<bf12aed8>] (ppp_start_xmit+0x128/0x254 [ppp_generic])
> [<bf12adb0>] (ppp_start_xmit+0x0/0x254 [ppp_generic]) from [<c0186fa4>] (dev_hard_start_xmit+0x170/0x268)
> [<c0186e34>] (dev_hard_start_xmit+0x0/0x268) from [<c01979b8>] (__qdisc_run+0x60/0x270)
>  r8 = C1BBC914  r7 = C21418B8  r6 = 00000000  r5 = C21418B8
>  r4 = C1BBC800 
> [<c0197958>] (__qdisc_run+0x0/0x270) from [<c0187250>] (dev_queue_xmit+0x1b4/0x25c)

Now, does anyone have an idea how best to fix it?

1. Should re-entrance in ppp_channel_push() be prevented, and if yes - at 
which level? Or

2. Should re-entrance be allowed and only recursive spin_lock_bh() 
avoided?

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
