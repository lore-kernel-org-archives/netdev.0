From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix chunk parameter processing bug
Date: Wed, 05 Mar 2008 15:10:03 +0800
Message-ID: <47CE474B.3040709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	vladislav <vladislav.yasevich@hp.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56748 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbYCEHL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 02:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an address family is not listed in "Supported Address Types" parameter(INIT Chunk), 
but the packet is sent by that family, this address family should be considered as supported by peer.
Otherwise, an error condition will occur. For instance, if kernel receives an IPV6 SCTP INIT chunk with
"Support Address Types" parameter which indicates just supporting IPV4 Address family. Kernel will reply
an IPV6 SCTP INIT ACK packet, but the source ipv6 address in ipv6 header will be vacant. This is not correct.

refer to RFC4460 as following:
      IMPLEMENTATION NOTE: If an SCTP endpoint lists in the 'Supported
      Address Types' parameter either IPv4 or IPv6, but uses the other
      family for sending the packet containing the INIT chunk, or if it
      also lists addresses of the other family in the INIT chunk, then
      the address family that is not listed in the 'Supported Address
      Types' parameter SHOULD also be considered as supported by the
      receiver of the INIT chunk.  The receiver of the INIT chunk SHOULD
      NOT respond with any kind of error indication.

Here is a fix to comply to RFC.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/sctp/sm_make_chunk.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index e45be4e..ed5d413 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2375,6 +2375,14 @@ static int sctp_process_param(struct sctp_association *asoc,
 		asoc->peer.ipv4_address = 0;
 		asoc->peer.ipv6_address = 0;
 
+		/* Assume that peer supports the address family 
+		   by which it sends a packet.
+		*/
+		if (peer_addr->sa.sa_family == AF_INET6)
+			asoc->peer.ipv6_address = 1;
+		else if (peer_addr->sa.sa_family == AF_INET)
+			asoc->peer.ipv4_address = 1;
+
 		/* Cycle through address types; avoid divide by 0. */
 		sat = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
 		if (sat)
-- 
1.5.3


-- 
Regards
Gui Jianfeng




