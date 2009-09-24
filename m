From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PULL] virtio_net updates
Date: Thu, 24 Sep 2009 10:05:58 +0930
Message-ID: <200909241005.59416.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Mark McLoughlin <markmc@redhat.com>,
	Dinesh Subhraveti <dineshs@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36997 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157AbZIXAf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 20:35:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

   Now Linus has the prereq add_buf changes, these can all feed via you.  Note
that the driver is changed to return TX_BUSY first which is simplest, then
complicated again to avoid it.

These have been in linux-next since last merge window, too.

Thanks!
Rusty.


The following changes since commit a724eada8c2a7b62463b73ccf73fd0bb6e928aeb:
  Linus Torvalds (1):
        Merge branch 'ixp4xx' of git://git.kernel.org/.../chris/linux-2.6

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6-for-davem.git master

Amit Shah (1):
      virtio_net: Check for room in the vq before adding buffer

Rusty Russell (5):
      virtio_net: skb_orphan() and nf_reset() in xmit path.
      virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
      virtio_net: don't free buffers in xmit ring
      virtio_net: formalize skb_vnet_hdr
      virtio_net: avoid (most) NETDEV_TX_BUSY by stopping queue early.

 drivers/net/virtio_net.c |  229 ++++++++++++++++++----------------------------
 1 files changed, 88 insertions(+), 141 deletions(-)

commit 2b5bbe3b8bee8b38bdc27dd9c0270829b6eb7eeb
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Sep 24 09:59:17 2009 -0600

    virtio_net: skb_orphan() and nf_reset() in xmit path.
    
    The complex transmit free logic was introduced to avoid hangs on
    removing the ip_conntrack module and also because drivers aren't
    generally supposed to keep stale skbs for unbounded times.
    
    After some debate, it was decided that while doing skb_orphan()
    generally is a rat's nest, we can do it in this driver.  Following
    patches take advantage of this.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

 drivers/net/virtio_net.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

commit 8958f574dbe7e41cc54df0df1accc861bb9f6be8
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Sep 24 09:59:18 2009 -0600

    virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
    
    This effectively reverts 99ffc696d10b28580fe93441d627cf290ac4484c
    "virtio: wean net driver off NETDEV_TX_BUSY".
    
    The complexity of queuing an skb (setting a tasklet to re-xmit) is
    questionable, especially once we get rid of the other reason for the
    tasklet in the next patch.
    
    If the skb won't fit in the tx queue, just return NETDEV_TX_BUSY.
    This is frowned upon, so a followup patch uses a more complex solution.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Herbert Xu <herbert@gondor.apana.org.au>

 drivers/net/virtio_net.c |   46 ++++++++++------------------------------------
 1 files changed, 10 insertions(+), 36 deletions(-)

commit b0c39dbdc204006ef3558a66716ff09797619778
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Sep 24 09:59:19 2009 -0600

    virtio_net: don't free buffers in xmit ring
    
    The virtio_net driver is complicated by the two methods of freeing old
    xmit buffers (in addition to freeing old ones at the start of the xmit
    path).
    
    The original code used a 1/10 second timer attached to xmit_free(),
    reset on every xmit.  Before we orphaned skbs on xmit, the
    transmitting userspace could block with a full socket until the timer
    fired, the skb destructor was called, and they were re-woken.
    
    So we added the VIRTIO_F_NOTIFY_ON_EMPTY feature: supporting devices
    send an interrupt (even if normally suppressed) on an empty xmit ring
    which makes us schedule xmit_tasklet().  This was a benchmark win.
    
    Unfortunately, VIRTIO_F_NOTIFY_ON_EMPTY makes quite a lot of work: a
    host which is faster than the guest will fire the interrupt every xmit
    packet (slowing the guest down further).  Attempting mitigation in the
    host adds overhead of userspace timers (possibly with the additional
    pain of signals), and risks increasing latency anyway if you get it
    wrong.
    
    In practice, this effect was masked by benchmarks which take advantage
    of GSO (with its inherent transmit batching), but it's still there.
    
    Now we orphan xmitted skbs, the pressure is off: remove both paths and
    no longer request VIRTIO_F_NOTIFY_ON_EMPTY.  Note that the current
    QEMU will notify us even if we don't negotiate this feature (legal,
    but suboptimal); a patch is outstanding to improve that.
    
    Move the skb_orphan/nf_reset to after we've done the send and notified
    the other end, for a slight optimization.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Mark McLoughlin <markmc@redhat.com>

 drivers/net/virtio_net.c |   64 +++------------------------------------------
 1 files changed, 5 insertions(+), 59 deletions(-)

commit b3f24698a7faa6e9d8a14124cfdc25353fc8ca19
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Sep 24 09:59:19 2009 -0600

    virtio_net: formalize skb_vnet_hdr
    
    We put the virtio_net_hdr into the skb's cb region; turn this into a
    union to clean up the code slightly and allow future expansion.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Mark McLoughlin <markmc@redhat.com>
    Cc: Dinesh Subhraveti <dineshs@us.ibm.com>

 drivers/net/virtio_net.c |   81 +++++++++++++++++++++++++---------------------
 1 files changed, 44 insertions(+), 37 deletions(-)

commit 48925e372f04f5e35fec6269127c62b2c71ab794
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Thu Sep 24 09:59:20 2009 -0600

    virtio_net: avoid (most) NETDEV_TX_BUSY by stopping queue early.
    
    Now we can tell the theoretical capacity remaining in the output
    queue, virtio_net can waste entries by stopping the queue early.
    
    It doesn't work in the case of indirect buffers and kmalloc failure,
    but that's rare (we could drop the packet in that case, but other
    drivers return TX_BUSY for similar reasons).
    
    For the record, I think this patch reflects poorly on the linux
    network API.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Dinesh Subhraveti <dineshs@us.ibm.com>

 drivers/net/virtio_net.c |   64 ++++++++++++++++++++++++++++-----------------
 1 files changed, 40 insertions(+), 24 deletions(-)

commit 0aea51c37fc5868cd723f670af9056c2ef694fee
Author: Amit Shah <amit.shah@redhat.com>
Date:   Wed Aug 26 14:58:28 2009 +0530

    virtio_net: Check for room in the vq before adding buffer
    
    Saves us one cycle of alloc-add-free if the queue was full.
    
    Signed-off-by: Amit Shah <amit.shah@redhat.com>
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (modified)

 drivers/net/virtio_net.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)
