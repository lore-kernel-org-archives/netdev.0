From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 0/4] macvtap: locking and offload control
Date: Tue, 25 Jun 2013 16:04:18 -0400
Message-ID: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619Ab3FYUEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 16:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches changes the macvtap locking to use rtnl instead
of a private lock and adds the ability for user to specify TAP offload
features.

The macvtap_lock protects the relationship between macvlan_dev and
macvtap_queue structures.  This relationship is modified in 3 places:
open(), release(), and dellinks().  dellinks() is already protected
by rtnl through the rtnetlink message handling.  If we add rtnl protection
during the open() and relase() calls, we can remove the private lock.

We can also stop using the _bh veriants of rcu since in most cases
either regular rcu is already taken or we don't need to disable bh.

Macvtap does not allow tap user to control of offload functionality via
TUNSETOFFLOAD ioctl.  This is the ioctl that qemu uses when
attempting to enable or disable offload features that it expects on the
tap socket.  The 3rd patch adds this support, but there is a small
wrinkle.  Typcally, tap offloads are reversed.  When the user disables
TSO to the tap, it does not expect to receive TSO packets.  To do this
here, we reverse the sence such that when TSO is disabled, we actuall
disalbe GRO on the macvtap interface, but also save the user expected
offloads so that we can properly perform segmentation when passing
data to the user (patch 4).

Changes since v1:
 - use rtnl locks.
 - reverse the sence of offload features to make them more consitent
   with user of tap.

Vlad Yasevich (4):
  macvtap: Convert to using rtnl lock
  macvtap: Consistently use rcu functions
  macvtap: Let TUNSETOFFLOAD actually controll offload features.
  macvtap: Perform GSO on forwarding path.

 drivers/net/macvlan.c      |  10 +++
 drivers/net/macvtap.c      | 176 ++++++++++++++++++++++++++++++++-------------
 include/linux/if_macvlan.h |   2 +
 3 files changed, 140 insertions(+), 48 deletions(-)

-- 
1.8.1.4
