From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v6 0/6] virtio-net: mergeable rx buffer size
	auto-tuning
Date: Thu, 16 Jan 2014 22:23:24 -0800
Message-ID: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

The virtio-net device currently uses aligned MTU-sized mergeable receive
packet buffers. Network throughput for workloads with large average
packet size can be improved by posting larger receive packet buffers.
However, due to SKB truesize effects, posting large (e.g, PAGE_SIZE)
buffers reduces the throughput of workloads that do not benefit from GRO
and have no large inbound packets.

This patchset introduces virtio-net mergeable buffer size auto-tuning,
with buffer sizes ranging from aligned MTU-size to PAGE_SIZE. Packet
buffer size is chosen based on a per-receive queue EWMA of incoming
packet size.

To unify mergeable receive buffer memory allocation and improve
SKB frag coalescing, all mergeable buffer memory allocation is
migrated to per-receive queue page frag allocators.

The per-receive queue mergeable packet buffer size is exported via
sysfs, and the network device sysfs layer has been extended to add
support for device-specific per-receive queue sysfs attribute groups.

Michael Dalton (6):
  net: allow > 0 order atomic page alloc in skb_page_frag_refill
  virtio-net: use per-receive queue page frag alloc for mergeable bufs
  virtio-net: auto-tune mergeable rx buffer size for improved
    performance
  net-sysfs: add support for device-specific rx queue sysfs attributes
  lib: Ensure EWMA does not store wrong intermediate values
  virtio-net: initial rx sysfs support, export mergeable rx buffer size

 drivers/net/virtio_net.c  | 197 +++++++++++++++++++++++++++++++++-------------
 include/linux/netdevice.h |  35 +++++++-
 lib/average.c             |   6 +-
 net/core/dev.c            |  12 +--
 net/core/net-sysfs.c      |  50 +++++++-----
 net/core/sock.c           |   4 +-
 6 files changed, 214 insertions(+), 90 deletions(-)

-- 
1.8.5.2
