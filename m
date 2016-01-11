From: Igor Plyatov <plyatov@gmail.com>
Subject: Re: net: phy: SMSC LAN8710/LAN8720 high load
Date: Mon, 11 Jan 2016 11:09:07 +0300
Message-ID: <56936323.3070406@gmail.com>
References: <1452498115.7467.23.camel@lws-tremmet.phytec.de>
Reply-To: plyatov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Teresa Remmet <t.remmet@phytec.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452498115.7467.23.camel@lws-tremmet.phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Teresa,

> Hello,
>
> we have noticed load issues on our AM335x boards with a LAN8710 phy while
> cpu is idling using 4.4-rc8.
>
> CPU:   0% usr   0% sys   0% nic  99% idle   0% io   0% irq   0% sirq
> Load average: 1.21 1.16 1.00 1/84 372
>
> We could track this down to the ethernet phy. And bisect the issue to the
> following patch:
>
> commit 776829de90c5972895db398993ddfa9417ff8b01
> Author: Igor Plyatov <plyatov@gmail.com>
> Date:   Fri Aug 14 20:11:02 2015 +0300
>
>      net: phy: workaround for buggy cable detection by LAN8700 after cable plugging
>      * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
>        Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
>        set, the ENERGYON bit does not asserted sometimes). This is a common bug of
>        LAN87xx family of PHY chips.
>      * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
>        algorythm still not reliable on 100 % and sometimes skip cable plugging.
>      
>      Signed-off-by: Igor Plyatov <plyatov@gmail.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Reverting the commit helped to make the load drop down to:
>
> 09:21:01 up 32 min,  load average: 0.19, 0.17, 0.14
>
> In both cases no ethernet cable as been connected.
>
> We also struggle with the buggy cable detection issue, but this increase of load
> doesn't seem acceptable.

It depends from scenarios of device usage and priorities of device 
reliability.
Our device is industrial and work most of the time with Ethernet cable 
plugged in.
In our case it is completely unacceptable to have buggy cable detection 
and we can easily sacrifice some small CPU time.

Do you need to use device without Ethernet cable for a long time? Is 
this critical?

Teresa, maybe you can improve CPU usage.
Try to play with number of cycles and msleep time in the cycle:

/* Wait max 640 ms to detect energy */
         for (i = 0; i < 64; i++) {
             /* Sleep to allow link test pulses to be sent */
             msleep(10);

But you need to keep overall duration >= 640 ms and make many long tests 
after modification to be sure in reliable cable detection.

Best wishes.
