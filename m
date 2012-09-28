From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/3] virtio-net: inline header support
Date: Fri, 28 Sep 2012 11:26:00 +0200
Message-ID: <cover.1348824232.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Thinking about Sasha's patches, we can reduce ring usage
for virtio net small packets dramatically if we put
virtio net header inline with the data.
This can be done for free in case guest net stack allocated
extra head room for the packet, and I don't see
why would this have any downsides.

Even though with my recent patches qemu
no longer requires header to be the first s/g element,
we need a new feature bit to detect this.
A trivial qemu patch will be sent separately.

We could get rid of an extra s/g for big packets too,
but since in practice everyone enables mergeable buffers,
I don't see much of a point.

Rusty, if you decide to pick this up I'll send a
(rather trivial) spec patch shortly afterwards, but holidays
are beginning here. Considering how simple
the guest patch is, I hope it can make it in 3.7?

Also note that patch 1 and 2 are IMO a good
idea without patch 3. If you decide to defer patch 3
pls consider 1/2 separately.

Before:
[root@virtlab203 qemu]# ssh robin ./netperf/bin/netperf -t TCP_RR -H
11.0.0.4
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
11.0.0.4 (11.0.0.4) port 0 AF_INET : demo
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1        1       10.00    2992.88   
16384  87380 

After:
[root@virtlab203 qemu]# ssh robin ./netperf/bin/netperf -t TCP_RR -H
11.0.0.4
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
11.0.0.4 (11.0.0.4) port 0 AF_INET : demo
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

16384  87380  1        1       10.00    3195.57   
16384  87380 

Michael S. Tsirkin (3):
  virtio: add API to query ring capacity
  virtio-net: correct capacity math on ring full
  virtio-net: put virtio net header inline with data

 drivers/net/virtio_net.c     | 57 +++++++++++++++++++++++++++++++-------------
 drivers/virtio/virtio_ring.c | 19 +++++++++++++++
 include/linux/virtio.h       |  2 ++
 include/linux/virtio_net.h   |  5 +++-
 4 files changed, 66 insertions(+), 17 deletions(-)

-- 
MST
