From: Joe Korty <joe.korty@ccur.com>
Subject: Re: eth0: too many iterations (16) in nv_nic_irq.
Date: Mon, 6 Apr 2009 10:25:08 -0400
Message-ID: <20090406142508.GA18639@tsunami.ccur.com>
References: <49D86997.6010304@krogh.cc>
Reply-To: Joe Korty <joe.korty@ccur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758048AbZDFOZo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D86997.6010304@krogh.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 05, 2009 at 04:19:35AM -0400, Jesper Krogh wrote:
> I have a 2.6.29 kernel which fills up the "dmesg-buffer" with these:
> 
> eth0: too many iterations (16) in nv_nic_irq.
> 
> $ dmesg | grep -c "too many iterations"
> 1986
> 
> I have seen the commit below.. is the fix just to set the limit to 30
> instead? or is there a "real bug" underneath?

Probably.  Still it is worth trying the '30' as an experiment.

The underlying cause is likely to be something on your system
holding off the eth0 interrupt for short periods of time.
An SMI is one such possibility.

I can't help but wonder if the printk itself is causing enough
of a delay to make this condition reoccur indefinately, under
sufficiently heavy net load, once it occurs once.  It might be
better to instead use printk_ratelimit.

Joe


> commit dccd547e2bf2c01a13c967ae03a705338394fad6
> Author: Joe Korty <joe.korty@ccur.com>
> Date:   Wed Oct 29 14:22:16 2008 -0700
> 
>      forcdeth: increase max_interrupt_work
> 
>      This eliminates the following often-generated warning from my 64 bit
>      Opteron SMP test stand:
> 
>          eth0: too many iterations (6) in nv_nic_irq
> 
>      According to the web, the problem is that the forcedeth driver has a
>      too-low value for max_interrupt_work.  Grepping the kernel I see that
>      forcedeth has the second lowest value of all ethernet drivers (ie, 6).
>      Most are in the 20-40 range.  So this patch increases this a bit,
>      from 6 to 15 (at 15 forcedeth becomes the driver with third-lowest
>      max_interrupt_work value).
> 
>      My test stand, which used to print out the above warnings repetitively
>      whenever it was under heavy net load, no longer does so.
> 
>      Signed-off-by: Joe Korty <joe.korty@ccur.com>
>      Cc: Ayaz Abdulla <aabdulla@nvidia.com>
>      Cc: Jeff Garzik <jeff@garzik.org>
>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>      Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
