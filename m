From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [net-next 00/54][pull request] Using dev_kfree/consume_skb_any for functions called in multiple contexts
Date: Mon, 24 Mar 2014 22:58:04 -0700
Message-ID: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56818 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaCYF6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 01:58:15 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These changes are a result of walking through the network drivers
supporting netpoll and verifying the code paths that netpoll can cause
to be called in hard irq context use an appropriate flavor of
kfree_skb.  Either dev_kfree_skb_any or dev_consume_skb_any.

Since my last pass at this I have become aware of the small differences
between dev_kfree_skb_any and dev_consume_skb_any.
net/core/drop_monitor.c reports the dev_kfree_skb_any as a drop and
while being quite about the second.  With the weird twist that
dev_kfree_skb is unintuitively consume_skb.

As netpoll now calls the napi poll function with budget == 0, pieces of
a drivers the napi poll function that don't run when budget == 0 have
been ignored.

The most interesting change is to the atl1c which tried unsuccesfully to
tell one of it's functions which context it is called in so that it
could call dev_kfree_skb_irq or dev_kfree_skb as appropriate.  I have
just removed the extra parameter and called dev_consume_skb_any.

At 54 separate changes I will post each change as a separate patch (so
they can be reviewed) but for general sanity sake I have gathered them
all into a git branch for easy acces.

David when you are satisified with these changes please pull:

    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Hopefully this will allow me to forget this class of error when dealing
with netpoll.

Eric

