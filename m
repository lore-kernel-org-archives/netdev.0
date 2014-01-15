From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v4 0/7] Intel Wired LAN Driver Updates, ixgbe: Add LER support
Date: Tue, 14 Jan 2014 18:53:10 -0800
Message-ID: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mark Rustad <mark.d.rustad@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60171 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbaAOCx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 21:53:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add Live Error Recovery (LER) support to the
ixgbe driver. This support also improves behavior in Thunderbolt
environments. This involves checking all register reads for a
value of all ones and when that is seen, to read the status
register, which should never properly return all ones, to
confirm whether the received value was correct. When this detects
a removal, the hw_addr field is cleared to indicate the removal.
This then blocks subsequent access to the device registers.

All register access macros have been changed to static inline
functions and all register accesses now use them.=C2=B7 Macro versions
are temporarily provided.

The __IXGBE_DOWN bit is no longer overloaded to also mean that
device removal has been initiated. Now the bit can be used to
protect ixgbe_down from multiple entry via test_and_set_bit. A
needed smp_mb__before_clear_bit was also added.

V2 Changes:
- Use ACCESS_ONCE where needed, thanks to Ben Hutchings
- Fix crash on module removal
- Use boolean values for boolean returns instead of 0 and 1
- Reword Kconfig help text

V3 Changes:
- Drop config option, per David Miller
- Drop tail register write checks, per Alexander Duyck
- Change writeq implementation to a static inline, thanks to Joe Perche=
s

V4 Changes:
- Change __IXGBE_REMOVE to __IXGBE_REMOVING, per Scott Feldman's commen=
t
- Add #define writeq writeq, per Alexander Duyck
- Change static inline functions to lower case, per David Miller
- Use new lower case names in added and modified register accesses
- Provide temporary upper case macros for register access functions
- Change IXGBE_REMOVED from macro to static inline and change reference=
s
- Correct IXGBE_WRITE_FLUSH to properly enclose parameter expansion

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>

Mark Rustad (7):
  ixgbe: Indicate removal state explicitly
  ixbge: Protect ixgbe_down with __IXGBE_DOWN bit
  ixgbe: Use static inlines instead of macros
  ixgbe: Make ethtool register test use accessors
  ixgbe: Check register reads for adapter removal
  ixgbe: Check for adapter removal on register writes
  ixgbe: Additional adapter removal checks

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   7 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  65 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 120 +++++++++++++--=
--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  74 +++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 +-
 6 files changed, 194 insertions(+), 77 deletions(-)

--=20
1.8.5.GIT
