From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V2 PATCH 0/5] Multiqueue support in
	tun/tap
Date: Sat, 17 Sep 2011 14:02:04 +0800
Message-ID: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	mirq-linux@rere.qmqm.pl, joe@perches.com, shemminger@vyatta.com
To: krkumar2@in.ibm.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
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

Hello all:

This series brings the V2 of multiqueue tun/tap (V1 in
http://www.mail-archive.com/kvm@vger.kernel.org/msg59479.html), an
approach to let tun/tap can benefit from the multicore/multiqueue
environment by spreading the network loads into differnet
sockets/queues.

Some quick overview of the design:

- Allowing multiple sockets to be attached to a tun/tap devices.
- Use RCU to synchronize the data path and system call
- A simple hash based queue selecting algorithm is used to choose the
tx queue.
- Two new ioctls were added for the usespace to attach and detach
socket to the device.
- ABI compatibility were maintained, and multiqueue is only enabled
for tap as kvm is the only user as far as I can see. But it maybe used
by tun also.

In order to use the multiqueue virio-net in guest, changes of qemu and
guest driver are also needed. Please refer
http://www.spinics.net/lists/kvm/msg52808.html for guest drivers
http://www.spinics.net/lists/kvm/msg52808.html and qemu changes.
I would also post the a new version of qemu changes soon.

A wiki-page was created to narrate the detail design of all parts
involved in the multi queue implementation:
http://www.linux-kvm.org/page/Multiqueue and some basic tests result
could be seen in this page
http://www.linux-kvm.org/page/Multiqueue-performance-Sep-13. I would
post the detail numbers in attachment as the reply of this thread.

Changes from V1:

1 Simplify the sockets array management by not leaving NULL in the
slot.
2 Optimization on the tx queue selecting.
3 Fix the bug in tun_deatch_all()

Some notes on the test result:

The results shows a very well scale for guest receiving and large
packets sending, but met some regressions at specific conditions:

1 Current implementation suffers from the regression of multiple
sessions of small packet transmission from guest, this regression
becomes severs when test it between localhost and guest.

>From the test result, we can see more pio exit were measured, the
reason is the small number of co-current sessions may not even
overload a single queue and may brings extra overhead when using
multiple queues. When we are trying to use multiple connections to
transmit small packets through single queue, the queue is almost full
and vhost thread is busy with tx. So guest have more chances to met a
notification disabled tx queue when it want to transmit packets (high
number of tx packets per pio exit). But when we transmit packets
through multiple queue, each queue is not fully utilized and so guest
have less chance to see a notification disabled queue when
transmitting packets, so more pio_exits and more vhost thread
wakup/sleep were found.

As Michael point out, other feature such as PLE may also have help in
the performance, when we are using single queue, multiple guest vcpus
may contend on the tx lock which may be captured by PLE and save the
cpu utilization. But multiple queue can not benefit from it as it
could get lees lock contention.

The solution for this still needs to be investigated, any suggestions
are welcomed.

2 Current implementation may also get regression for single session
packet transmission.

The reason is packets from each flow were not handled by the same
queue/vhost thread.

Various method could be done to handle this:

2.1 hack the guest driver, and store the queue index into the rxhash and
use it when choosing tx in guest. This need some hack to store the
rxhash into sk and pass it in to skb again in
skb_orphan_try(). sk_rxhash is only used by RPS now, so some more
clean method is needed.

2.2 hack the tun/tap, add a hash to queue table, and use the hash of the
skb to store the queue index. This method would introduce more
overhead and the rxhash would be calculated during each skb reception
or transmission.

I've tried both 1 and 2, both of them could solve the problem, but
both of it may introduces regression for multiple sessions. More
reasonable method is needed.

Please comment, thanks. Any suggestions are welcomed.

---

Jason Wang (5):
      tuntap: move socket to tun_file
      tuntap: categorize ioctl
      tuntap: introduce multiqueue flags
      tuntap: multiqueue support
      tuntap: add ioctls to attach or detach a file form tap device


 drivers/net/tun.c      |  718 ++++++++++++++++++++++++++++--------------------
 include/linux/if_tun.h |    5 
 2 files changed, 430 insertions(+), 293 deletions(-)

-- 
Jason Wang
