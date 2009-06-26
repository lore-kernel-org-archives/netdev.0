From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: hunging ifenslave command
Date: Fri, 26 Jun 2009 18:36:15 +0200
Message-ID: <20090626163615.GA6755@ami.dom.local>
References: <4A3A3DEA.20602@onet.eu> <4A3CE5D5.8070308@gmail.com> <4A44D1FC.8090001@onet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sdrb <sdrb@onet.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:48363 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943AbZFZQg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 12:36:29 -0400
Received: by fxm9 with SMTP id 9so2212402fxm.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 09:36:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A44D1FC.8090001@onet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 03:49:48PM +0200, sdrb wrote:
> Jarek Poplawski pisze:
>> sdrb wrote, On 06/18/2009 03:15 PM:
>>
>>> Hello,
>>>
>>> I have got problem with hunging "ifenslave" command.
>>> I configured bond0 interfaces with 3 slaved interfaces: eth0, eth1 
>>> and eth2. While I'm removing one of it - sometimes only the 
>>> "ifenslave" command hangs up but sometimes the whole system is 
>>> hanging up completely - so it's not possible to even write on the 
>>> console.
>>>
>>> I'm using linux kernel 2.6.27.10 with bonding driver version v3.3.0  
>>> (June 10, 2008) and ethernet card driver r8168 version 8.006.00-NAPI.
>>>
>>> Anyone knows where is the problem with it?
>>
>>
>> Hi,
>>
>> I don't know, but I guess, if anyone knew it would be fixed now. So, I'd
>> recommend trying the current stable (2.6.30), and if no difference, maybe
>> some debugging like turning on lockdep (lock debugging with prove
>> locking correctness). If still nothing reported, try to get a few SysRq
>> logs when it happens e.g. Alt-PrtScr with t, d, w, q, and send them with
>> .config and dmesg (gzipped or as attachments to the bugzilla report).
>
> Ok, I dig a little in the 2.6.27.10 kernel and I've taken the newest  
> driver (ver 8.012.00) from the realtek website.
> Sorry - I haven't tested it under 2.6.30, because I had to fix it just  
> for 2.6.27.10.
>
> I investigated this problem and I noticed that probably there is problem  
> with rtnl_lock().
> Below there is backtrace for three tasks I've got from logs:
...
> I've made some patch for r8168 driver and it seems it works, but I'm not  
> sure if I did it correctly or if it isn't too dangerous solution :)
> The patch is in attachment. With this patch the "ifenslave" command  
> doesn't hang as earlier.
> Can anyone review it?
>
I didn't verify this (is it an out of tree driver?), but it's quite
probable. This type of bug was fixed a while ago in most drivers, and
if this one is similar to r8169 you could probably try to move this
flush_scheduled_work() to the .remove callback because it works a bit
different than cancel_delayed_work() (or cancel_delayed_work_sync()
which should be more reliable).

Btw., this type of bugs should be reported by lockdep (with a config
option I mentioned earlier).

Jarek P.

>
> sdrb
>

> --- r8168_n.c	2009-04-21 05:05:33.000000000 +0200
> +++ r8168_n.c	2009-06-26 15:04:12.988842186 +0200
> @@ -5752,7 +5752,7 @@ rtl8168_down(struct net_device *dev)
>  	rtl8168_delete_esd_timer(dev, &tp->esd_timer);
>  	rtl8168_delete_link_timer(dev, &tp->link_timer);
>  
> -	flush_scheduled_work();
> +	cancel_delayed_work(&tp->task);
>  
>  #ifdef CONFIG_R8168_NAPI
>  #if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)

