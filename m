From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 19 Nov 2013 17:18:48 -0500 (EST)
Message-ID: <20131119.171848.1682244975462854541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab3KSWSw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 17:18:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mostly these are fixes for fallout due to merge window changes, as well=
 as
cures for problems that have been with us for a much longer period of t=
ime.

1) Johannes Berg noticed two major deficiencies in our genetlink regist=
ration.
   Some genetlink protocols we passing in constant counts for their ops=
 array
   rather than something like ARRAY_SIZE(ops) or similar.  Also, some g=
enetlink
   protocols were using fixed IDs for their multicast groups.

   We have to retain these fixed IDs to keep existing userland tools
   working, but reserve them so that other multicast groups used by
   other protocols can not possibly conflict.

   In dealing with these two problems, we actually now use less state
   management for genetlink operations and multicast groups.

2) When configuring interface hardware timestamping, fix several driver=
s
   that simply do not validate that the hwtstamp_config value is one th=
e
   driver actually supports.  From Ben Hutchings.

3) Invalid memory references in mwifiex driver, from Amitkumar Karwar.

4) In dev_forward_skb(), set the skb->protocol in the right order relat=
ive
   to skb_scrub_packet().  From Alexei Starovoitov.

5) Bridge erroneously fails to use the proper wrapper functions to
   make calls to netdev_ops->ndo_vlan_rx_{add,kill}_vid.  Fix from
   Toshiaki Makita.

6) When detaching a bridge port, make sure to flush all VLAN IDs to
   prevent them from leaking, also from Toshiaki Makita.

7) Put in a compromise for TCP Small Queues so that deep queued devices
   that delay TX reclaim non-trivially don't have such a performance
   decrease.  One particularly problematic area is 802.11 AMPDU in wire=
less.
   From Eric Dumazet.

8) Fix crashes in tcp_fastopen_cache_get(), we can see NULL socket dsts
   here.  Fix from Eric Dumzaet, reported by Dave Jones.

9) Fix use after free in ipv6 SIT driver, from Willem de Bruijn.

10) When computing mergeable buffer sizes, virtio-net fails to take the
    virtio-net header into account.  From Michael Dalton.

11) Fix seqlock deadlock in ip4_datagram_connect() wrt. statistic bumpi=
ng,
    this one has been with us for a while.  From Eric Dumazet.

12) Fix NULL deref in the new TIPC fragmentation handling, from Erik
    Hugne.

13) 6lowpan bit used for traffic classification was wrong, from
    Jukka Rissanen.

14) macvlan has the same issue as normal vlans did wrt. propagating
    LRO disabling down to the real device, fix it the same way.  From
    Michal Kubecek.

15) CPSW driver needs to soft reset all slaves during suspend, from
    Daniel Mack.

16) Fix small frame pacing in FQ packet scheduler, from Eric Dumazet.

17) The xen-netfront RX buffer refill timer isn't properly scheduled
    on partial RX allocation success, from Ma JieYue.

18) When ipv6 ping protocol support was added, the AF_INET6 protocol
    initialization cleanup path on failure was borked a little.  Fix
    from Vlad Yasevich.

19) If a socket disconnects during a read/recvmsg/recvfrom/etc. that bl=
ocks
    we can do the wrong thing with the msg_name we write back to usersp=
ace.
    From Hannes Frederic Sowa.  There is another fix in the works from
    Hannes which will prevent future problems of this nature.

20) Fix route leak in VTI tunnel transmit, from Fan Du.

Please pull, thanks a lot!

The following changes since commit 42a2d923cc349583ebf6fdd52a7d35e1c2f7=
e6bd:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2=
013-11-13 17:40:34 +0900)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 091e0662ee2c37867ad918ce7b6ddd17f0e090e2=
:

  Merge branch 'genetlink_mcast' (2013-11-19 16:39:42 -0500)

----------------------------------------------------------------

Ajit Khaparde (2):
      be2net: Fix unconditional enabling of Rx interface options
      be2net: Delete secondary unicast MAC addresses during be_close

