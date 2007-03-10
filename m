From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: netconsole system freeze when cable unplugged
Date: Sat, 10 Mar 2007 14:06:28 +0000
Message-ID: <45F2BB64.10000@simon.arlott.org.uk>
References: <45F1B6FD.1060902@simon.arlott.org.uk>	<20070309204243.GA28441@electric-eye.fr.zoreil.com>	<45F1EE12.2070605@simon.arlott.org.uk> <p73r6rx9q28.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:36568 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767834AbXCJOGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 09:06:34 -0500
In-Reply-To: <p73r6rx9q28.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/07 13:38, Andi Kleen wrote:
> Simon Arlott <simon@fire.lp0.eu> writes:
> 
>> On 09/03/07 20:42, Francois Romieu wrote:
>>> Simon Arlott <simon@fire.lp0.eu> :
>>>> When I unplug the cable the system just stops responding to
>>>> anything, at all. No message is printed to the console when the
>>>> cable is plugged back in.
>>> rtl8139_interrupt (spin_lock(&tp->lock))
>>> -> rtl8139_weird_interrupt
>>>    -> rtl_check_media
>>>       -> mii_check_media (printk(KERN_INFO "%s: link down\n", ...))
>>>          [netpoll stuff here]
>>>          -> rtl8139_poll_controller
>>>             -> rtl8139_interrupt
>>>                *deadlock*
>>> See below for my random stuff of the day. Feel free to open a PR at
>>> bugzilla.kernel.org if the issue does not go away.
>> The patch doesn't fix it, nothing changes. I'm not sure how this can
>> be debugged if printk won't work...
> 
> earlyprintk can be called directly (early_printk()) and should
> work. It won't log over the network of course.

It also won't log over the serial console either :(
(but that's probably a good thing, it's slow enough to boot with tons 
of messages to the display because of netconsole and nfs).

rtl8139_interrupt
-> spin_lock(&tp->lock)
-> rtl8139_weird_interrupt
   -> rtl_check_media
      -> mii_check_media
         -> printk(KERN_INFO "%s: link down\n", ...)
            -> wite_msg
               -> local_irq_save
               -> netpoll_send_udp
                  -> netpoll_send_skb
                     -> local_irq_save
                     -> dev->hard_start_xmit(..., ...)
rtl8139_start_xmit
-> spin_lock_irqsave
   *deadlock*

-- 
Simon Arlott
