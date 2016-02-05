From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 00/10] Add GSO support for outer checksum w/ inner
 checksum offloads
Date: Fri, 05 Feb 2016 15:27:25 -0800
Message-ID: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33456 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcBEX10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:27:26 -0500
Received: by mail-pf0-f175.google.com with SMTP id w123so76621510pfb.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:27:26 -0800 (PST)
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

Changes from v1:
* Dropped use of CHECKSUM_UNNECESSARY for remote checksum offload
* Left encap_hdr_csum as it will likely be needed in future for SCTP GSO
* Broke the changes out over many more patches
* Updated GRE segmentation to more closely match UDP tunnel segmentation

---

Alexander Duyck (10):
      net: Drop unecessary enc_features variable from tunnel segmentation functions
      net: Move GSO csum into SKB_GSO_CB
      net: Update remote checksum segmentation to support use of GSO checksum
      net: Store checksum result for offloaded GSO checksums
      net: Move skb_has_shared_frag check out of GRE code and into segmentation
      gre: Use GSO flags to determine csum need instead of GRE flags
      gre: Use inner_proto to obtain inner header protocol
      udp: Clean up the use of flags in UDP segmentation offload
      udp: Use uh->len instead of skb->len to compute checksum in segmentation
      net: Allow tunnels to use inner checksum offloads with outer checksums needed


 include/linux/skbuff.h |   29 +++++++++++----
 net/core/skbuff.c      |   34 +++++++++++-------
 net/ipv4/gre_offload.c |   85 ++++++++++++++++++--------------------------
 net/ipv4/tcp_offload.c |    8 +++-
 net/ipv4/udp_offload.c |   93 +++++++++++++++++++++++-------------------------
 5 files changed, 127 insertions(+), 122 deletions(-)
