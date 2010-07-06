From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Mon, 05 Jul 2010 19:05:47 -0700 (PDT)
Message-ID: <20100705.190547.28805625.davem@davemloft.net>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752703Ab0GFCFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:05:33 -0400
In-Reply-To: <a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 5 Jul 2010 07:33:14 +0200

> In order to support hardware time stamping from a PHY, it is necessary to
> read from the PHY while running in_interrupt(). This patch allows a mii
> bus to operate in an atomic context. An mii_bus driver may declare itself
> capable for this mode. Drivers which do not do this will remain with the
> default that bus operations may sleep.
> 
> Before commit 35b5f6b1a82b5c586e0b24c711dc6ba944e88ef1 mii bus
> operations were protected with spin locks. That commit replaced the
> locks with mutexs in order to accommodate i2c buses that need to
> sleep. Thus, this patch restores the original behavior as a run time
> option.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Ok, I'm not to happy about this one, to be honest.

Conditional locking is always a problem waiting to happen.

Question: What context can you call mdiobus_lock() in?

Answer: You absolutely cannot know.

Therefore every piece of code, except those with special knowledge
of what kind of device is behind the mdiobus object, have to assume
the worst which is that the interface can only be called in sleepable
contexts.

We need to find another way to accomodate this, I really don't want to
see this kind of situation where the locking facility type is
conditional upon the device sitting behind the interface.
