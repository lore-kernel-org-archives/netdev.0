From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 5 Mar 2010 15:29:41 +0000
Message-ID: <OF33DF005A.0C447DF0-ON802576DD.00538FB8-802576DD.00552375@smsc.com>
References: <20100305.063909.26489418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:49951 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753472Ab0CEPow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 10:44:52 -0500
In-Reply-To: <20100305.063909.26489418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 05/03/2010 14:39:09:

> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Fri,  5 Mar 2010 12:47:05 +0000
> 
> > This patch fixes a reproducible null dereference in smsc95xx (and I
> > suspect others) when the device is removed during a control register
> > access.  This can be reproduced by rapidly plugging and unplugging
> > the device during its initialisation.
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> 
> The parent shouldn't become NULL until the device is totally quiesced
> and is no longer accesses.

The failure I'm seeing is caused when the usb device is disconnected.
smsc95xx detects that a pending USB control operation failed
and tries to print a message via netdev_printk to report this.

Unfortunately, something else (the USB subsystem?) has already set
parent to null at this time so the netdev_printk causes a null 
dereference.

So netdev_printk suddenly changes from safe to use to unsafe to use?

I could change all instances in smsc95xx to defensively check this
at each call, but what should I test to see if the device is still
valid?  Is testing parent != null the correct thing to do?

I think other usbnet drivers may have the same problem, but I don't have
any hardware to test them.

> Maybe you can instead fix the smsc95xx driver to abide by this rule
> instead of adding a conditional check to thousands of other drivers in
> the tree that do not need this?

I agree it'd be better to avoid this check where it's unnecessary, but
if netdev_printk isn't necessarily safe to call for *removable* interfaces
then shouldn't all such callers be checking that it's safe to do so?

Steve
