From: Craig Hada <craig.hada@hp.com>
Subject: [PATCH v2 net-next] drivers/net: Enable IOMMU pass through for be2net
Date: Fri, 18 Jan 2013 18:23:14 -0800
Message-ID: <1358562195-2028-1-git-send-email-craig.hada@hp.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, craig.hada@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34229 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3ASC0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 21:26:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the coherent DMA mask to 64-bit after the be2net driver 
has been acknowledged that the system is 64-bit DMA capable. The coherent 
DMA mask is examined by the Intel IOMMU driver to determine whether to 
allow pass through context mapping for all devices. With this patch, the 
be2net driver combined with be2net compatible hardware provides 
comparable performance to the case where vt-d is disabled. The main use 
case for this change is to decrease the time necessary to copy virtual 
machine memory during KVM live migration instantiations.

This patch was tested on a system that enables the IOMMU in non-coherent 
mode. Two DMA remapper issues were encountered in the previous version and 
both patches have been committed.
    commit ea2447f700cab264019b52e2b417d689e052dcfd
    commit 2e12bc29fc5a12242d68e11875db3dd58efad9ff

The performance of this patch was measured with netperf with vt-d 
enabled and disabled along with kernel boot parameters intel_iommu 
and iommu. The command and parameters used in the netperf runs along 
with results are as follows:


# netperf -c -p 12865 -H 10.10.0.2 -t TCP_STREAM -l 60

vt-d enabled and intel-iommu=on
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    60.00      4636.58   16.76    -1.00    1.777   -1.000
 87380  16384  16384    60.00      4718.79   17.30    -1.00    1.802   -1.000
 87380  16384  16384    60.00      4566.91   18.04    -1.00    1.942   -1.000

vt-d enabled
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    60.00      6837.12   7.21     -1.00    0.518   -1.000
 87380  16384  16384    60.00      6956.20   6.38     -1.00    0.450   -1.000
 87380  16384  16384    60.00      6903.63   6.75     -1.00    0.481   -1.000

vt-d disabled
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    60.00      6909.70   6.57     -1.00    0.467   -1.000
 87380  16384  16384    60.00      6811.79   6.90     -1.00    0.498   -1.000
 87380  16384  16384    60.00      6861.32   6.71     -1.00    0.481   -1.000

vt-d enabled and intel_iommu=on and iommu=pt
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    60.00      6768.45   7.30     -1.00    0.530   -1.000
 87380  16384  16384    60.00      6841.40   7.39     -1.00    0.531   -1.000
 87380  16384  16384    60.00      6861.78   5.68     -1.00    0.407   -1.000


Craig Hada (1):
  drivers/net: Enable IOMMU pass through for be2net

 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)
