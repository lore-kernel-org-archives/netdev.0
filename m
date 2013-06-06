From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 0/8] Multiqueue API for macvtap
Date: Thu,  6 Jun 2013 17:54:32 +0800
Message-ID: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series implements a fully tuntap compatiable API which could be used
by userspace to manage multiple macvtap queues. The main parts is to add
TUNSETQUEUE ioctl support for macvtap.

Patch 1 - 5 was some tuntap compatibility and misc cleanups.
Patch 6 removes the linear search in macvtap by reshuffling the macvtaps array
each time a queue is removed.
Patch 7 implement TUNSETQUEUE ioctl by introducing a list to track all queues
while use the array to just track all enabled queues.
Patch 8 reports IFF_MULTI_QUEUE to userspace to notify the userspace that the
multiqueue API is completed.

Flow caches implememtation were missed in this version, since I am doing
rework on the tuntap flow caches. Have some some stress test with both netperf
and pktgen.

Please review, thanks.

Changes from RFC V3:
- drop the TUNSETIFF checks
- disable taps first during macvtap_put_queue() to simplify codes
- typo fixes and better comments from Michael on numvtaps in macvtap_get_queue()
- BUG_ON() and unnecessary checks of numdisabled in macvtap_del_queues()
- drop numdisabled and introduce numqueues to track the number of queues
- better style in macvtap_ioctl_set_queue()
- rename tap_link to queue_list
- blank line fixes again :(

Changes from RFC V2:
- Don't place disabled taps in the array and use a linked like to track all taps
- Remove unnecessary best-effort barriers
- Add ACCESS_ONCE() for vlan->numvtaps to prevent compiler generate unexpected
codes
- Add a comment to explain that numvtaps is just a hint in macvtap_get_queue()
- blank line fixes

Changes from RFC V1:
- Drop the patch of "return -EBADFD when TUNGETIFF fails" to preserve backward
compatibility
- Add a small patch of optimizing macvtap_do_read() (see patch 1/8)
- Use different functions to do tap enabling and creating
- Use different functions to do tap disabling and closing
- Remove the emtpy line in patch 6/8
- Add a line in patch 3/8
- Add a comment to explain the checking when doing TUNSETIFF with
IFF_MULTI_QUEUE
- Add comments to explian the second swapping when moving taps between disabled
areas and enabled areas.
- Fix the commit log of patch 7/8 ( v1 says the linked list were used which is
wrong )
- Other minor bug fixes

Jason Wang (8):
  macvtap: fix a possible race between queue selection and changing
    queues
  macvtap: do not add self to waitqueue if doing a nonblock read
  macvlan: switch to use IS_ENABLED()
  macvtap: introduce macvtap_get_vlan()
  macvlan: change the max number of queues to 16
  macvtap: eliminate linear search
  macvtap: add TUNSETQUEUE ioctl
  macvtap: enable multiqueue flag

 drivers/net/macvtap.c      |  206 +++++++++++++++++++++++++++++++-------------
 include/linux/if_macvlan.h |    8 ++-
 2 files changed, 152 insertions(+), 62 deletions(-)
