From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Fri, 31 Jul 2009 13:20:19 +0200
Message-ID: <4A72D373.7080802@hartkopp.net>
References: <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>	 <20090725131046.0f076f37@lxorguk.ukuu.org.uk>	 <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net>	 <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar>	 <4A705604.3040807@hartkopp.net>	 <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com>	 <4A717083.5090101@hartkopp.net> <20090731093949.GA4867@darkstar> <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:63513 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbZGaLU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 07:20:27 -0400
In-Reply-To: <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Young wrote:
> On Fri, Jul 31, 2009 at 5:39 PM, Dave Young<hidave.darkstar@gmail.com> wrote:
>> On Thu, Jul 30, 2009 at 12:05:55PM +0200, Oliver Hartkopp wrote:
>>> Dave Young wrote:
>>>> On Wed, Jul 29, 2009 at 10:00 PM, Oliver Hartkopp<oliver@hartkopp.net> wrote:
>>>>> Hi Dave,
>>>>>
>>>>> i got it again - even with your patch (that's why it's 2.6.31-rc4-dirty in the
>>>>> attached screenshot).
>>>> Weird, the oops occurs between sock init and tty init routines. Could
>>>> you tell your bluez version and your configuration?
>>>>
>>> No problem:
>> Thanks.
>>
>> It's still reasonable, after rfcomm sock layer initialized, userspace do sock ioctl callback but tty layer was not initilized yet at this time.
>>
>> Could you confirm it by applying following debug patch on top of my previous patch? if you get more oops with it then above reason will be right.
>>
>> --- linux-2.6.orig/net/bluetooth/rfcomm/core.c  2009-07-31 17:14:07.000000000 +0800
>> +++ linux-2.6/net/bluetooth/rfcomm/core.c       2009-07-31 17:30:39.000000000 +0800
>> @@ -36,6 +36,7 @@
>>  #include <linux/net.h>
>>  #include <linux/mutex.h>
>>  #include <linux/kthread.h>
>> +#include <linux/nmi.h>
>>
>>  #include <net/sock.h>
>>  #include <asm/uaccess.h>
>> @@ -2080,7 +2081,7 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
>>  /* ---- Initialization ---- */
>>  static int __init rfcomm_init(void)
>>  {
>> -       int ret;
>> +       int ret, i;
>>
>>        l2cap_load();
>>
>> @@ -2088,6 +2089,12 @@ static int __init rfcomm_init(void)
>>        if (ret)
>>                goto out_sock;
>>
>> +       /* delay 5 seconds to trigger the tty bug */
>> +       for (i = 0; i < 50; i++) {
>> +               touch_nmi_watchdog();
>> +               mdelay(100);
> 
> Hi, for this case, msleep is better, you can just replace the above
> two lines with msleep(100)
> 

Hi Dave,

applied this patch and replaced mdelay(100) with msleep(100).

I got two crashes and three proper boots.

The crashes look like the formerly posted screenshots.
When it boots properly i can see the delay in the boot process.

Does this help?

Regards,
Oliver

