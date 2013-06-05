From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V3 0/9] Multiqueue API for macvtap
Date: Wed,  5 Jun 2013 14:36:23 +0800
Message-ID: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab3FEGqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 02:46:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all:

This series implements a v3 of fully tuntap compatiable API which could be used
by userspace to manage multiple macvtap queues. The main parts is to add
TUNSETQUEUE ioctl support for macvtap.

Patch 1 - 5 was some tuntap compatibility and misc cleanups.
Patch 6 removes the linear search in macvtap by reshuffling the macvtaps array
each time a queue is removed. After this, we could store both enabled and
disabled queues in the same array without introducing extra data structure.
Patch 7 let TUNSETIFF can create multiqueue device, nothing but some check
were added.
Patch 8 implement TUNSETQUEUE ioctl
Patch 9 reports IFF_MULTI_QUEUE to userspace to notify the userspace that the
multiqueue API is completed.

Flow caches implememtation were missed in this version, since I am doing
rework on the tuntap flow caches. Have some some stress test with both netperf
and pktgen.

Please review, thanks.

Changes from V2:
- Don't place disabled taps in the array and use a linked like to track all taps
- Remove unnecessary best-effort barriers
- Add ACCESS_ONCE() for vlan->numvtaps to prevent compiler generate unexpected
  codes
- Add a comment to explain that numvtaps is just a hint in macvtap_get_queue()
- blank line fixes

Changes from V1:
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

Jason Wang (9):
  macvtap: fix a possible race between queue selection and changing
    queues
  macvtap: do not add self to waitqueue if doing a nonblock read
  macvlan: switch to use IS_ENABLED()
  macvtap: introduce macvtap_get_vlan()
  macvlan: change the max number of queues to 16
  macvtap: eliminate linear search
  macvtap: allow TUNSETIFF to create multiqueue device
  macvtap: add TUNSETQUEUE ioctl
  macvtap: enable multiqueue flag

 drivers/net/macvtap.c      |  261 ++++++++++++++++++++++++++++++++------------
 include/linux/if_macvlan.h |    8 +-
 2 files changed, 197 insertions(+), 72 deletions(-)
