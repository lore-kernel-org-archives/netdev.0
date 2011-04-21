From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 0/2] Multiqueue support for
	qemu(virtio-net)
Date: Thu, 21 Apr 2011 11:33:33 +0800
Message-ID: <19887.42381.34145.956833@gargle.gargle.HOWL>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<OF7CC46028.9A206852-ON65257878.00307271-65257878.00308D38@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>, rusty@rustcorp.com.au,
	qemu-devel@nongnu.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <OF7CC46028.9A206852-ON65257878.00307271-65257878.00308D38@in.ibm.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 writes:
 > Thanks Jason!
 > 
 > So I can use my virtio-net guest driver and test with this patch?
 > Please provide the script you use to start MQ guest.
 > 

Yes and thanks. Following is a simple script may help you start macvtap mq
guest.

qemu_path=./qemu-system-x86_64
img_path=/home/kvm_autotest_root/images/mq.qcow2
vtap_dev=/dev/tap104
mac=96:88:12:1C:27:83
smp=2
mq=4

for i in `seq $mq`
do
    vtap+=" -netdev tap,id=hn$i,fd=$((i+100)) $((i+100))<>$vtap_dev"
    netdev+="hn$i#"
done

eval "$qemu_path $img_path $vtap -device virtio-net-pci,queues=$mq,netdev=$netdev,mac=$mac,vectors=32 -enable-kvm -smp $smp"


 > Regards,
 > 
 > - KK
 > 
 > Jason Wang <jasowang@redhat.com> wrote on 04/20/2011 02:03:07 PM:
 > 
 > > Jason Wang <jasowang@redhat.com>
 > > 04/20/2011 02:03 PM
 > >
 > > To
 > >
 > > Krishna Kumar2/India/IBM@IBMIN, kvm@vger.kernel.org, mst@redhat.com,
 > > netdev@vger.kernel.org, rusty@rustcorp.com.au, qemu-
 > > devel@nongnu.org, anthony@codemonkey.ws
 > >
 > > cc
 > >
 > > Subject
 > >
 > > [RFC PATCH 0/2] Multiqueue support for qemu(virtio-net)
 > >
 > > Inspired by Krishna's patch
 > (http://www.spinics.net/lists/kvm/msg52098.html
 > > ) and
 > > Michael's suggestions.  The following series adds the multiqueue support
 > for
 > > qemu and enable it for virtio-net (both userspace and vhost).
 > >
 > > The aim for this series is to simplified the management and achieve the
 > same
 > > performacne with less codes.
 > >
 > > Follows are the differences between this series and Krishna's:
 > >
 > > - Add the multiqueue support for qemu and also for userspace virtio-net
 > > - Instead of hacking the vhost module to manipulate kthreads, this patch
 > just
 > > implement the userspace based multiqueues and thus can re-use the
 > > existed vhost kernel-side codes without any modification.
 > > - Use 1:1 mapping between TX/RX pairs and vhost kthread because the
 > > implementation is based on usersapce.
 > > - The cli is also changed to make the mgmt easier, the -netdev option of
 > qdev
 > > can now accpet more than one ids. You can start a multiqueue virtio-net
 > device
 > > through:
 > > ./qemu-system-x86_64 -netdev tap,id=hn0,vhost=on,fd=X -netdev
 > > tap,id=hn0,vhost=on,fd=Y -device
 > virtio-net-pci,netdev=hn0#hn1,queues=2 ...
 > >
 > > The series is very primitive and still need polished.
 > >
 > > Suggestions are welcomed.
 > > ---
 > >
 > > Jason Wang (2):
 > >       net: Add multiqueue support
 > >       virtio-net: add multiqueue support
 > >
 > >
 > >  hw/qdev-properties.c |   37 ++++-
 > >  hw/qdev.h            |    3
 > >  hw/vhost.c           |   26 ++-
 > >  hw/vhost.h           |    1
 > >  hw/vhost_net.c       |    7 +
 > >  hw/vhost_net.h       |    2
 > >  hw/virtio-net.c      |  409 +++++++++++++++++++++++++++++++
 > > +------------------
 > >  hw/virtio-net.h      |    2
 > >  hw/virtio-pci.c      |    1
 > >  hw/virtio.h          |    1
 > >  net.c                |   34 +++-
 > >  net.h                |   15 +-
 > >  12 files changed, 353 insertions(+), 185 deletions(-)
 > >
 > > --
 > > Jason Wang
 > 
