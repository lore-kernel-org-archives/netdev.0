From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v2 net-next 0/2] net: centralize net_device MTU bounds checking
Date: Wed, 28 Sep 2016 18:20:51 -0400
Message-ID: <20160928222053.33697-1-jarod@redhat.com>
References: <20160912201106.47837-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752922AbcI1WVH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 18:21:07 -0400
In-Reply-To: <20160912201106.47837-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking into an MTU issue with sfc, I started noticing that almost
every NIC driver with an ndo_change_mtu function implemented almost
exactly the same range checks, and in many cases, that was the only
practical thing their ndo_change_mtu function was doing. Quite a few
drivers have either 68, 64, 60 or 46 as their minimum MTU value checked,
and then various sizes from 1500 to 65535 for their maximum MTU value. We
can remove a whole lot of redundant code here if we simple store min_mtu
and max_mtu in net_device, and check against those in net/core/dev.c's
dev_set_mtu().

This pair of patches looks to introduce centralized MTU range checking
infrastructure, while maintaining compatibility with all existing drivers,
and start to make use of it, converting all eth_change_mtu/ether_setup users
over to this new infra.

Assuming these pass review muster, I've got a ton of follow-on patches to
clean up MTU settings for everything in the kernel with an ndo_change_mtu.

This work is all staged in a (rebasing) git tree here:

https://github.com/jarodwilson/linux-muck

The master branch is based on net-next from today, and carries these two
patches, plus a ton of follow-on patches to eliminate MTU range checks
and change_mtu functions where possible. All patches were successfully
built across 160 various arch and config combos by the 0-day folks.
(Thanks to Andrew Lunn for the suggestion to get that going).

Resending, because I forgot to add CC list to the actual patches.

