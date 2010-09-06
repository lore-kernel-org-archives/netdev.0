From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] ucc_geth: fix ethtool set ring param bug
Date: Mon, 06 Sep 2010 13:22:23 -0700 (PDT)
Message-ID: <20100906.132223.48506151.davem@davemloft.net>
References: <1283305429-8426-1-git-send-email-liang.li@windriver.com>
	<1283443364-2136-1-git-send-email-liang.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: liang.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942Ab0IFUWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:22:06 -0400
In-Reply-To: <1283443364-2136-1-git-send-email-liang.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liang Li <liang.li@windriver.com>
Date: Fri,  3 Sep 2010 00:02:44 +0800

> +		printk(KERN_INFO "Stopping interface %s.\n", netdev->name);
 ...
> +		printk(KERN_INFO "Reactivating interface %s.\n", netdev->name);

Please get rid of these log messages.

Also, this isn't the way to implement this.

Abstract out the one and only operation that can fail when you change
the ring size, which is the memory allocations, into seperate code.

Allocate the newly sized rings first, and if that fails abort the
ring size change attempt.  This will let the device continue to
function and operate properly even if the ring resizing fails.

Then stop the RX/TX DMA, switch the ring pointers and configuration
inside of the device, restart RX/TX DMA, and finally free up the
old ring memory.

I know why you want to use *_close() and *_open(), it requires less
coding and work on your part.  But this is why the error handling
behavior is difficult and what happens on failure (device goes down
and becomes inoperative) is extremely unpleasant for the user.

The user should be able to make this kind of change over an SSH
shell that uses the interface itself, and not expect to lose
connectivity completely just because the ring allocation fails.

Thanks.
