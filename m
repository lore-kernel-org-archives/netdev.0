From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH v2 net-net 0/3] Increase the limit of tuntap queues
Date: Mon, 24 Nov 2014 13:42:11 -0500 (EST)
Message-ID: <431146931.3324107.1416854531319.JavaMail.zimbra@redhat.com>
References: <1416854006-10041-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416854006-10041-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry! forgot to add Michael, adding now.

> Networking under KVM works best if we allocate a per-vCPU rx and tx
> queue in a virtual NIC. This requires a per-vCPU queue on the host side.
> Modern physical NICs have multiqueue support for large number of queues.
> To scale vNIC to run multiple queues parallel to maximum number of vCPU's
> we need to increase number of queues support in tuntap.
> 
> Changes from v1
> PATCH 2: David Miller     - sysctl changes to limit number of queues
>                             not required for unprivileged users(dropped).
> 
> Changes from RFC
> PATCH 1: Sergei Shtylyov  - Add an empty line after declarations.
> PATCH 2: Jiri Pirko -       Do not introduce new module paramaters.
> 	 Michael.S.Tsirkin- We can use sysctl for limiting max number
>                             of queues.
> 
> This series is to increase the limit of tuntap queues. Original work is being
> done by 'jasowang@redhat.com'. I am taking this
> 'https://lkml.org/lkml/2013/6/19/29'
> patch series as a reference. As per discussion in the patch series:
> 
> There were two reasons which prevented us from increasing number of tun
> queues:
> 
> - The netdev_queue array in netdevice were allocated through kmalloc, which
> may
>   cause a high order memory allocation too when we have several queues.
>   E.g. sizeof(netdev_queue) is 320, which means a high order allocation would
>   happens when the device has more than 16 queues.
> 
> - We store the hash buckets in tun_struct which results a very large size of
>   tun_struct, this high order memory allocation fail easily when the memory
>   is
>   fragmented.
> 
> The patch 60877a32bce00041528576e6b8df5abe9251fa73 increases the number of tx
> queues. Memory allocation fallback to vzalloc() when kmalloc() fails.
> 
> This series tries to address following issues:
> 
> - Increase the number of netdev_queue queues for rx similarly its done for tx
>   queues by falling back to vzalloc() when memory allocation with kmalloc()
>   fails.
> 
> - Switches to use flex array to implement the flow caches to avoid higher
> order
>   allocations.
> 
> - Increase number of queues to 256, maximum number is equal to maximum number
>   of vCPUS allowed in a guest.
> 
> I have done some testing to test any regression with sample program which
> creates
> tun/tap for single queue / multiqueue device. I have also done testing with
> multiple
> parallel Netperf sessions from guest to host for different combination of
> queues
> and CPU's. It seems to be working fine without much increase in cpu load with
> the
> increase in number of queues.
> 
> For this test vhost threads are pinned to separate CPU's. Below are the
> results:
> Host kernel: 3.18.rc4, Intel(R) Core(TM) i7-3520M CPU @ 2.90GHz, 4 CPUS
> NIC : Ethernet controller: Intel Corporation 82579LM Gigabit Network
> 
> 1] Before patch applied limit: Single Queue
> Guest, smp=2,
> 19:57:44     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal
> %guest  %gnice   %idle
> 19:57:44     all    2.90    0.00    3.68    0.98    0.13    0.61    0.00
> 4.64    0.00   87.06
> 
> 2] Patch applied, Tested with 2 queues, with vhost threads pinned to
> different physical cpus
> Guest, smp=2, queues =2
> 23:21:59     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal
> %guest  %gnice   %idle
> 23:21:59     all    1.80    0.00    1.57    1.49    0.18    0.23    0.00
> 1.41    0.00   93.32
> 
> 3] Tested with 4 queues, with vhost threads pinned to different physical cpus
> -------------------------------------------------------------------------------
> Guest, smp=4, queues =4
> 23:09:43     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal
> %guest  %gnice   %idle
> 23:09:43     all    1.89    0.00    1.63    1.35    0.19    0.23    0.00
> 1.33    0.00   93.37
> 
> Patches Summary:
>   net: allow large number of rx queues
>   tuntap: Reduce the size of tun_struct by using flex array
>   tuntap: Increase the number of queues in tun
> 
>  drivers/net/tun.c |   58
>  +++++++++++++++++++++++++++++++++++++++---------------
>  net/core/dev.c    |   19 ++++++++++++-----
>  2 files changed, 55 insertions(+), 22 deletions(-)
> 
