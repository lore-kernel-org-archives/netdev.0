From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 00/20] extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:05 -0700
Message-ID: <1302050665-10460-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:53946 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1DFAol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Extend "*features" from word to a BITMAP. This will eliminate the current upper
bound. Also making it a bitmap will allow us to use (set/test/clear)_bit()
macros/inline functions. So operation -
    dev->features |= NETIF_F_SG
can be performed like-
    set_bit(NETIF_F_SG_BIT, dev->feature);

Again it's not as easy as it looks since operations like -
   bitmap = bitmap-a & bitmap-b 
will be difficult but at the same time it would be imposible to use |=
operations for multi-word flags too. Bitmap will make it easier to manage
multi-word features but will need some macro / wrapper writing to achieve
complex bit manipulations. 

Since the use of "features" is wide-spread, this can not be done in one shot.
So breaking the work into following 4 steps of which first two steps will be
achieved by this patch. Third step is the one which will take longer.

(1) convert hw_features and wanted_features to a bitmap but maintain the
    backword compatibility with legacy_* option. 
(2) Define fake macros for vlan_features and features until all the work of
    converion is not complete.
(3) Complete the conversion.
(4) Define bitmaps for features and vlan_features.

We can add step (5) which is to convert the use of legacy_* stuff and use the
newer way only.


Mahesh Bandewar (20):
  net-core: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-ipv4: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-ipv6: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-vlan: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-bridge: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-decnet: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-dsa: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-l2tp: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-phonet: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-sctp: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  net-wireless: extending (hw_/wanted_/vlan_)features fields to a
    bitmap.
  loopback: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  veth: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  jme: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  sungem: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  sunhme: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  usb-smsc75xx: extending (hw_/wanted_/vlan_)features fields to a
    bitmap.
  usb-smsc95xx: extending (hw_/wanted_/vlan_)features fields to a
    bitmap.
  virtio_net: extending (hw_/wanted_/vlan_)features fields to a bitmap.
  xen: extending (hw_/wanted_/vlan_)features fields to a bitmap.

 drivers/net/jme.c                  |   12 ++--
 drivers/net/loopback.c             |    4 +-
 drivers/net/sungem.c               |    7 +-
 drivers/net/sunhme.c               |    8 +-
 drivers/net/usb/smsc75xx.c         |   12 ++--
 drivers/net/usb/smsc95xx.c         |   12 ++--
 drivers/net/veth.c                 |    6 +-
 drivers/net/virtio_net.c           |   21 ++++---
 drivers/net/xen-netfront.c         |    8 +-
 include/linux/if_vlan.h            |    4 +-
 include/linux/netdevice.h          |  110 +++++++++++++++++++++++++-----------
 net/8021q/vlan.c                   |   12 ++--
 net/8021q/vlan_dev.c               |    9 ++-
 net/bridge/br_device.c             |    2 +-
 net/bridge/br_if.c                 |    4 +-
 net/core/dev.c                     |   51 +++++++++--------
 net/core/ethtool.c                 |   97 ++++++++++++++++----------------
 net/core/net-sysfs.c               |    4 +-
 net/core/sock.c                    |    2 +-
 net/dccp/ipv6.c                    |    2 +-
 net/decnet/af_decnet.c             |    2 +-
 net/decnet/dn_nsp_out.c            |    2 +-
 net/dsa/slave.c                    |    4 +-
 net/ipv4/ip_gre.c                  |    6 +-
 net/ipv4/ip_output.c               |   12 ++--
 net/ipv4/ipip.c                    |    4 +-
 net/ipv4/ipmr.c                    |    2 +-
 net/ipv4/netfilter/nf_nat_helper.c |    2 +-
 net/ipv6/ip6_output.c              |    6 +-
 net/ipv6/ip6_tunnel.c              |    2 +-
 net/ipv6/ip6mr.c                   |    2 +-
 net/ipv6/sit.c                     |    4 +-
 net/l2tp/l2tp_core.c               |    2 +-
 net/phonet/pep-gprs.c              |    2 +-
 net/sctp/output.c                  |    4 +-
 net/wireless/core.c                |   10 ++--
 36 files changed, 251 insertions(+), 202 deletions(-)

-- 
1.7.3.1

