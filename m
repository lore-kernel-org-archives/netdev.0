From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Tue, 18 Aug 2015 18:54:07 -0700 (PDT)
Message-ID: <20150818.185407.1667358232705414236.davem@davemloft.net>
References: <55CE1D7E.2070400@rosalab.ru>
	<1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: eugene.shatokhin@rosalab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Date: Fri, 14 Aug 2015 19:58:36 +0300

> 2. The second race is on dev->flags.
> 
> dev->flags is set to 0 here:
> *0  usbnet_stop (usbnet.c:816)
>     /* deferred work (task, timer, softirq) must also stop.
>      * can't flush_scheduled_work() until we drop rtnl (later),
>      * else workers could deadlock; so make workers a NOP.
>      */
>     dev->flags = 0;
>     del_timer_sync (&dev->delay);
>     tasklet_kill (&dev->bh);
> 
> And here, the code clears EVENT_RX_KILL bit in dev->flags, which may
> execute concurrently with the above operation:
> *0 clear_bit (bitops.h:113, inlined)
> *1 usbnet_bh (usbnet.c:1475)
>     /* restart RX again after disabling due to high error rate */
>     clear_bit(EVENT_RX_KILL, &dev->flags);
> 
> It seems, setting dev->flags to 0 is not necessarily atomic w.r.t.
> clear_bit() and other bit operations with dev->flags. It is safer to
> make it atomic and this way, make the race harmless.
> 
> While at it, the checking of EVENT_NO_RUNTIME_PM bit of dev->flags in
> usbnet_stop() was fixed too: the bit should be checked before dev->flags
> is cleared.

The fix for this is excessive.

Instead of all of this madness, looping over expensive clear_bit()
atomics, just do whatever it takes to make sure that usbnet_bh() is
quiesced and cannot execute any more.  Then you can safely clear
dev->flags normally.
