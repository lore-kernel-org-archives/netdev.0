From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/33] sfc: Don't count RX checksum errors during loopback self-test
Date: Fri, 12 Dec 2008 12:53:07 +0000
Message-ID: <20081212125306.GM10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:48738 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757199AbYLLMxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:53:09 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loopback self-test checks that IP packets with incorrect checksums
are not altered when sent on a queue with checksum generation off.
These should not contribute to RX error statistics.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 7421945..dbab9db 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -784,15 +784,18 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			   rx_ev_buf_owner_id_err | rx_ev_eth_crc_err |
 			   rx_ev_frm_trunc | rx_ev_ip_hdr_chksum_err);
 
-	/* Count errors that are not in MAC stats. */
+	/* Count errors that are not in MAC stats.  Ignore expected
+	 * checksum errors during self-test. */
 	if (rx_ev_frm_trunc)
 		++rx_queue->channel->n_rx_frm_trunc;
 	else if (rx_ev_tobe_disc)
 		++rx_queue->channel->n_rx_tobe_disc;
-	else if (rx_ev_ip_hdr_chksum_err)
-		++rx_queue->channel->n_rx_ip_hdr_chksum_err;
-	else if (rx_ev_tcp_udp_chksum_err)
-		++rx_queue->channel->n_rx_tcp_udp_chksum_err;
+	else if (!efx->loopback_selftest) {
+		if (rx_ev_ip_hdr_chksum_err)
+			++rx_queue->channel->n_rx_ip_hdr_chksum_err;
+		else if (rx_ev_tcp_udp_chksum_err)
+			++rx_queue->channel->n_rx_tcp_udp_chksum_err;
+	}
 	if (rx_ev_ip_frag_err)
 		++rx_queue->channel->n_rx_ip_frag_err;
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
