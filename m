From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [rfc net-next v6 0/3] Multiqueue virtio-net
Date: Tue, 30 Oct 2012 12:05:24 -0700
Message-ID: <509024F4.8080408@hp.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
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

On 10/30/2012 03:03 AM, Jason Wang wrote:
> Hi all:
>
> This series is an update version of multiqueue virtio-net driver based on
> Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
> packets reception and transmission. Please review and comments.
>
> Changes from v5:
> - Align the implementation with the RFC spec update v4
> - Switch the mode between single mode and multiqueue mode without reset
> - Remove the 256 limitation of queues
> - Use helpers to do the mapping between virtqueues and tx/rx queues
> - Use commbined channels instead of separated rx/tx queus when do the queue
> number configuartion
> - Other coding style comments from Michael
>
> Reference:
> - A protype implementation of qemu-kvm support could by found in
> git://github.com/jasowang/qemu-kvm-mq.git
> - V5 could be found at http://lwn.net/Articles/505388/
> - V4 could be found at https://lkml.org/lkml/2012/6/25/120
> - V2 could be found at http://lwn.net/Articles/467283/
> - Michael virtio-spec: http://www.spinics.net/lists/netdev/msg209986.html
>
> Perf Numbers:
>
> - Pktgen test shows the receiving capability of the multiqueue virtio-net were
>    dramatically improved.
> - Netperf result shows latency were greately improved according to the test
> result.

I suppose it is technically correct to say that latency was improved, 
but usually for aggregate request/response tests I tend to talk about 
the aggregate transactions per second.

Do you have a hypothesis as to why the improvement dropped going to 20 
concurrent sessions from 10?

rick jones

> Netperf Local VM to VM test:
> - VM1 and its vcpu/vhost thread in numa node 0
> - VM2 and its vcpu/vhost thread in numa node 1
> - a script is used to lauch the netperf with demo mode and do the postprocessing
>    to measure the aggreagte result with the help of timestamp
> - average of 3 runs
>
> TCP_RR:
> size/session/+lat%/+normalize%
>      1/     1/    0%/    0%
>      1/    10/  +52%/   +6%
>      1/    20/  +27%/   +5%
>     64/     1/    0%/    0%
>     64/    10/  +45%/   +4%
>     64/    20/  +28%/   +7%
>    256/     1/   -1%/    0%
>    256/    10/  +38%/   +2%
>    256/    20/  +27%/   +6%
> TCP_CRR:
> size/session/+lat%/+normalize%
>      1/     1/   -7%/  -12%
>      1/    10/  +34%/   +3%
>      1/    20/   +3%/   -8%
>     64/     1/   -7%/   -3%
>     64/    10/  +32%/   +1%
>     64/    20/   +4%/   -7%
>    256/     1/   -6%/  -18%
>    256/    10/  +33%/    0%
>    256/    20/   +4%/   -8%
> STREAM:
> size/session/+thu%/+normalize%
>      1/     1/   -3%/    0%
>      1/     2/   -1%/    0%
>      1/     4/   -2%/    0%
>     64/     1/    0%/   +1%
>     64/     2/   -6%/   -6%
>     64/     4/   -8%/  -14%
>    256/     1/    0%/    0%
>    256/     2/  -48%/  -52%
>    256/     4/  -50%/  -55%
>    512/     1/   +4%/   +5%
>    512/     2/  -29%/  -33%
>    512/     4/  -37%/  -49%
>   1024/     1/   +6%/   +7%
>   1024/     2/  -46%/  -51%
>   1024/     4/  -15%/  -17%
>   4096/     1/   +1%/   +1%
>   4096/     2/  +16%/   -2%
>   4096/     4/  +31%/  -10%
> 16384/     1/    0%/    0%
> 16384/     2/  +16%/   +9%
> 16384/     4/  +17%/   -9%
>
> Netperf test between external host and guest over 10gb(ixgbe):
> - VM thread and vhost threads were pinned int the node 0
> - a script is used to lauch the netperf with demo mode and do the postprocessing
>    to measure the aggreagte result with the help of timestamp
> - average of 3 runs
>
> TCP_RR:
> size/session/+lat%/+normalize%
>      1/     1/    0%/   +6%
>      1/    10/  +41%/   +2%
>      1/    20/  +10%/   -3%
>     64/     1/    0%/  -10%
>     64/    10/  +39%/   +1%
>     64/    20/  +22%/   +2%
>    256/     1/    0%/   +2%
>    256/    10/  +26%/  -17%
>    256/    20/  +24%/  +10%
> TCP_CRR:
> size/session/+lat%/+normalize%
>      1/     1/   -3%/   -3%
>      1/    10/  +34%/   -3%
>      1/    20/    0%/  -15%
>     64/     1/   -3%/   -3%
>     64/    10/  +34%/   -3%
>     64/    20/   -1%/  -16%
>    256/     1/   -1%/   -3%
>    256/    10/  +38%/   -2%
>    256/    20/   -2%/  -17%
> TCP_STREAM:(guest receiving)
> size/session/+thu%/+normalize%
>      1/     1/   +1%/  +14%
>      1/     2/    0%/   +4%
>      1/     4/   -2%/  -24%
>     64/     1/   -6%/   +1%
>     64/     2/   +1%/   +1%
>     64/     4/   -1%/  -11%
>    256/     1/   +3%/   +4%
>    256/     2/    0%/   -1%
>    256/     4/    0%/  -15%
>    512/     1/   +4%/    0%
>    512/     2/  -10%/  -12%
>    512/     4/    0%/  -11%
>   1024/     1/   -5%/    0%
>   1024/     2/  -11%/  -16%
>   1024/     4/   +3%/  -11%
>   4096/     1/  +27%/   +6%
>   4096/     2/    0%/  -12%
>   4096/     4/    0%/  -20%
> 16384/     1/    0%/   -2%
> 16384/     2/    0%/   -9%
> 16384/     4/  +10%/   -2%
> TCP_MAERTS:(guest sending)
>      1/     1/   -1%/    0%
>      1/     2/    0%/    0%
>      1/     4/   -5%/    0%
>     64/     1/    0%/    0%
>     64/     2/   -7%/   -8%
>     64/     4/   -7%/   -8%
>    256/     1/    0%/    0%
>    256/     2/  -28%/  -28%
>    256/     4/  -28%/  -29%
>    512/     1/    0%/    0%
>    512/     2/  -15%/  -13%
>    512/     4/  -53%/  -59%
>   1024/     1/   +4%/  +13%
>   1024/     2/   -7%/  -18%
>   1024/     4/   +1%/  -18%
>   4096/     1/   +2%/    0%
>   4096/     2/   +3%/  -19%
>   4096/     4/   -1%/  -19%
> 16384/     1/   -3%/   -1%
> 16384/     2/    0%/  -12%
> 16384/     4/    0%/  -10%
>
> Jason Wang (2):
>    virtio_net: multiqueue support
>    virtio-net: change the number of queues through ethtool
>
> Krishna Kumar (1):
>    virtio_net: Introduce VIRTIO_NET_F_MULTIQUEUE
>
>   drivers/net/virtio_net.c        |  790 ++++++++++++++++++++++++++++-----------
>   include/uapi/linux/virtio_net.h |   19 +
>   2 files changed, 594 insertions(+), 215 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