Alexei Starovoitov (1):
      core/dev: do not ignore dmac in dev_forward_skb()

Amitkumar Karwar (4):
      mwifiex: replace u16 with __le16 in struct mwifiex_types_power_gr=
oup
      mwifiex: fix invalid memory access in mwifiex_get_power_level()
      mwifiex: fix invalid memory access in mwifiex_ret_tx_rate_cfg()
      mwifiex: fix invalid memory access in mwifiex_update_autoindex_ie=
s()

Andrey Vagin (1):
      tcp: don't update snd_nxt, when a socket is switched from repair =
mode

Avinash Patil (1):
      mwifiex: correct packet length for packets from SDIO interface

Ben Hutchings (6):
      tg3: Validate hwtstamp_config completely before applying it
      e1000e: Validate hwtstamp_config completely before applying it
      pch_gbe: Validate hwtstamp_config completely before applying it
      stmmac: Validate hwtstamp_config completely before applying it
      ti_cpsw: Validate hwtstamp_config completely before applying it
      ixp4xx_eth: Validate hwtstamp_config completely before applying i=
t

Chang Xiangzhong (1):
      net: sctp: bug-fixing: retran_path not set properly after transpo=
rts recovering (v3)

Chris Metcalf (1):
      connector: improved unaligned access error fix

Colin Ian King (1):
      rtlwifi: fix null dereference on efuse_word on kmalloc fail retur=
ns NULL

Dan Carpenter (7):
      mwifiex: potential integer underflow in mwifiex_ret_wmm_get_statu=
s()
      libertas: potential oops in debugfs
      wcn36xx: harmless memory corruption bug in debugfs
      wcn36xx: missing unlocks on error paths
      net: cdc_ncm: cleanup a type issue in cdc_ncm_setup()
      net: mv643xx_eth: potential NULL dereference in probe()
      isdnloop: use strlcpy() instead of strcpy()

Dan Williams (1):
      prism54: set netdev type to "wlan"

Daniel Borkmann (2):
      random32: add __init prefix to prandom_start_seed_timer
      random32: use msecs_to_jiffies for reseed timer

Daniel Mack (1):
      net: ethernet: ti/cpsw: do not crash on single-MAC machines durin=
g resume

David S. Miller (7):
      Merge branch 'hwtstamp'
      Merge branch 'genetlink'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'macvlan'
      net: Handle CHECKSUM_COMPLETE more adequately in pskb_trim_rcsum(=
).
      Merge branch 'bnx2x'
      Merge branch 'genetlink_mcast'

Divy Le Ray (1):
      MAINTAINERS: cxgb3: Update cxgb3 maintainer entry

Dmitry Kravkov (4):
      bnx2x: Clean the sp rtnl task upon unload
      bnx2x: Prevent panic during DMAE timeout
      bnx2x: prevent CFC attention
      bnx2x: Prevent "timeout waiting for state X"

Duan Fugang-B38611 (1):
      net:fec: fix WARNING caused by lack of calls to dma_mapping_error=
()

Eric Dumazet (5):
      tcp: tsq: restore minimal amount of queueing
      net-tcp: fix panic in tcp_fastopen_cache_set()
      ipv4: fix possible seqlock deadlock
      pkt_sched: fq: warn users using defrate
      pkt_sched: fq: fix pacing for small frames

Erik Hugne (1):
      tipc: fix dereference before check warning

=46abio Estevam (1):
      net: ipv6: ndisc: Fix warning when CONFIG_SYSCTL=3Dn

=46elipe Pena (2):
      wireless: rt2800lib: Fix typo on checking
      rtlwifi: rtl8192se: Fix wrong assignment

=46elix Fietkau (1):
      usbnet: fix status interrupt urb handling

Geyslan G. Bem (1):
      net/hsr: Fix possible leak in 'hsr_get_node_status()'

Hannes Frederic Sowa (2):
      inet: prevent leakage of uninitialized memory to user in recv sys=
