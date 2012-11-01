From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 net-next 0/8] enable/disable zero copy tx dynamically
Date: Thu, 1 Nov 2012 21:16:17 +0200
Message-ID: <cover.1351797353.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


tun supports zero copy transmit since 0690899b4d4501b3505be069b9a687e68ccbe15b,
however you can only enable this mode if you know your workload does not
trigger heavy guest to host/host to guest traffic - otherwise you
get a (minor) performance regression.
This patchset addresses this problem by notifying the owner
device when callback is invoked because of a data copy.
This makes it possible to detect whether zero copy is appropriate
dynamically: we start in zero copy mode, when we detect
data copied we disable zero copy for a while.

With this patch applied, I get the same performance for
guest to host and guest to guest both with and without zero copy tx.

Changes from v2:
  change callback parameter from int to bool
  accordingly, drop err parameter from skb_tx_error

Changes from v1:
  Comment fixups in patches 2 and 8 suggested by Vlad Yasevich,
     no changes to other patches

Michael S. Tsirkin (8):
  skb: report completion status for zero copy skbs
  skb: api to report errors for zero copy skbs
  tun: report orphan frags errors to zero copy callback
  vhost-net: cleanup macros for DMA status tracking
  vhost: track zero copy failures using DMA length
  vhost: move -net specific code out
  vhost-net: select tx zero copy dynamically
  vhost-net: reduce vq polling on tx zerocopy

 drivers/net/tun.c         |   1 +
 drivers/vhost/net.c       | 111 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/vhost/tcm_vhost.c |   1 +
 drivers/vhost/vhost.c     |  52 +++-------------------
 drivers/vhost/vhost.h     |  11 ++---
 include/linux/skbuff.h    |   5 ++-
 net/core/skbuff.c         |  24 +++++++++-
 7 files changed, 144 insertions(+), 61 deletions(-)

-- 
MST
