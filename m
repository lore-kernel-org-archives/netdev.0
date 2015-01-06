From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps to 48 bits
Date: Mon,  5 Jan 2015 18:54:02 -0800
Message-ID: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

History:
  v2:
    - added ethtool_ops::get_compat_flags() to be able to check user
      parameters in generic ethtool layer when a driver does not
      support a new feature.
    - in generic ethtool code, EINVAL when userspace sets a link mode
      with bits 32..47 set, unless driver explicitly indicates that it
      supports it (get_compat_flags). also print a warning once (per
      lifetime, not per-interface) if driver sets bits 32..47 of link
      mode, unless it explicitly indicated that it supports 48bit link
      modes.
    - don't update phydev->advertising too early (ie. keep original behavior)
  v1:
    initial draft

This patch series increases the width of the supported/advertising
ethtool masks from 32 bits to 48. This should allow to breathe for a
couple more years (or... months?).

It should not cause any backward compatibility issues for
now. However, if user-space passed non-0 to previously-reserved fields
to ethtool_set_settings or ethtool_set_eee, they will be rejected by
non-updated (ie. no get_compat_flags) drivers. Updated drivers will
handle the new expanded link mode masks appropriately. It is
recommended we gradually adopt the new get/set API, and provide the
associated get_compat_flags(), in order to correctly support future
link modes. See ethtool.h for details.

I updated a couple drivers (mlx4, veth, tun), and some shared code in
drivers/net (phy, mii, mdio). It might be overkill for phy/mii/mdio,
and I might have missed other shared code in drivers/net. Please let
me know.

I used the compiler on my private copy to 1/ track where the
ethtool_cmd/ethtool_eee link mode fields were used 2/ track where the
link mode bitmaps are used and updated. So I believe that there is
some sort of transitive closure for the code I updated. Maybe tools
like coccinelle or clang could allow to automate these processes (1/
would probably be easy-ish, but 2/ seems a bit more complex)? I
reverted these internal "tracking" tricks for this version to minimize
impact on uapi/ethtool.h. The main resulting visible artifact of those
tricks is the new ethtool_link_mode_mask_t typedef (aka. u64). I kept
this trivial typedef here to help future refactoring, but I'd be happy
to rename it as plain "u64" if you prefer.

I can send updates to other drivers, even though it's rather pointless
to update 1G drivers at this point for example. Please let me know,
but I'd prefer to do this in follow-up patches outside this first
patch series.


############################################
# Patch Set Summary:

David Decotigny (8):
  net: ethtool: internal compatibility flags to reject non-zero reserved
    fields
  net: ethtool: extend link mode support to 48 bits
  net: phy: extend link mode support to 48 bits
  net: mii: extend link mode support to 48 bits
  net: mdio: extend link mode support to 48 bits
  net: veth: extend link mode support to 48 bits
  net: tun: extend link mode support to 48 bits
  net: mlx4_en: extend link mode support to 48 bits

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  73 ++++++++-----
 drivers/net/mdio.c                              |  59 +++++-----
 drivers/net/mii.c                               |  52 +++++----
 drivers/net/phy/phy.c                           |  30 +++---
 drivers/net/phy/phy_device.c                    |   4 +-
 drivers/net/tun.c                               |   4 +-
 drivers/net/veth.c                              |   4 +-
 include/linux/ethtool.h                         |  25 ++++-
 include/linux/mdio.h                            |  15 +--
 include/linux/mii.h                             |  31 +++---
 include/linux/phy.h                             |  10 +-
 include/uapi/linux/ethtool.h                    | 137 ++++++++++++++++++++----
 net/core/ethtool.c                              |  44 ++++++++
 13 files changed, 343 insertions(+), 145 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