calls
      ping: prevent NULL pointer dereference on write to msg_name

Janusz Dziedzic (2):
      ath9k: DFS radar use correct width enum
      ath9k: dfs_debug fix possible NULL dereference

Jason Wang (2):
      tuntap: limit head length of skb allocated
      macvtap: limit head length of skb allocated

Johannes Berg (21):
      taskstats: use genl_register_family_with_ops()
      hsr: use genl_register_family_with_ops()
      ieee802154: use genl_register_family_with_ops()
      wimax: use genl_register_family_with_ops()
      genetlink: remove genl_register_ops/genl_unregister_ops
      genetlink: register family ops as array
      genetlink: allow making ops const
      genetlink: make all genl_ops users const
      genetlink: make genl_ops flags a u8 and move to end
      genetlink: unify registration functions
      genetlink: rename shadowed variable
      netlink: fix documentation typo in netlink_set_err()
      genetlink: only pass array to genl_register_family_with_ops()
      drop_monitor/genetlink: use proper genetlink multicast APIs
      quota/genetlink: use proper genetlink multicast APIs
      hsr: don't call genl_unregister_mc_group()
      genetlink: remove genl_unregister_mc_group()
      genetlink: remove family pointer from genl_multicast_group
      genetlink: add and use genl_set_err()
      genetlink: pass family to functions using groups
      genetlink: make multicast groups const, prevent abuse

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jukka Rissanen (1):
      6lowpan: Uncompression of traffic class field was incorrect

Larry Finger (3):
      rtlwifi: rtl8192se: Fix incorrect signal strength for unassociate=
d AP
      rtlwifi: rtl8192cu: Fix incorrect signal strength for unassociate=
d AP
      rtlwifi: rtl8192de: Fix incorrect signal strength for unassociate=
d AP

Ma JieYue (1):
      xen-netfront: fix missing rx_refill_timer when allocate memory fa=
iled

Maciej =AFenczykowski (1):
      pkt_sched: fq: change classification of control packets

Mark Cave-Ayland (1):
      rtlwifi: Fix endian error in extracting packet type

Michael Dalton (1):
      virtio-net: mergeable buffer size should include virtio-net heade=
r

Michal Kube=E8ek (2):
      macvlan: introduce macvlan_dev_real_dev() helper function
      macvlan: disable LRO on lower device instead of macvlan

Nicolas Dichtel (4):
      sit: fix prefix length of ll and v4mapped addresses
      sit: link local routes are missing
      sit/gre6: don't try to add the same route two times
      ip6tnl: fix use after free of fb_tnl_dev

Nikolay Aleksandrov (1):
      bonding: fix two race conditions in bond_store_updelay/downdelay

Petko Manolov (1):
      MAINTAINERS: Update Pegasus and RTL8150 repositories;

Stanislaw Gruszka (1):
      rt2x00: fix HT TX descriptor settings regression

Sujith Manoharan (1):
      ath9k: Use correct PCIE initvals for AR9485

Toshiaki Makita (3):
      bridge: Use vlan_vid_[add/del] instead of direct ndo_vlan_rx_[add=
/kill]_vid calls
      bridge: Call vlan_vid_del for all vids at nbp_vlan_flush
      bridge: Fix memory leak when deleting bridge with vlan filtering =
enabled

Ujjal Roy (1):
      mwifiex: fix wrong eth_hdr usage for bridged packets in AP mode

Veaceslav Falico (1):
      bonding: don't permit to use ARP monitoring in 802.3ad mode

Vlad Yasevich (1):
      ipv6: Fix inet6_init() cleanup order

Wang Weidong (1):
      bonding: add ip checks when store ip target

Wei Yongjun (2):
      libertas: fix error return code in if_cs_probe()
      wcn36xx: Add missing unlock before return

Willem de Bruijn (1):
      sit: fix use after free of fb_tunnel_dev

Ying Xue (1):
      atm: idt77252: fix dev refcnt leak

