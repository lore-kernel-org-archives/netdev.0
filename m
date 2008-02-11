From: Scott Wood <scottwood@freescale.com>
Subject: Re: WARN_ON() hit in fsl bitbanged phy driver
Date: Mon, 11 Feb 2008 16:26:01 -0600
Message-ID: <47B0CB79.7090400@freescale.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B03F931E6@ismail.innsys.innovsys.com> <47B0C30A.1030801@freescale.com> <DCEAAC0833DD314AB0B58112AD99B93B03F9325F@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Rune Torgersen <runet@innovsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44798 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756936AbYBKW0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:26:10 -0500
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B03F9325F@ismail.innsys.innovsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rune Torgersen wrote:
> Scott Wood wrote:
>> Rune Torgersen wrote:
>>> I hit the following WARN_ON when using mii-tools agains a ethernet
>>> interface using a bit-banged mii interface
>> It looks like the kernel thinks it's in an interrupt, even though it
>> clearly isn't from the backtrace.  Presumably, something
>> slept from an
>> interrupt handler; try turning on sleep-in-spinlock debugging.
> 
> I turned on sleep-in-spinlock and it did not reveal anything. I'm trying
> some other debug options.
> 
>> The root cause was probably something other than the phy code.
> I'm not so sure, because it only happens when I run mii-tool agains the
> interface useing the bit-banged driver, and then only the first time.

OK, it seems I should have checked 2.6.24 instead of head-of-tree; 
softirq.c:139 is a different assertion than I thought.  It's not 
in_irq(), but irqs_disabled().  fs_ioctl() is disabling interrupts, and 
spin_unlock_bh() doesn't like that.  The current use of mutexes likes it 
even less.  The locking should be moved inside the phy bus 
implementation, if it's needed at all.

It only happens once because it's a WARN_ON_ONCE(). :-)

-Scott
