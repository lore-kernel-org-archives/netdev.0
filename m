From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] virtio-net: Reporting traffic queue distribution
	statistics through ethtool
Date: Thu, 16 May 2013 22:47:35 +0100
Message-ID: <1368740855.2655.57.camel@bwh-desktop.uk.solarflarecom.com>
References: <1368735869-31076-1-git-send-email-sriram.narasimhan@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Sriram Narasimhan <sriram.narasimhan@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1368735869-31076-1-git-send-email-sriram.narasimhan@hp.com>
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

On Thu, 2013-05-16 at 13:24 -0700, Sriram Narasimhan wrote:
> This patch allows virtio-net driver to report traffic distribution
> to inbound/outbound queues through ethtool -S.  The per_cpu
> virtnet_stats is split into receive and transmit stats and are
> maintained on a per receive_queue and send_queue basis.
> virtnet_stats() is modified to aggregate interface level statistics
> from per-queue statistics.  Sample output below:
> 
> NIC statistics:
>      rxq0: rx_packets: 4357802
>      rxq0: rx_bytes: 292642052
>      txq0: tx_packets: 824540
>      txq0: tx_bytes: 55256404
>      rxq1: rx_packets: 0
>      rxq1: rx_bytes: 0
>      txq1: tx_packets: 1094268
>      txq1: tx_bytes: 73328316
>      rxq2: rx_packets: 0
>      rxq2: rx_bytes: 0
>      txq2: tx_packets: 1091466
>      txq2: tx_bytes: 73140566
>      rxq3: rx_packets: 0
>      rxq3: rx_bytes: 0
>      txq3: tx_packets: 1093043
>      txq3: tx_bytes: 73246142
> 
> Signed-off-by: Sriram Narasimhan <sriram.narasimhan@hp.com>
[...]

That ordering is totally unreadable.  I want to see patches for ethtool
to let the user order and aggregate the queue statistics in a sensible
way:

$ ethtool -S eth0                   # default would show aggregated statistics
NIC statistics:
	rx_packets: 4357802
	rx_bytes: 292642052
	tx_packets: 4103317
	tx_bytes: 274971428

$ ethtool -S eth0 full group queue  # full statistics, grouped by queue name
NIC statistics:
rxq0:
	rx_packets: 4357802
	rx_bytes: 292642052
rxq1:
	rx_packets: 0
	rx_bytes: 0
[...]
txq0:
	tx_packets: 824540
	tx_bytes: 55256404
txq1:
	tx_packets: 1094268
	tx_bytes: 73328316
[...]

$ ethtool -S eth0 full group statistic  # full statistics, grouped by statistic name
NIC statistics:
rx_packets:
	rxq0: 4357802
	rxq1: 0
	rxq2: 0
	rxq3: 0
rx_bytes:
	rxq0: 292642052
	rxq1: 0
	rxq2: 0
	rxq3: 0
[...]

Maybe even:

$ ethtool -S eth0 full table
NIC statistics:
	rx_packets   rx_bytes
rxq0:      4357802  292642052
rxq1:            0          0
rxq2:            0          0
rxq3:            0          0
	tx_packets   tx_bytes
txq0:       824540   55256404
txq1:      1094268   73328316
txq2:      1091466   73140566
txq3:      1093043   73246142

(Difficult to do, but probably very useful!)

The queue names should be rx-<index> and tx-<index> like in sysfs.

We'll need to reach a consensus on the naming scheme for per-queue and
otherwise disaggregated statistics (see previous discussions in
<http://thread.gmane.org/gmane.linux.kernel.virtualization/15572/focus=15608>).  I don't much care what they look like as long as there's an implementation for the ethtool side and they don't look too awful in older versions of ethtool.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