Zhi Yong Wu (1):
      net, virtio_net: replace the magic value

fan.du (1):
      xfrm: Release dst if this dst is improper for vti tunnel

hahnjo (1):
      alx: Reset phy speed after resume

 Documentation/networking/ip-sysctl.txt               |   3 -
 MAINTAINERS                                          |  10 +-
 drivers/acpi/event.c                                 |  25 ++--
 drivers/atm/idt77252.c                               |   2 +-
 drivers/connector/cn_proc.c                          |  72 +++++-----
 drivers/isdn/isdnloop/isdnloop.c                     |   8 +-
 drivers/net/bonding/bond_sysfs.c                     |  30 ++---
 drivers/net/bonding/bonding.h                        |   3 +
 drivers/net/ethernet/atheros/alx/main.c              |   3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h          |   1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |   4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c      |   5 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |  17 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h      |  11 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c     |   2 +-
 drivers/net/ethernet/broadcom/tg3.c                  |  16 +--
 drivers/net/ethernet/emulex/benet/be_cmds.c          |  16 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.h          |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c          |   7 +-
 drivers/net/ethernet/freescale/fec_main.c            |  31 ++++-
 drivers/net/ethernet/intel/e1000e/netdev.c           |  14 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c           |   3 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |  12 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  12 +-
 drivers/net/ethernet/ti/cpsw.c                       |  36 ++---
 drivers/net/ethernet/xscale/ixp4xx_eth.c             |  12 +-
 drivers/net/macvtap.c                                |   8 +-
 drivers/net/team/team.c                              |  29 +---
 drivers/net/tun.c                                    |  10 +-
 drivers/net/usb/cdc_ncm.c                            |   2 +-
 drivers/net/usb/usbnet.c                             |   3 -
 drivers/net/virtio_net.c                             |  34 ++---
 drivers/net/wireless/ath/ath9k/ar9003_hw.c           |  22 +--
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h     |  42 ++----
 drivers/net/wireless/ath/ath9k/ath9k.h               |  19 +--
 drivers/net/wireless/ath/ath9k/dfs_debug.c           |  13 +-
 drivers/net/wireless/ath/ath9k/hw.h                  |   1 +
 drivers/net/wireless/ath/ath9k/init.c                |   9 +-
 drivers/net/wireless/ath/ath9k/pci.c                 |  87 +++++++++++=
+
 drivers/net/wireless/ath/wcn36xx/debug.c             |   2 +-
 drivers/net/wireless/ath/wcn36xx/smd.c               |   9 +-
 drivers/net/wireless/libertas/debugfs.c              |   6 +-
 drivers/net/wireless/libertas/if_cs.c                |   1 +
 drivers/net/wireless/mac80211_hwsim.c                |   5 +-
 drivers/net/wireless/mwifiex/fw.h                    |   4 +-
 drivers/net/wireless/mwifiex/ie.c                    |  11 +-
 drivers/net/wireless/mwifiex/sdio.c                  |   3 +
 drivers/net/wireless/mwifiex/sta_cmd.c               |   4 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c           |  46 ++++---
 drivers/net/wireless/mwifiex/sta_ioctl.c             |   5 +-
 drivers/net/wireless/mwifiex/uap_txrx.c              |  29 +++-
 drivers/net/wireless/mwifiex/wmm.c                   |   3 +
 drivers/net/wireless/prism54/islpci_dev.c            |   7 +-
 drivers/net/wireless/rt2x00/rt2800lib.c              |   2 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h              |   2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c              |   4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c            |   4 +-
 drivers/net/wireless/rtlwifi/base.c                  |  93 ++++++-----=
