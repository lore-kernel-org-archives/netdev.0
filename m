From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Thu, 02 Feb 2017 19:14:05 -0800
Message-ID: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35766 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdBCDO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:14:26 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so700548pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 19:14:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds adjust head support for virtio. The following is my
test setup. I use qemu + virtio as follows,

./x86_64-softmmu/qemu-system-x86_64 \
  -hda /var/lib/libvirt/images/Fedora-test0.img \
  -m 4096  -enable-kvm -smp 2 -netdev tap,id=hn0,queues=4,vhost=on \
  -device virtio-net-pci,netdev=hn0,mq=on,guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off,vectors=9

In order to use XDP with virtio until LRO is supported TSO must be
turned off in the host. The important fields in the above command line
are the following,

  guest_tso4=off,guest_tso6=off,guest_ecn=off,guest_ufo=off

Also note it is possible to conusme more queues than can be supported
because when XDP is enabled for retransmit XDP attempts to use a queue
per cpu. My standard queue count is 'queues=4'.

After loading the VM I run the relevant XDP test programs in,

  ./sammples/bpf

For this series I tested xdp1, xdp2, and xdp_tx_iptunnel. I usually test
with iperf (-d option to get bidirectional traffic), ping, and pktgen.
I also have a modified xdp1 that returns XDP_PASS on any packet to ensure
the normal traffic path to the stack continues to work with XDP loaded.

It would be great to automate this soon. At the moment I do it by hand
which is starting to get tedious.

v2: original series dropped trace points after merge.

---

John Fastabend (5):
      virtio_net: wrap rtnl_lock in test for calling with lock already held
      virtio_net: factor out xdp handler for readability
      virtio_net: remove duplicate queue pair binding in XDP
      virtio_net: refactor freeze/restore logic into virtnet reset logic
      virtio_net: XDP support for adjust_head


 drivers/net/virtio_net.c |  338 ++++++++++++++++++++++++++++++----------------
 drivers/virtio/virtio.c  |   42 +++---
 include/linux/virtio.h   |    4 +
 3 files changed, 247 insertions(+), 137 deletions(-)
