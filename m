From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 00/11] 802154: implement
	link-layer security
Date: Fri, 16 May 2014 17:46:34 +0200
Message-ID: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series implements 802.15.4-2011 link layer security.

Patches 1 and 2 prepare for llsec by adding data structures to represent the
llsec PIB as specified in 802.15.4-2011. I've changed some structures from
their specification to be more sensible, since 802.15.4 specifies some
structures in not-exactly-useful ways. Nested lists are common, but not very
accessible for netlink methods, and not very fast to traverse when searching
for specific elements either.

Patch 3 implements backends for these structures in mac802154.

Patch 4 and 5 implement the encryption and decryption methods, split from patch
3 to ease review. The encryption and decryption methods are almost entirely
compliant with the specified outgoing/incoming frame procedures. Decryption
deviates from the specification slightly where the specification makes no
sense, i.e. encrypted frames with security level 0 may be sent, but must be
dropped an reception - but transforms for processing such frames are given a
few lines in the standard. I've opted to not drop these frames instead of not
implementing the transforms that wouldn't be used if they were dropped.

Patch 6 links the mac802154 llsec with the SoftMAC devices. This is mainly
init//fini code for llsec context, handling of security subheaders and calling
the encryption/decryption methods.

Patch 7 adds sockopts to 802.15.4 dgram sockets to modifiy outgoing security
parameters on a per-socket basis. Ideally, this would also be available for
sockets on 6lowpan devices, but I'm not sure how to do that nicely.

Patch 8 adds forwarders to the llsec configuration methods for netlink, patch
10 implements these netlink accessors. This is mainly mechanical.

Patch 11, implements a key tracking option for devices that previous patches
haven't, because I'm not entirely sure whether this is the best approach to the
problem. It performs reasonably well though, so I decided to include it as a
separate patch in this series instead of sending an RFC just for this one
option.

---

Phoebe Buckheister (11):
      ieee802154: add types for link-layer security
      mac802154: update Kconfig
      mac802154: add llsec structures and mutators
      mac802154: add llsec encryption method
      mac802154: add llsec decryption method
      mac802154: integrate llsec with wpan devices
      ieee802154: add dgram sockopts for security control
      mac802154: add llsec configuration functions
      mac802154: propagate device address changes to llsec
      ieee802154: add netlink interfaces for llsec
      ieee802154, mac802154: implement devkey record option


 include/linux/nl802154.h        |   31 ++
 include/net/af_ieee802154.h     |   10 +-
 include/net/ieee802154_netdev.h |  135 +++++
 net/ieee802154/dgram.c          |   66 +++
 net/ieee802154/ieee802154.h     |   19 +
 net/ieee802154/netlink.c        |   20 +
 net/ieee802154/nl-mac.c         |  807 +++++++++++++++++++++++++++++
 net/ieee802154/nl_policy.c      |   16 +
 net/mac802154/Kconfig           |    4 +
 net/mac802154/Makefile          |    3 +-
 net/mac802154/llsec.c           | 1067 +++++++++++++++++++++++++++++++++++++++
 net/mac802154/llsec.h           |  108 ++++
 net/mac802154/mac802154.h       |   44 ++
 net/mac802154/mac_cmd.c         |   42 +-
 net/mac802154/mib.c             |  187 +++++++
 net/mac802154/wpan.c            |  144 ++++--
 16 files changed, 2670 insertions(+), 33 deletions(-)


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
