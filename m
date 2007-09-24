From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 24 Sep 2007 10:28:34 -0700
Message-ID: <1190654914.2010.8.camel@localhost>
References: <1190177401.19708.264.camel@localhost>
	 <20070919.111147.55510143.davem@davemloft.net>
	 <1190227854.26101.9.camel@localhost>
	 <20070919.125451.112289690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1500 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751413AbXIXR3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 13:29:36 -0400
In-Reply-To: <20070919.125451.112289690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-19 at 12:54 -0700, David Miller wrote:
> Applied to net-2.6.24, thanks Joe!

Here is a patch that adds some type safety to print_mac
by using a struct print_mac_buf * instead of char *.

It also reduces the defconfig vmlinux size by 8 bytes.

Signed-off-by:  Joe Perches <joe@perches.com>

--

 include/linux/if_ether.h |   12 ++++++++++--
 net/ethernet/eth.c       |    6 +++---
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 57abca1..620d6b1 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -126,7 +126,15 @@ extern struct ctl_table ether_table[];
  *	Display a 6 byte device address (MAC) in a readable format.
  */
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-extern char *print_mac(char *buf, const u8 *addr);
-#define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
+
+struct print_mac_buf {
+	char formatted_mac_addr[18];
+};
+
+#define DECLARE_MAC_BUF(var) \
+	struct print_mac_buf __maybe_unused _##var; \
+	struct print_mac_buf __maybe_unused *var = &_##var
+
+extern char *print_mac(struct print_mac_buf *buf, const u8 *addr);
 
 #endif	/* _LINUX_IF_ETHER_H */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 2aaf6fa..ad82613 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -338,10 +338,10 @@ struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
 }
 EXPORT_SYMBOL(alloc_etherdev_mq);
 
-char *print_mac(char *buf, const u8 *addr)
+char *print_mac(struct print_mac_buf *buf, const u8 *addr)
 {
-	sprintf(buf, MAC_FMT,
+	sprintf(buf->formatted_mac_addr, MAC_FMT,
 		addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
-	return buf;
+	return buf->formatted_mac_addr;
 }
 EXPORT_SYMBOL(print_mac);


