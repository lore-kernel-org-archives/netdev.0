From: dfages@arkoon.net
Subject: =?iso-8859-1?Q?R=E9f._:_Fw:_[BUG/PATCH]_CONFIG=5FNET=5FHW=5FFLOWCONTROL?=
	=?iso-8859-1?Q?_and_SMP?=
Date: Tue, 30 Sep 2003 09:07:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C1256DB1.00272341.00@arkoon-mail.arkoon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Yes, I know that but, for the moment, I've to keep my 2.4.19 kernel (so without
NAPI).
I've also ported the e1000 driver to HW_FLOWCONTROL. Some people may be happy to
use it...

Regards,
---
Daniel FAGES
ARKOON Network Security    http://www.arkoon.net


|--------+--------------------------->
|        |          Robert Olsson    |
|        |          <Robert.Olsson@da|
|        |          ta.slu.se>       |
|        |                           |
|        |          29/09/2003 23:25 |
|        |                           |
|--------+--------------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       Pour :  Andrew Morton <akpm@osdl.org>                                |
  |       cc :    netdev@oss.sgi.com, daniel fages/Arkoon                      |
  |       Objet :      Fw: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP       |
  >----------------------------------------------------------------------------|







Hello!

IMO HW_FLOWCONTROL is now outdated. It has served very well and encouraged
people to use for Linux production networking. With a 2 tulip NIC's on a UP
system as a typical system. Only tulip has code for it. This option was
added by Alexey in 2.1.63 something...


Cheers.
                              --ro


Andrew Morton writes:
 >
 >
 > Begin forwarded message:
 >
 > Date: Mon, 29 Sep 2003 14:08:54 +0200
 > From: dfages@arkoon.net
 > To: linux-kernel@vger.kernel.org
 > Subject: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP
 >
 >
 >
 >
 > Hi,
 > by testing the CONFIG_NET_HW_FLOWCONTROL (NIC Hardware throttling) on
 > a SMP system, I found a bug in net/core/dev.c : the netdev_dropping
 > variable can be set to a negative value (the result is that a CPU can
 > be locked in "throttle" state).
 > This bug seems to exist in 2.4 and in 2.6 kernels.
 >
 > Here's a typical scenario :
 >
 > - Throttling --> (CPU 0)queue->throttle==1 && (CPU 1)queue->throttle==1
 >      && netdev_dropping == 2
 > - 1st packet Unthrottle ( in net_rx_action() ), received by CPU 0
 >      --> (CPU 0)queue->throttle==1 && (CPU 1)queue->throttle==1
 >      && netdev_dropping == 1
 > - 2nd packet Unthrottle ( in net_rx_action() ), received by CPU 0
 >      --> (CPU 0)queue->throttle==0 && (CPU 1)queue->throttle==1
 >      && netdev_dropping == 0
 > - 3nd packet Unthrottle ( in net_rx_action() ), received by CPU 1
 >      --> (CPU 0)queue->throttle==0 && (CPU 1)queue->throttle==0
 >      && netdev_dropping == -1
 >
 > and so on...
 >
 > The problem is that the (CPU)queue->throttle should be set to zero every
 > time the netdev_dropping variable is decremented.
 >
 >
 > Here's a patch for the 2.4.19 kernel (tested with success) :
 >
 > --- linux-2.4.19/net/core/dev.c.orig     Mon Sep 29 12:49:14 2003
 > +++ linux-2.4.19/net/core/dev.c    Tue Sep 23 18:35:35 2003
 > @@ -1519,8 +1519,8 @@
 >
 >  #ifdef CONFIG_NET_HW_FLOWCONTROL
 >      if (queue->throttle && queue->input_pkt_queue.qlen < no_cong_thresh ) {
 > +         queue->throttle = 0;
 >           if (atomic_dec_and_test(&netdev_dropping)) {
 > -              queue->throttle = 0;
 >                netdev_wakeup();
 >                goto softnet_break;
 >           }
 >
 >
 >
 >
 > I haven't done a patch for 2.4.22 (as we currently use 2.4.19) but the same
 > modification should be applied around lines 1572 to 1577 of net/core/dev.c
 >
 > For 2.6.0-test5, the lines to modified are arount 1631 to 1637.
 >
 > Regards,
 > ---
 > Daniel FAGES
 > ARKOON Network Security    http://www.arkoon.net
 >
 >
 > -
 > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > Please read the FAQ at  http://www.tux.org/lkml/
 >
