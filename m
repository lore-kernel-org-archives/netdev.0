From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 00/11] net: remove disable_irq() from ->ndo_poll_controller
Date: Tue,  9 Dec 2014 15:37:11 +0100
Message-ID: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:49301 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbaLIOh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:37:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit e22b886a8a43b ("sched/wait: Add might_sleep() checks"),
Peter Zijlstra added a check that fires on netpoll controllers that
use disable_irq().

There are 60 drivers currently using disable_irq() in their netpoll
controller.  A lot of these simply disable irqs before calling their
interrupt handler.  A few do something a little more complex, often
with multiple irqs.

Thomas Gleixner and Peter Zijlstra suggested the idea of a adding a
spinlock in the interrupt handler and submitted the initial patch for
this: https://lkml.org/lkml/2014/10/29/742

There are three groups of drivers/netpoll controllers that need to be
fixed:
  1) drivers that simply disable_irq()
     a) interrupt handler takes a lock
        examples: 8139cp/8139too
        The disable_irq() call is not necessary, we can just remove it
        and rely on the lock in the interrupt handler.
     b) interrupt handler doesn't take a lock
        examples: e1000, atl1c
        Add locking to the interrupt handler, remove the disable_irq() call.
  2) other drivers
     These are the other drivers whose netpoll controller use disable_irq:
     drivers/net/ethernet/nvidia/forcedeth.c
     drivers/net/ethernet/broadcom/bnx2.c
     drivers/net/ethernet/neterion/s2io.c
     drivers/net/ethernet/neterion/vxge/vxge-main.c
     drivers/net/ethernet/silan/sc92031.c
     drivers/net/ethernet/freescale/fec_main.c
     drivers/net/ethernet/freescale/gianfar.c
     drivers/net/ethernet/pasemi/pasemi_mac.c
     drivers/net/ethernet/xilinx/ll_temac_main.c
     drivers/net/ethernet/xilinx/xilinx_axienet_main.c
     Additionally, igb calls synchronize_irq()
     in igb_netpoll -> igb_irq_disable.


These patches provide new helpers to lock the interrupt handler
against netpoll controller, and convert a few drivers as examples for
each group.  I will take care of the rest if this RFC passes the
review.

e1000 and 8139cp have been tested on QEMU, the rest has only been
compiled.  The changes to drivers in group 2) are more complex, and
need more careful review.


Note: I'm not sure whether this should go into net-next or net.  For
now, since the check was only in linux-next, I based the patches on
net-next.  But Peter and Thomas said:

>> But I suspect most all the network drivers will need this and maybe
>> more, disable_irq() is a popular little thing and we 'just' changed
>> semantics on them.
>
> We changed that almost 4 years ago :) What we 'just' did was to add
> a prominent warning into the code.


Please review and comment.  Thanks!


Sabrina Dubroca (11):
  netpoll: introduce netpoll_irq_lock to protect netpoll controller
    against interrupts
  e1000: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  8139cp/too: remove disable_irq from netpoll controller
  atl1c: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  bnx2: remove disable_irq from netpoll controller, use netpoll_irq_lock
  s2io: remove disable_irq from netpoll controller, use netpoll_irq_lock
  pasemi: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  ll_temac: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  xilinx/axienet: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  gianfar: remove disable_irq from netpoll controller, use
    netpoll_irq_lock
  net: fec: remove disable_irq from netpoll controller, use
    netpoll_irq_lock

 drivers/net/ethernet/atheros/atl1c/atl1c.h        |  3 ++
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   | 12 ++++---
 drivers/net/ethernet/broadcom/bnx2.c              | 24 ++++++++++----
 drivers/net/ethernet/broadcom/bnx2.h              |  4 +++
 drivers/net/ethernet/freescale/fec.h              |  2 ++
 drivers/net/ethernet/freescale/fec_main.c         | 14 +++++++++
 drivers/net/ethernet/freescale/gianfar.c          | 38 ++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h          |  5 +++
 drivers/net/ethernet/intel/e1000/e1000.h          |  3 ++
 drivers/net/ethernet/intel/e1000/e1000_main.c     | 21 ++++++++++---
 drivers/net/ethernet/neterion/s2io.c              | 27 +++++++++-------
 drivers/net/ethernet/neterion/s2io.h              |  4 +++
 drivers/net/ethernet/pasemi/pasemi_mac.c          | 25 +++++++++------
 drivers/net/ethernet/pasemi/pasemi_mac.h          |  3 ++
 drivers/net/ethernet/realtek/8139cp.c             |  3 +-
 drivers/net/ethernet/realtek/8139too.c            |  3 +-
 drivers/net/ethernet/xilinx/ll_temac.h            |  3 ++
 drivers/net/ethernet/xilinx/ll_temac_main.c       | 13 ++++----
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |  3 ++
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 15 +++++----
 include/linux/netpoll.h                           | 31 ++++++++++++++++++
 21 files changed, 182 insertions(+), 74 deletions(-)


Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>

-- 
2.1.3
