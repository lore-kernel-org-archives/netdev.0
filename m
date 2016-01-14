From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 0/4] Implement local checksum offload support for tunnel
 segmentation
Date: Wed, 13 Jan 2016 21:11:55 -0800
Message-ID: <20160114045532.5119.56124.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35201 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcANFL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 00:11:57 -0500
Received: by mail-pf0-f175.google.com with SMTP id 65so93394339pff.2
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 21:11:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series updates the existing segmentation offload code for
tunnels to make better use of existing and updated GSO checksum
computation.  This is done primarily through two mechanisms.  First we
maintain a separate checksum in the GSO context block of the sk_buff.  This
allows us to maintain two checksum values, one offloaded with values stored
in csum_start and csum_offset, and one computed and tracked in
SKB_GSO_CB(skb)->csum.  By maintaining these two values we are able to take
advantage of the same sort of math used in local checksum offload so that
we can provide both inner and outer checksums with minimal overhead.

Below is the performance for a netperf session between an ixgbe PF and VF
on the same host but in different namespaces.  As can be seen a significant
gain in performance can be had from allowing the use of Tx checksum offload
on the inner headers while performing a software offload on the outer
header computation:

 Recv   Send   Send                       Utilization  Service Demand
 Socket Socket Message Elapsed            Send  Recv   Send  Recv
 Size   Size   Size    Time    Throughput local remote local remote
 bytes  bytes  bytes   secs.   10^6bits/s % S   % U    us/KB us/KB

Before:
 87380  16384  16384   10.00   12844.38   9.30  -1.00  0.712 -1.00
After:
 87380  16384  16384   10.00   13216.63   6.78  -1.00  0.504 -1.000

The one piece I believe that may be controversial in this patch is the
part where I added the usage of CHECKSUM_UNNECESSARY in GSO so that we
could use it to flag when we were computing a checksum but it didn't belong
to the current transport layer.  So for example in the case of remote
checksum offload if there is a request for us to generate the outer header
checksum, but we do not have a hardware offload we need to compute the
checksum for the data, but not the TCP headers.  So in order to not
populate the headers in this case, and to not flag TCP as being offloaded
by the hardware I have added the use of CHECKSUM_UNNECESSARY to indicate
that there is a checksum, but it doesn't apply to the current headers.

---

Alexander Duyck (4):
      net: Move GSO csum into SKB_GSO_CB
      net: Update remote checksum segmentation to support use of GSO checksum
      net: Store checksum result for offloaded GSO checksums
      net: Allow UDP and GRE to use inner checksum offloads with outer checksums needed


 include/linux/skbuff.h |   27 +++++++++++++++++------
 net/core/skbuff.c      |   32 +++++++++++++++------------
 net/ipv4/gre_offload.c |    2 --
 net/ipv4/tcp_offload.c |    8 +++++--
 net/ipv4/udp_offload.c |   57 +++++++++++++++++-------------------------------
 5 files changed, 64 insertions(+), 62 deletions(-)
