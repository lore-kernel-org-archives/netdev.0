From: Craig Hada <craig.hada@hp.com>
Subject: [PATCH net-next] drivers/net: Enable IOMMU pass through for be2net
Date: Wed, 12 Sep 2012 10:58:53 -0700
Message-ID: <1347472734-3196-1-git-send-email-craig.hada@hp.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, craig.hada@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch sets the coherent DMA mask to 64-bit after the be2net driver
has been acknowledged that the system is 64-bit DMA capable. The coherent
DMA mask is examined by the Intel IOMMU driver to determine whether to
allow pass through context mapping for all devices. With this patch, the
be2net driver combined with be2net compatible hardware provides
comparable performance to the case where vt-d is disabled. The main use
case for this change is to decrease the time necessary to copy virtual
machine memory during KVM live migration instantiations.

This patch was tested on a system that enables the IOMMU in non-coherent
mode. Two DMA remapper issues were encountered and both are in the Intel
IOMMU driver with the following patches submitted upstream but not yet
commited.

Patch 1 - DMAR:[fault reason 02] Present bit in context entry is clear
https://lkml.org/lkml/2012/6/15/20

Patch 2 - DMAR:[fault reason 02] Present bit in context entry is clear
https://lkml.org/lkml/2011/11/11/279

The performance of this patch was measured with netperf with vt-d
enabled and disabled along with kernel boot parameters intel_iommu
and iommu. Netperf was run 3 times and averaged for each configuration
of vt-d and boot parameters. The command and parameters used in the
netperf runs along with results are as follows:

# netperf -c -p 12865 -H 10.10.0.2 -t TCP_STREAM -l 60

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

vt-d enabled and intel-iommu=on
 87380  16384  16384    60.0       3634.29   16.76    -1.00    2.267   -1.000

vt-d enabled
 87380  16384  16384    60.00      6779.01   6.77     -1.00    0.489   -1.000

vt-d disabled
 87380  16384  16384    60.00      6807.70   7.00     -1.00    0.505   -1.000

vt-d enabled and intel_iommu=on and iommu=pt
 87380  16384  16384    60.00      6849.93   7.19     -1.00    0.516   -1.000


Craig Hada (1):
  drivers/net: Enable IOMMU pass through for be2net

 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)
