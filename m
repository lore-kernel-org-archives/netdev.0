From: "David S. Miller" <davem@redhat.com>
Subject: Re: acenic lockup
Date: Thu, 08 May 2003 09:00:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.090049.48375778.davem@redhat.com>
References: <20030507.123421.133894691.davem@redhat.com>
	<200305072221.CAA00973@mops.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, jes@trained-monkey.org, netdev@oss.sgi.com,
   jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200305072221.CAA00973@mops.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
   Date: Thu, 8 May 2003 02:21:11 +0400 (MSD)

   > However, what does kick device back into working state?
   
   Usually it is a link problem and device will recover after
   link is restored. This happens here.
   
I fully recognize this.

   If it is some PCI failure or something went wrong in hardware,
   the device will stop forever, I guess. And I guess this happens
   with the same frequency as memory parity errors i.e. not so much. :-)
   
Sometimes it is not cosmic bit-flip which causes this, but rather
bit-flip caused by programmer of some unrelated area of kernel :-)))
   
I am happy that hard-hang part is probably gone now.  But I also
desire real resiliency in this area of drivers.

   > Do we make shamans dance when this message hits the logs
   > and pray for the best? :-) 
   
   Sort of. I was about to dance for a while when saw creepy
   "ethX: BUG, tx ring is full" from tulip, which has the same bogus
   netif_wake_queue(). :-)
   
Note to Jeff, independant of what is being discussed here, a real
audit of drivers that blindly invoke netif_wake_queue() from transmit
timeout watchdog routine is in order at some point.  This is what
Alexey is referring to as "same bogus netif_wake_queue()".

   Well, full reset is difficult thing with lock-free acenic.
   Seems, it has to throttle card, wake up something at process context,
   to disable irq there and to reset nic like it happens at ifconfig down
   (or even module unload in face of hard hardware failure?)

It is simple, use schedule_work(), tg3.c does exactly this.
Only difference in acenic is need to use disable_irq(), that is all.
