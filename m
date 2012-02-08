From: greearb@candelatech.com
Subject: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Wed,  8 Feb 2012 11:54:35 -0800
Message-ID: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55699 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab2BHTyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:54:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This patch series enables some features designed to make
testing ethernet devices and debugging link-level errors
easier.

First, support is added for receiving the Ethernet FCS.  This
allows stock wireshark to show you the actual Ethernet FCS.

Second, allow sending packets with user-specified Ethernet
FCS.  The user can specify bad FCS in order to test network
equipments' handling of FCS errors, or, in strange cases,
users might want to implement their own FCS scheme.

Third, allow configuring a NIC to receive errored (and possibly
other types of packets not normally passed up the stack).  This
allows sniffers to show packets with bad FCS, for instance.

These features have been tested on e100 and e1000e.  The
e1000 patch has not been tested yet.

Changes from first posting:

*  Ensure nic reset when changing the rx-fcs and rx-all
   logic in e100 (e1000e already did this).

*  Use priv-flag for the 'send customized CRC' logic and
   make it non configurable (if NIC supports it, feature is
   enabled)  Please note that this will only be used when the
   SKB is specifically flagged as wanting this behaviour.

*  Use EPROTONOSUPPORT error to indicate the packet-socket's bound
   NIC does not support the 'send customized CRC' feature.

*  Some general cleanup, and patch re-ordering.


There was a suggestion to throw away packets flagged as bad by
the NIC.  I did not add any additional logic to do this.  I think
it is not needed, but I am open to other opinions.


Ben Greear (10):
  net: Support RXFCS feature flag.
  e100: Support RXFCS feature flag.
  e1000e:  Support RXFCS feature flag.
  net: Add framework to allow sending packets with customized CRC.
  e100: Support sending custom Ethernet CRC
  e1000e:  Support sending custom Ethernet CRC.
  net:  Support RX-ALL feature flag.
  e1000e:  Support RXALL feature flag.
  e100:  Support RXALL feature flag.
  e1000: Support sending custom Ethernet CRC.

 Documentation/networking/netdev-features.txt  |   13 ++++
 arch/alpha/include/asm/socket.h               |    3 +
 arch/arm/include/asm/socket.h                 |    3 +
 arch/avr32/include/asm/socket.h               |    3 +
 arch/cris/include/asm/socket.h                |    3 +
 arch/frv/include/asm/socket.h                 |    3 +
 arch/h8300/include/asm/socket.h               |    3 +
 arch/ia64/include/asm/socket.h                |    3 +
 arch/m32r/include/asm/socket.h                |    3 +
 arch/m68k/include/asm/socket.h                |    3 +
 arch/mips/include/asm/socket.h                |    3 +
 arch/mn10300/include/asm/socket.h             |    3 +
 arch/parisc/include/asm/socket.h              |    4 +
 arch/powerpc/include/asm/socket.h             |    3 +
 arch/s390/include/asm/socket.h                |    3 +
 arch/sparc/include/asm/socket.h               |    4 +
 arch/xtensa/include/asm/socket.h              |    3 +
 drivers/net/ethernet/intel/e100.c             |   66 +++++++++++++++++++-
 drivers/net/ethernet/intel/e1000/e1000_main.c |   13 ++++
 drivers/net/ethernet/intel/e1000e/defines.h   |    1 +
 drivers/net/ethernet/intel/e1000e/e1000.h     |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c    |   80 +++++++++++++++++++++---
 drivers/net/ethernet/intel/e1000e/param.c     |    5 +-
 include/asm-generic/socket.h                  |    4 +
 include/linux/if.h                            |    2 +
 include/linux/netdev_features.h               |    4 +
 include/linux/netdevice.h                     |    8 ++-
 include/linux/skbuff.h                        |    4 +-
 include/net/sock.h                            |    4 +
 net/core/ethtool.c                            |    2 +
 net/core/skbuff.c                             |    1 +
 net/core/sock.c                               |    4 +
 net/packet/af_packet.c                        |   32 +++++++++-
 33 files changed, 273 insertions(+), 21 deletions(-)

-- 
1.7.3.4
