From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/5] tun/macvtap: TUNSETIFF fixes
Date: Tue, 16 Dec 2014 15:04:53 +0200
Message-ID: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jason Wang <jasowang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Carpenter reported the following:
	static checker warning:

		drivers/net/tun.c:1694 tun_set_iff()
		warn: 0x17100 is larger than 16 bits

	drivers/net/tun.c
	  1692
	  1693          tun->flags = (tun->flags & ~TUN_FEATURES) |
	  1694                  (ifr->ifr_flags & TUN_FEATURES);
	  1695

	It's complaining because the "ifr->ifr_flags" variable is a short
	(should it be unsigned?).  The new define:

	#define IFF_VNET_LE    0x10000

	doesn't fit in two bytes.  Other suspect looking code could be:

		return __virtio16_to_cpu(q->flags & IFF_VNET_LE, val);

And that's true: we have run out of IFF flags in tun.

So let's not try to add more: add simple GET/SET ioctls
instead. Easy to test, leads to clear semantics.

Alternatively we'll have to revert the whole thing for 3.19,
but that seems more work as this has dependencies
in other places.

While here, I noticed that macvtap was actually reading
ifreq flags as a 32 bit field.
Fix that up as well.

Michael S. Tsirkin (5):
  macvtap: fix uninitialized access on TUNSETIFF
  if_tun: add TUNSETVNETLE/TUNGETVNETLE
  tun: drop broken IFF_VNET_LE
  macvtap: drop broken IFF_VNET_LE
  if_tun: drop broken IFF_VNET_LE

 include/uapi/linux/if_tun.h |  3 ++-
 drivers/net/macvtap.c       | 30 ++++++++++++++++++++++++------
 drivers/net/tun.c           | 26 +++++++++++++++++++++++---
 3 files changed, 49 insertions(+), 10 deletions(-)

-- 
MST
