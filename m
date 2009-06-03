From: Chris Wright <chrisw@sous-sol.org>
Subject: [PATCH] tun: virtio net is not compatible with LRO
Date: Tue, 2 Jun 2009 22:23:35 -0700
Message-ID: <20090603052335.GA20823@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:52472 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752107AbZFCFYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2009 01:24:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current failure mode for an LRO device bridged to a virtio device
(common for KVM) is BUG().  Rather than crashing the host, we can at
least limp along and give a warning.  lro_flush() will set gso_size,
but no corresponding gso_type, unlike gro which will eventually call
->gro_complete and set up proper gso_type.

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 drivers/net/tun.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 735bf41..17c4516 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -717,8 +717,15 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-			else
-				BUG();
+			else {
+				WARN_ONCE(1, "%s: hdr_len %d gso_size %d "
+					   "gso_type %x.  virtio is not "
+					   "compatible with LRO, verify NIC "
+					    "isn't using LRO", __func__,
+					    gso.hdr_len, gso.gso_size,
+					    sinfo->gso_type);
+				return -EINVAL;
+			}
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
 				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
 		} else
