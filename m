From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Thu, 19 May 2016 20:11:22 +0300
Message-ID: <35f32e86-09f4-7e7d-6cf1-49805407e068@cogentembedded.com>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
 <b2763da7-575a-4d73-2997-4236173761bf@cogentembedded.com>
 <573DBFD6.2050508@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>,
	Fabio Estevam <fabio.estevam@nxp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35777 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932420AbcESRL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:11:27 -0400
Received: by mail-lf0-f53.google.com with SMTP id e126so14500952lfg.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:11:26 -0700 (PDT)
In-Reply-To: <573DBFD6.2050508@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/19/2016 04:29 PM, Guenter Roeck wrote:

>>> Commit da47b4572056 ("phy: add support for a reset-gpio specification")
>>> causes the following xtensa qemu crash according to Guenter Roeck:
>>>
>>> [    9.366256] libphy: ethoc-mdio: probed
>>> [    9.367389]  (null): could not attach to PHY
>>> [    9.368555]  (null): failed to probe MDIO bus
>>> [    9.371540] Unable to handle kernel paging request at virtual address
>>> 0000001c
>>> [    9.371540]  pc = d0320926, ra = 903209d1
>>> [    9.375358] Oops: sig: 11 [#1]
>>
>>     Of course, I'd like this patch to be reverted (as it was applied
>> erroneously instead of my patches)... but where's the backtrace? It's not
>> immediately clear how this code can cause kernel oops...
>>
> See http://www.spinics.net/lists/kernel/msg2258611.html.

    OK, I'll try to comment on your analysis posted there:

> GPIOLIB is not configured in my test case, meaning gpiod_get_optional()
> returns -ENOSYS, and phy_probe() thus returns an error. Question here is if
> it is really appropriate for the XXX_optional() gpiolib functions to return
> an error if GPIOLIB is not configured. Either case, result is that pretty
> much all phy registrations will now fail if GPIOLIB is not configured.

    Yes, that's the primary issue. That's what needs to be fixed...

> Also, I suspect that there may be a bug in the error handling path
> of ethoc_probe(). No idea what exactly is wrong, though. Other drivers
> use pretty much the same code sequence for mdio registration and associated
> error handling.

    I tried analyzing this code and it wasn't clear what's the issue...
    I must mention that this code actually looked strange -- other drivers 
call phy_connect_direct() etc. from their ndo_open() method, this driver does 
this from the probe. One problem I'm seing is that iff register_netdev() 
fails, it forgets to disconnect from the PHY.

> Last but not least, something seems to be wrong with the use of dev_err()
> with &netdev->dev if register_netdev() has not yet been called. Maybe someone
> has some insight ?

    Yes, this needs fixing as well.

> Guenter

MBR, Sergei
