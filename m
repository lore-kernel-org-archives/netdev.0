From: Joe Perches <joe@perches.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 09:54:46 -0800
Message-ID: <1203616486.7181.269.camel@localhost>
References: <1203586467.20345.14.camel@brick>
	 <20080221.015743.222059206.davem@davemloft.net>
	 <1203588079.20345.15.camel@brick>
	 <20080221.020554.259219477.davem@davemloft.net>
	 (sfid-20080221_100524_615638_119EBE24)  <1203589042.17534.145.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2425 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYBURzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 12:55:53 -0500
In-Reply-To: <1203589042.17534.145.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 11:17 +0100, Johannes Berg wrote:
> Yeah, I saw that discussion. I think it's fine, it's just something we
> need to be aware of. In fact, I Joe had a patch (that seems to have
> gotten lost?) to make DECLARE_MAC_BUF() declare a structure with the u8
> pointer in it instead to get type checking for the args, which would
> make our code there not even compile, and imho rightfully so. I'll send
> in a patch to fix this (via John) and Joe can resend his patch to get
> typechecking there.

This removes the __pure from print_mac, so reject as appropriate...

Add some type safety to print_mac by using 
struct print_mac_buf * instead of char *.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 42dc6a3..2f8df76 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -129,9 +129,16 @@ extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-extern __pure char *print_mac(char *buf, const unsigned char *addr);
-#define MAC_BUF_SIZE	18
-#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
+
+struct print_mac_buf {
+	char formatted_mac_addr[18];
+};
+
+#define DECLARE_MAC_BUF(var) \
+	struct print_mac_buf __maybe_unused _##var; \
+	struct print_mac_buf __maybe_unused *var = &_##var
+
+extern char *print_mac(struct print_mac_buf *buf, const unsigned char *addr);
 
 #endif
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a7b4175..ce607ab 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -384,9 +384,10 @@ ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 }
 EXPORT_SYMBOL(sysfs_format_mac);
 
-char *print_mac(char *buf, const unsigned char *addr)
+char *print_mac(struct print_mac_buf *buf, const unsigned char *addr)
 {
-	_format_mac_addr(buf, MAC_BUF_SIZE, addr, ETH_ALEN);
-	return buf;
+	_format_mac_addr(buf->formatted_mac_addr,
+			 sizeof(buf->formatted_mac_addr), addr, ETH_ALEN);
+	return buf->formatted_mac_addr;
 }
 EXPORT_SYMBOL(print_mac);