Eric W. Biederman (54):
      uml/net_kern: Call dev_consume_skb_any instead of dev_kfree_skb.
      3c509: Call dev_consume_skb_any instead of dev_kfree_skb.
      3c59x: Call dev_consume_skb_any instead of dev_kfree_skb.
      8390: Call dev_consume_skb_any instead of dev_kfree_skb.
      bfin_mac: Call dev_consume_skb_any instead of dev_kfree_skb.
      sun4i-emac: Call dev_consume_skb_any instead of dev_kfree_skb.
      am79c961a: Call dev_consume_skb_any instead of dev_kfree_skb.
      lance: Call dev_consume_skb_any instead of dev_kfree_skb.
      pcnet32: Call dev_kfree_skb_any instead of dev_kfree_skb.
      alx: Call dev_kfree_skb_any instead of dev_kfree_skb.
      atl1c: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      bnad: Call dev_kfree_skb_any instead of dev_kfree_skb.
      macb: Call dev_kfree_skb_any instead of kfree_skb.
      xgmac: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      cxgb3: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
      cxgb4: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
      cxfb4vf: Call dev_kfree/consume_skb_any instead of [dev_]kfree_skb.
      cs89x0: Call dev_consume_skb_any instead of dev_kfree_skb.
      enic: Call dev_kfree_skb_any instead of dev_kfree_skb.
      dm9000: Call dev_consume_skb_any instead of dev_kfree_skb.
      dmfe: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      uli526x: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      sundance: Call dev_kfree_skb_any instead of dev_kfree_skb.
      fec: Call dev_kfree_skb_any instead of kfree_skb.
      ucc_geth: Call dev_consume_skb_any instead of dev_kfree_skb.
      i825xx: Call dev_kfree_skb_any instead of dev_kfree_skb.
      ehea: Call dev_consume_skb_any instead of dev_kfree_skb.
      ibmveth: Call dev_consume_skb_any instead of dev_kfree_skb.
      jme: Call dev_kfree_skb_any instead of dev_kfree_skb.
      mv643xx_eth: Call dev_kfree_skb_any instead of dev_kfree_skb.
      skge: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      sky2: Call dev_kfree_skb_any instead of dev_kfree_skb.
      ksz884x: Call dev_consume_skb_any instead of dev_kfree_skb.
      s2io: Call dev_kfree_skb_any instead of dev_kfree_skb.
      vxge: Call dev_kfree_skb_any instead of dev_kfree_skb.
      forcedeth: Call dev_kfree_skb_any instead of kfree_skb.
      sc92031: Call dev_consume_skb_any instead of dev_kfree_skb.
      sis900: Call dev_kfree_skb_any instead of dev_kfree_skb.
      smc911x: Call dev_kfree_skb_any instead of dev_kfree_skb.
      smc91x: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      smsc911x: Call dev_consume_skb_any instead of dev_kfree_skb.
      stmmac: Call dev_consume_skb_any instead of dev_kfree_skb.
      sungem: Call dev_consume_skb_any instead of dev_kfree_skb.
      tilepro: Call dev_consume_skb_any instead of kfree_skb.
      spider_net: Call dev_consume_skb_any instead of dev_kfree_skb.
      via-rhine: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      via-velocity: Call dev_kfree_skb_any instead of kfree_skb.
      xilinx_emaclite: Call dev_consume_skb_any instead of dev_kfree_skb.
      vmxnet3: Call dev_kfree_skb_any instead of dev_kfree_skb.
      xen-netfront: Call dev_kfree_skb_any instead of dev_kfree_skb.
      wlags49_h2: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      staging/octeon-ethernet: Call dev_kfree/consume_skb_any instead of dev_kfree_skb.
      virtio_net: Call dev_kfree_skb_any instead of dev_kfree_skb.
      if_vlan: Call dev_kfree_skb_any instead of kfree_skb.

 arch/um/drivers/net_kern.c                        |  2 +-
 drivers/net/ethernet/3com/3c509.c                 |  2 +-
 drivers/net/ethernet/3com/3c59x.c                 |  2 +-
 drivers/net/ethernet/8390/lib8390.c               |  2 +-
 drivers/net/ethernet/adi/bfin_mac.c               |  2 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c       |  2 +-
 drivers/net/ethernet/amd/7990.c                   |  2 +-
 drivers/net/ethernet/amd/am79c961a.c              |  2 +-
 drivers/net/ethernet/amd/pcnet32.c                |  2 +-
 drivers/net/ethernet/atheros/alx/main.c           |  2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   | 20 ++++++++------------
 drivers/net/ethernet/brocade/bna/bnad.c           | 16 ++++++++--------
 drivers/net/ethernet/cadence/macb.c               |  2 +-
 drivers/net/ethernet/calxeda/xgmac.c              |  6 +++---
 drivers/net/ethernet/chelsio/cxgb3/sge.c          |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |  6 +++---
 drivers/net/ethernet/cirrus/cs89x0.c              |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c       |  4 ++--
 drivers/net/ethernet/davicom/dm9000.c             |  2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c             |  4 ++--
 drivers/net/ethernet/dec/tulip/uli526x.c          |  4 ++--
 drivers/net/ethernet/dlink/sundance.c             |  2 +-
 drivers/net/ethernet/freescale/fec_main.c         |  2 +-
 drivers/net/ethernet/freescale/ucc_geth.c         |  2 +-
 drivers/net/ethernet/i825xx/lib82596.c            |  2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c         |  6 +++---
 drivers/net/ethernet/ibm/ibmveth.c                |  2 +-
 drivers/net/ethernet/jme.c                        |  2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |  4 ++--
 drivers/net/ethernet/marvell/skge.c               |  4 ++--
 drivers/net/ethernet/marvell/sky2.c               |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c             |  2 +-
 drivers/net/ethernet/neterion/s2io.c              |  6 +++---
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |  8 ++++----
 drivers/net/ethernet/nvidia/forcedeth.c           |  8 ++++----
 drivers/net/ethernet/silan/sc92031.c              |  2 +-
 drivers/net/ethernet/sis/sis900.c                 |  2 +-
 drivers/net/ethernet/smsc/smc911x.c               |  2 +-
 drivers/net/ethernet/smsc/smc91x.c                |  4 ++--
 drivers/net/ethernet/smsc/smsc911x.c              |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  2 +-
 drivers/net/ethernet/sun/sungem.c                 |  2 +-
 drivers/net/ethernet/tile/tilepro.c               |  4 ++--
 drivers/net/ethernet/toshiba/spider_net.c         |  2 +-
 drivers/net/ethernet/via/via-rhine.c              |  6 +++---
 drivers/net/ethernet/via/via-velocity.c           |  2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |  2 +-
 drivers/net/virtio_net.c                          |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                 |  2 +-
 drivers/net/xen-netfront.c                        |  2 +-
 drivers/staging/octeon/ethernet-tx.c              |  6 +++---
 drivers/staging/wlags49_h2/wl_netdev.c            |  6 +++---
 include/linux/if_vlan.h                           |  2 +-
 54 files changed, 99 insertions(+), 103 deletions(-)