--
 drivers/net/wireless/rtlwifi/efuse.c                 |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c         |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c         |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c          |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c         |   2 +-
 drivers/net/wireless/rtlwifi/wifi.h                  |   6 +-
 drivers/net/xen-netfront.c                           |   7 +-
 drivers/scsi/pmcraid.c                               |   3 +-
 drivers/thermal/thermal_core.c                       |  25 ++--
 fs/dlm/netlink.c                                     |  10 +-
 fs/quota/netlink.c                                   |  16 ++-
 include/linux/genl_magic_func.h                      |  53 +++-----
 include/linux/if_macvlan.h                           |  17 +++
 include/linux/skbuff.h                               |  39 +++---
 include/net/genetlink.h                              | 131 +++++++++++=
+------
 include/uapi/linux/genetlink.h                       |   1 +
 include/uapi/linux/pkt_sched.h                       |   7 +-
 kernel/taskstats.c                                   |  38 ++----
 lib/random32.c                                       |  12 +-
 net/bridge/br_if.c                                   |   1 +
 net/bridge/br_vlan.c                                 |  24 ++--
 net/core/dev.c                                       |  11 +-
 net/core/drop_monitor.c                              |  15 ++-
 net/hsr/hsr_netlink.c                                |  64 +++------
 net/ieee802154/6lowpan.c                             |   4 +-
 net/ieee802154/dgram.c                               |   3 +-
 net/ieee802154/ieee802154.h                          |  21 ++-
 net/ieee802154/netlink.c                             |  45 ++++---
 net/ieee802154/nl-mac.c                              |  79 ++---------
 net/ieee802154/nl-phy.c                              |  37 +-----
 net/ipv4/datagram.c                                  |   2 +-
 net/ipv4/ip_tunnel.c                                 |   4 +-
 net/ipv4/ip_vti.c                                    |   1 +
 net/ipv4/ping.c                                      |  49 ++++---
 net/ipv4/raw.c                                       |   4 +-
 net/ipv4/tcp.c                                       |   6 -
 net/ipv4/tcp_metrics.c                               |  10 +-
 net/ipv4/tcp_output.c                                |   7 +-
 net/ipv4/udp.c                                       |   7 +-
 net/ipv6/addrconf.c                                  |  38 ++----
 net/ipv6/af_inet6.c                                  |   4 +-
 net/ipv6/ip6_tunnel.c                                |  18 ++-
 net/ipv6/ndisc.c                                     |   2 +-
 net/ipv6/raw.c                                       |   4 +-
 net/ipv6/sit.c                                       |  18 ++-
 net/ipv6/udp.c                                       |   5 +-
 net/irda/irnetlink.c                                 |   5 +-
 net/l2tp/l2tp_ip.c                                   |   4 +-
 net/l2tp/l2tp_netlink.c                              |   9 +-
 net/netfilter/ipvs/ip_vs_ctl.c                       |   4 +-
 net/netlabel/netlabel_cipso_v4.c                     |   4 +-
 net/netlabel/netlabel_mgmt.c                         |   4 +-
 net/netlabel/netlabel_unlabeled.c                    |   4 +-
 net/netlink/af_netlink.c                             |   2 +-
 net/netlink/genetlink.c                              | 524 +++++++++++=
+++++++++++++++++++++++--------------------------------------
 net/nfc/netlink.c                                    |  41 +++---
 net/openvswitch/datapath.c                           |  59 ++++----
 net/openvswitch/datapath.h                           |   1 +
 net/openvswitch/dp_notify.c                          |  11 +-
 net/phonet/datagram.c                                |   9 +-
 net/sched/sch_fq.c                                   |  40 +++---
 net/sctp/associola.c                                 |   6 +-
 net/tipc/link.c                                      |   3 +-
 net/tipc/netlink.c                                   |  11 +-
 net/wimax/op-msg.c                                   |  27 +---
 net/wimax/op-reset.c                                 |  17 ---
 net/wimax/op-rfkill.c                                |  21 ---
 net/wimax/op-state-get.c                             |  17 ---
 net/wimax/stack.c                                    |  95 +++++++----=
--
 net/wimax/wimax-internal.h                           |   8 +-
 net/wireless/nl80211.c                               | 206 +++++++++++=
++---------------
 129 files changed, 1437 insertions(+), 1432 deletions(-)
