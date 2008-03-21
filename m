From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Thu, 20 Mar 2008 18:08:02 -0700
Message-ID: <20080320180802.426ad2d1.akpm@linux-foundation.org>
References: <20080316184349.GA28543@khazad-dum.debian.net>
	<200803161246.23909.david-b@pacbell.net>
	<20080318001429.896acf51.akpm@linux-foundation.org>
	<20080320225612.GB20788@khazad-dum.debian.net>
	<20080320164741.734e838c.akpm@linux-foundation.org>
	<20080321003604.GC20788@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>,
	Richard Purdie <rpurdie@rpsys.net>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	video4linux-list@redhat.com,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	lm-sensors@lm-sensors.org
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756599AbYCUBKZ@vger.kernel.org>
In-Reply-To: <20080321003604.GC20788@khazad-dum.debian.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Mar 2008 21:36:04 -0300 Henrique de Moraes Holschuh <hmh@hmh.eng.br> wrote:

> Well, so far so good for LEDs, but what about the other users of in_atomic
> that apparently should not be doing it either?

Ho hum.  Lots of cc's added.



./arch/x86/mm/pageattr.c

  Looks wrong.

./arch/m68k/atari/time.c

  Possibly buggy: deadlockable

./sound/core/seq/seq_virmidi.c

  Possibly buggy

./net/iucv/iucv.c
./kernel/power/process.c

  Just a debug check.

./drivers/s390/char/sclp_tty.c

  Possibly buggy: deadlockable
  
./drivers/s390/char/sclp_vt220.c

  Possibly buggy: deadlockable

./drivers/s390/net/netiucv.c

  Possibly buggy: deadlockable

./drivers/char/isicom.c

  Possibly buggy: deadlockable

./drivers/usb/misc/sisusbvga/sisusb_con.c

  Possibly buggy: deadlockable

./drivers/net/usb/pegasus.c

  Possibly buggy: deadlockable (I assume)

./drivers/net/wireless/airo.c

  Possibly buggy: deadlockable

./drivers/net/wireless/rt2x00/rt73usb.c

  Possibly buggy: deadlockable (I assume)

./drivers/net/wireless/rt2x00/rt2500usb.c

  Possibly buggy: deadlockable (I assume)

./drivers/net/wireless/hostap/hostap_ioctl.c

  Possibly buggy: deadlockable (I assume)

./drivers/net/wireless/zd1211rw/zd_usb.c

  Possibly buggy: deadlockable (I assume)

./drivers/net/irda/sir_dev.c

  Possibly buggy: deadlockable

./drivers/net/netxen/netxen_nic_niu.c

  Possibly buggy: deadlockable

./drivers/net/netxen/netxen_nic_init.c

  Possibly buggy: deadlockable

./drivers/ieee1394/ieee1394_transactions.c

  Possibly buggy: deadlockable

./drivers/video/amba-clcd.c

  Possibly buggy: deadlockable

./drivers/i2c/i2c-core.c

  Possibly buggy: deadlockable


The usual pattern for most of the above is

	if (!in_atomic())
		do_something_which_might_sleep();

problem is, in_atomic() returns false inside spinlock on non-preptible
kernels.  So if anyone calls those functions inside spinlock they will
incorrectly schedule and another task can then come in and try take the
already-held lock.

Now, it happens that in_atomic() returns true on non-preemtible kernels
when running in interrupt or softirq context.  But if the above code really
is using in_atomic() to detect am-i-called-from-interrupt and NOT
am-i-called-from-inside-spinlock, they should be using in_irq(),
in_softirq() or in_interrupt().