Jarod Wilson (2):
  net: centralize net_device min/max MTU checking
  net: deprecate eth_change_mtu, remove usage

 arch/m68k/emu/nfeth.c                                 |  1 -
 drivers/isdn/hysdn/hysdn_net.c                        |  1 -
 drivers/media/dvb-core/dvb_net.c                      |  2 +-
 drivers/net/appletalk/ipddp.c                         |  1 -
 drivers/net/cris/eth_v10.c                            |  1 -
 drivers/net/ethernet/3com/3c509.c                     |  1 -
 drivers/net/ethernet/3com/3c515.c                     |  1 -
 drivers/net/ethernet/3com/3c574_cs.c                  |  1 -
 drivers/net/ethernet/3com/3c589_cs.c                  |  1 -
 drivers/net/ethernet/3com/3c59x.c                     |  2 --
 drivers/net/ethernet/3com/typhoon.c                   |  1 -
 drivers/net/ethernet/8390/8390.c                      |  1 -
 drivers/net/ethernet/8390/8390p.c                     |  1 -
 drivers/net/ethernet/8390/ax88796.c                   |  1 -
 drivers/net/ethernet/8390/axnet_cs.c                  |  1 -
 drivers/net/ethernet/8390/etherh.c                    |  1 -
 drivers/net/ethernet/8390/hydra.c                     |  1 -
 drivers/net/ethernet/8390/mac8390.c                   |  1 -
 drivers/net/ethernet/8390/mcf8390.c                   |  1 -
 drivers/net/ethernet/8390/ne2k-pci.c                  |  1 -
 drivers/net/ethernet/8390/pcnet_cs.c                  |  1 -
 drivers/net/ethernet/8390/smc-ultra.c                 |  1 -
 drivers/net/ethernet/8390/wd.c                        |  1 -
 drivers/net/ethernet/8390/zorro8390.c                 |  1 -
 drivers/net/ethernet/adaptec/starfire.c               |  1 -
 drivers/net/ethernet/adi/bfin_mac.c                   |  1 -
 drivers/net/ethernet/allwinner/sun4i-emac.c           |  1 -
 drivers/net/ethernet/amd/a2065.c                      |  1 -
 drivers/net/ethernet/amd/am79c961a.c                  |  1 -
 drivers/net/ethernet/amd/ariadne.c                    |  1 -
 drivers/net/ethernet/amd/atarilance.c                 |  1 -
 drivers/net/ethernet/amd/au1000_eth.c                 |  1 -
 drivers/net/ethernet/amd/declance.c                   |  1 -
 drivers/net/ethernet/amd/hplance.c                    |  1 -
 drivers/net/ethernet/amd/lance.c                      |  1 -
 drivers/net/ethernet/amd/mvme147.c                    |  1 -
 drivers/net/ethernet/amd/ni65.c                       |  1 -
 drivers/net/ethernet/amd/nmclan_cs.c                  |  1 -
 drivers/net/ethernet/amd/pcnet32.c                    |  1 -
 drivers/net/ethernet/amd/sun3lance.c                  |  1 -
 drivers/net/ethernet/amd/sunlance.c                   |  1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      |  1 -
 drivers/net/ethernet/apple/bmac.c                     |  1 -
 drivers/net/ethernet/apple/mace.c                     |  1 -
 drivers/net/ethernet/apple/macmace.c                  |  1 -
 drivers/net/ethernet/aurora/nb8800.c                  |  1 -
 drivers/net/ethernet/cadence/macb.c                   |  1 -
 drivers/net/ethernet/cirrus/cs89x0.c                  |  1 -
 drivers/net/ethernet/cirrus/ep93xx_eth.c              |  1 -
 drivers/net/ethernet/cirrus/mac89x0.c                 |  1 -
 drivers/net/ethernet/davicom/dm9000.c                 |  1 -
 drivers/net/ethernet/dec/tulip/de2104x.c              |  1 -
 drivers/net/ethernet/dec/tulip/de4x5.c                |  1 -
 drivers/net/ethernet/dec/tulip/dmfe.c                 |  1 -
 drivers/net/ethernet/dec/tulip/tulip_core.c           |  1 -
 drivers/net/ethernet/dec/tulip/uli526x.c              |  1 -
 drivers/net/ethernet/dec/tulip/winbond-840.c          |  1 -
 drivers/net/ethernet/dec/tulip/xircom_cb.c            |  1 -
 drivers/net/ethernet/dnet.c                           |  1 -
 drivers/net/ethernet/ec_bhf.c                         |  1 -
 drivers/net/ethernet/fealnx.c                         |  1 -
 drivers/net/ethernet/freescale/fec_main.c             |  1 -
 drivers/net/ethernet/freescale/fec_mpc52xx.c          |  1 -
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |  1 -
 drivers/net/ethernet/freescale/ucc_geth.c             |  1 -
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c             |  1 -
 drivers/net/ethernet/hisilicon/hip04_eth.c            |  1 -
 drivers/net/ethernet/hisilicon/hisi_femac.c           |  1 -
 drivers/net/ethernet/hp/hp100.c                       |  2 --
 drivers/net/ethernet/i825xx/82596.c                   |  1 -
 drivers/net/ethernet/i825xx/ether1.c                  |  1 -
 drivers/net/ethernet/i825xx/lib82596.c                |  1 -
 drivers/net/ethernet/i825xx/sun3_82586.c              |  1 -
 drivers/net/ethernet/ibm/emac/core.c                  |  1 -
 drivers/net/ethernet/korina.c                         |  1 -
 drivers/net/ethernet/lantiq_etop.c                    | 18 ++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.c           |  1 -
 drivers/net/ethernet/micrel/ks8851.c                  |  1 -
 drivers/net/ethernet/micrel/ks8851_mll.c              |  1 -
 drivers/net/ethernet/microchip/enc28j60.c             |  1 -
 drivers/net/ethernet/moxa/moxart_ether.c              |  1 -
 drivers/net/ethernet/natsemi/jazzsonic.c              |  1 -
 drivers/net/ethernet/natsemi/macsonic.c               |  1 -
 drivers/net/ethernet/natsemi/xtsonic.c                |  1 -
 drivers/net/ethernet/netx-eth.c                       |  1 -
 drivers/net/ethernet/nuvoton/w90p910_ether.c          |  1 -
 drivers/net/ethernet/nxp/lpc_eth.c                    |  1 -
 drivers/net/ethernet/packetengines/hamachi.c          |  1 -
 drivers/net/ethernet/packetengines/yellowfin.c        |  1 -
 drivers/net/ethernet/qlogic/qla3xxx.c                 |  1 -
 drivers/net/ethernet/rdc/r6040.c                      |  1 -
 drivers/net/ethernet/realtek/atp.c                    |  1 -
 drivers/net/ethernet/renesas/ravb_main.c              |  1 -
 drivers/net/ethernet/renesas/sh_eth.c                 |  2 --
 drivers/net/ethernet/seeq/ether3.c                    |  1 -
 drivers/net/ethernet/seeq/sgiseeq.c                   |  1 -
 drivers/net/ethernet/sgi/ioc3-eth.c                   |  1 -
 drivers/net/ethernet/sgi/meth.c                       |  1 -
 drivers/net/ethernet/silan/sc92031.c                  |  1 -
 drivers/net/ethernet/sis/sis190.c                     |  1 -
 drivers/net/ethernet/sis/sis900.c                     |  1 -
 drivers/net/ethernet/smsc/epic100.c                   |  1 -
 drivers/net/ethernet/smsc/smc911x.c                   |  1 -
 drivers/net/ethernet/smsc/smc9194.c                   |  1 -
 drivers/net/ethernet/smsc/smc91c92_cs.c               |  1 -
 drivers/net/ethernet/smsc/smc91x.c                    |  1 -
 drivers/net/ethernet/smsc/smsc911x.c                  |  1 -
 drivers/net/ethernet/sun/sunbmac.c                    |  1 -
 drivers/net/ethernet/sun/sunhme.c                     |  1 -
 drivers/net/ethernet/sun/sunqe.c                      |  1 -
 drivers/net/ethernet/ti/cpmac.c                       |  1 -
 drivers/net/ethernet/ti/cpsw.c                        |  1 -
 drivers/net/ethernet/ti/tlan.c                        |  1 -
 drivers/net/ethernet/toshiba/tc35815.c                |  1 -
 drivers/net/ethernet/tundra/tsi108_eth.c              |  1 -
 drivers/net/ethernet/via/via-rhine.c                  |  1 -
 drivers/net/ethernet/wiznet/w5100.c                   |  1 -
 drivers/net/ethernet/wiznet/w5300.c                   |  1 -
 drivers/net/ethernet/xircom/xirc2ps_cs.c              |  1 -
 drivers/net/ethernet/xscale/ixp4xx_eth.c              |  1 -
 drivers/net/plip/plip.c                               |  1 -
 drivers/net/sb1000.c                                  |  1 -
 drivers/net/usb/catc.c                                |  1 -
 drivers/net/usb/kaweth.c                              |  1 -
 drivers/net/usb/pegasus.c                             |  1 -
 drivers/net/usb/r8152.c                               |  3 ++-
 drivers/net/usb/rtl8150.c                             |  1 -
 drivers/net/wan/sbni.c                                |  1 -
 drivers/net/wireless/intersil/prism54/islpci_dev.c    |  1 -
 drivers/net/wireless/mac80211_hwsim.c                 |  1 -
 drivers/net/wireless/marvell/libertas/main.c          |  1 -
 drivers/net/wireless/ray_cs.c                         |  1 -
 drivers/net/wireless/wl3501_cs.c                      |  1 -
 drivers/net/wireless/zydas/zd1201.c                   |  1 -
 drivers/staging/rtl8188eu/os_dep/mon.c                |  1 -
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c          |  1 -
 drivers/staging/rtl8192u/r8192U_core.c                |  1 -
 drivers/staging/slicoss/slicoss.c                     |  1 -
 include/linux/netdevice.h                             |  4 ++++
 include/uapi/linux/if_ether.h                         |  2 ++
 net/atm/br2684.c                                      |  2 --
 net/bluetooth/bnep/netdev.c                           |  1 -
 net/core/dev.c                                        | 12 ++++++++++--
 net/ethernet/eth.c                                    |  5 +++--
 net/irda/irlan/irlan_eth.c                            |  1 -
 145 files changed, 30 insertions(+), 158 deletions(-)

CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org

-- 
2.10.0
