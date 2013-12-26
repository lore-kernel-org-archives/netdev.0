From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: auto-tune mergeable rx buffer size
	for improved performance
Date: Thu, 26 Dec 2013 15:33:01 +0800
Message-ID: <52BBDBAD.8030609@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-3-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1387239389-13216-3-git-send-email-mwdalton@google.com>
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

On 12/17/2013 08:16 AM, Michael Dalton wrote:
> Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page frag
> allocators") changed the mergeable receive buffer size from PAGE_SIZE to
> MTU-size, introducing a single-stream regression for benchmarks with large
> average packet size. There is no single optimal buffer size for all
> workloads.  For workloads with packet size <= MTU bytes, MTU + virtio-net
> header-sized buffers are preferred as larger buffers reduce the TCP window
> due to SKB truesize. However, single-stream workloads with large average
> packet sizes have higher throughput if larger (e.g., PAGE_SIZE) buffers
> are used.
>
> This commit auto-tunes the mergeable receiver buffer packet size by
> choosing the packet buffer size based on an EWMA of the recent packet
> sizes for the receive queue. Packet buffer sizes range from MTU_SIZE +
> virtio-net header len to PAGE_SIZE. This improves throughput for
> large packet workloads, as any workload with average packet size >=
> PAGE_SIZE will use PAGE_SIZE buffers.
>
> These optimizations interact positively with recent commit
> ba275241030c ("virtio-net: coalesce rx frags when possible during rx"),
> which coalesces adjacent RX SKB fragments in virtio_net. The coalescing
> optimizations benefit buffers of any size.
>
> Benchmarks taken from an average of 5 netperf 30-second TCP_STREAM runs
> between two QEMU VMs on a single physical machine. Each VM has two VCPUs
> with all offloads & vhost enabled. All VMs and vhost threads run in a
> single 4 CPU cgroup cpuset, using cgroups to ensure that other processes
> in the system will not be scheduled on the benchmark CPUs. Trunk includes
> SKB rx frag coalescing.
>
> net-next w/ virtio_net before 2613af0ed18a (PAGE_SIZE bufs): 14642.85Gb/s
> net-next (MTU-size bufs):  13170.01Gb/s
> net-next + auto-tune: 14555.94Gb/s
>
> Signed-off-by: Michael Dalton <mwdalton@google.com>

The patch looks good to me and test this patch with mlx4, it help to
increase the rx performance from about 22Gb/s to about 26 Gb/s.
