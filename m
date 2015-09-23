From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bnx2x: byte swap rss_key to comply to Toeplitz specs
Date: Tue, 22 Sep 2015 17:04:58 -0700
Message-ID: <1442966698.29850.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442614912.14037.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150922.145935.2262486270670808983.davem@davemloft.net>
	 <20150922.160644.138485112664023430.davem@davemloft.net>
	 <1442964885.29850.100.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35576 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934153AbbIWAFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 20:05:12 -0400
Received: by pacfv12 with SMTP id fv12so23405202pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 17:05:01 -0700 (PDT)
In-Reply-To: <1442964885.29850.100.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After a good amount of debugging, I found bnx2x was byte swaping
the 40 bytes of rss_key.

If we byte swap the key, then bnx2x generates hashes matching
MSDN specs as documented in (Verifying the RSS Hash Calculation)

https://msdn.microsoft.com/en-us/library/windows/hardware/ff571021%
28v=vs.85%29.aspx

It is mostly a non issue, unless we want to mix different NIC
in a host, and want consistent hashing among all of them, ie
if they all use the boot time generated rss key, or if some application
is choosing specific tuple(s) so that incoming traffic lands into known
rx queue(s).

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index c9bd7f16018e..ff702a707a91 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4319,8 +4319,16 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 
 	/* RSS keys */
 	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
-		memcpy(&data->rss_key[0], &p->rss_key[0],
-		       sizeof(data->rss_key));
+		u8 *dst = (u8 *)(data->rss_key) + sizeof(data->rss_key);
+		const u8 *src = (const u8 *)p->rss_key;
+		int i;
+
+		/* Apparently, bnx2x reads this array in reverse order
+		 * We need to byte swap rss_key to comply with Toeplitz specs.
+		 */
+		for (i = 0; i < sizeof(data->rss_key); i++)
+			*--dst = *src++;
+
 		caps |= ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY;
 	}
 
