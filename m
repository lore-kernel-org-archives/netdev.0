From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [Qemu-devel] [RFC PATCH 0/2] Multiqueue support for qemu(virtio-net)
Date: Fri, 29 Apr 2011 15:10:13 -0500
Message-ID: <4DBB1B25.1020300@codemonkey.ws>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>	<OF7CC46028.9A206852-ON65257878.00307271-65257878.00308D38@in.ibm.com> <19887.42381.34145.956833@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	qemu-devel@nongnu.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44599 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab1D2UKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 16:10:17 -0400
In-Reply-To: <19887.42381.34145.956833@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2011 10:33 PM, Jason Wang wrote:
> Krishna Kumar2 writes:
>   >  Thanks Jason!
>   >
>   >  So I can use my virtio-net guest driver and test with this patch?
>   >  Please provide the script you use to start MQ guest.
>   >
>
> Yes and thanks. Following is a simple script may help you start macvtap mq
> guest.
>
> qemu_path=./qemu-system-x86_64
> img_path=/home/kvm_autotest_root/images/mq.qcow2
> vtap_dev=/dev/tap104
> mac=96:88:12:1C:27:83
> smp=2
> mq=4
>
> for i in `seq $mq`
> do
>      vtap+=" -netdev tap,id=hn$i,fd=$((i+100)) $((i+100))<>$vtap_dev"

So you are basically dup()'ing the tap device.

Does this actually improve performance at all?

Regards,

Anthony Liguori

>      netdev+="hn$i#"
> done
>
> eval "$qemu_path $img_path $vtap -device virtio-net-pci,queues=$mq,netdev=$netdev,mac=$mac,vectors=32 -enable-kvm -smp $smp"
>
>
>   >  Regards,
>   >
>   >  - KK
>   >
>   >  Jason Wang<jasowang@redhat.com>  wrote on 04/20/2011 02:03:07 PM:
>   >
>   >  >  Jason Wang<jasowang@redhat.com>
>   >  >  04/20/2011 02:03 PM
>   >  >
>   >  >  To
>   >  >
>   >  >  Krishna Kumar2/India/IBM@IBMIN, kvm@vger.kernel.org, mst@redhat.com,
>   >  >  netdev@vger.kernel.org, rusty@rustcorp.com.au, qemu-
>   >  >  devel@nongnu.org, anthony@codemonkey.ws
>   >  >
>   >  >  cc
>   >  >
>   >  >  Subject
>   >  >
>   >  >  [RFC PATCH 0/2] Multiqueue support for qemu(virtio-net)
>   >  >
>   >  >  Inspired by Krishna's patch
>   >  (http://www.spinics.net/lists/kvm/msg52098.html
>   >  >  ) and
>   >  >  Michael's suggestions.  The following series adds the multiqueue support
>   >  for
>   >  >  qemu and enable it for virtio-net (both userspace and vhost).
>   >  >
>   >  >  The aim for this series is to simplified the management and achieve the
>   >  same
>   >  >  performacne with less codes.
>   >  >
>   >  >  Follows are the differences between this series and Krishna's:
>   >  >
>   >  >  - Add the multiqueue support for qemu and also for userspace virtio-net
>   >  >  - Instead of hacking the vhost module to manipulate kthreads, this patch
>   >  just
>   >  >  implement the userspace based multiqueues and thus can re-use the
>   >  >  existed vhost kernel-side codes without any modification.
>   >  >  - Use 1:1 mapping between TX/RX pairs and vhost kthread because the
>   >  >  implementation is based on usersapce.
>   >  >  - The cli is also changed to make the mgmt easier, the -netdev option of
>   >  qdev
>   >  >  can now accpet more than one ids. You can start a multiqueue virtio-net
>   >  device
>   >  >  through:
>   >  >  ./qemu-system-x86_64 -netdev tap,id=hn0,vhost=on,fd=X -netdev
>   >  >  tap,id=hn0,vhost=on,fd=Y -device
>   >  virtio-net-pci,netdev=hn0#hn1,queues=2 ...
>   >  >
>   >  >  The series is very primitive and still need polished.
>   >  >
>   >  >  Suggestions are welcomed.
>   >  >  ---
>   >  >
>   >  >  Jason Wang (2):
>   >  >        net: Add multiqueue support
>   >  >        virtio-net: add multiqueue support
>   >  >
>   >  >
>   >  >   hw/qdev-properties.c |   37 ++++-
>   >  >   hw/qdev.h            |    3
>   >  >   hw/vhost.c           |   26 ++-
>   >  >   hw/vhost.h           |    1
>   >  >   hw/vhost_net.c       |    7 +
>   >  >   hw/vhost_net.h       |    2
>   >  >   hw/virtio-net.c      |  409 +++++++++++++++++++++++++++++++
>   >  >  +------------------
>   >  >   hw/virtio-net.h      |    2
>   >  >   hw/virtio-pci.c      |    1
>   >  >   hw/virtio.h          |    1
>   >  >   net.c                |   34 +++-
>   >  >   net.h                |   15 +-
>   >  >   12 files changed, 353 insertions(+), 185 deletions(-)
>   >  >
>   >  >  --
>   >  >  Jason Wang
>   >
>

