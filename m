From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 01 Sep 2015 09:57:54 +0200
Message-ID: <1441094274.3328.0.camel@suse.de>
References: <55AD3A41.2040100@rosalab.ru>
	 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	 <1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
	 <87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E01750.4010202@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-28 at 11:09 +0300, Eugene Shatokhin wrote:
> > Exactly what problem will that result in?  The tasklet_kill() will
> wait
> > for the processing of the single element done queue, and everything
> will
> > be fine.  Or?
> 
> Given enough time, what prevents defer_bh() from calling 
> tasklet_schedule(&dev->bh) *after* usbnet_stop() calls tasklet_kill()?
> 
> Consider the following situation (assuming '&&' are changed to '||'
> in 
> that while loop in usbnet_terminate_urbs() as they should be):
> 
> CPU0                            CPU1
> usbnet_stop()                   defer_bh() with list == dev->rxq
>    usbnet_terminate_urbs()
>                                  __skb_unlink() removes the last
>                                  skb from dev->rxq.
>                                  dev->rxq, dev->txq and dev->done
>                                  are now empty.
>    while (!skb_queue_empty()...)
>      The loop ends because all 3
>      queues are now empty.
> 
>    usbnet_terminate_urbs() ends.
> 
> usbnet_stop() continues:
>    usbnet_status_stop(dev);
>    ...
>    del_timer_sync (&dev->delay);
>    tasklet_kill (&dev->bh);
>                                  __skb_queue_tail(&dev->done, skb);
>                                  if (dev->done.qlen == 1)
>                                    tasklet_schedule(&dev->bh);
> 
> The BH is scheduled at this point, which is not what was intended.
> The 
> race window is small, but still.

This looks possible. I cannot come up with a better fix, although
it isn't nice. Thanks for finding this.

	Regards
		Oliver
