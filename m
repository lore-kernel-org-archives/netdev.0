From: akpm@linux-foundation.org
Subject: [patch 1/1] starfire: clean up properly if firmware loading fails
Date: Tue, 26 Jan 2010 20:27:09 -0800
Message-ID: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bhutchings@solarflare.com, michael@moffatt.org.nz,
	stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60418 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932150Ab0A0E2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 23:28:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

netdev_open() will return without cleaning up net device or hardware state
if firmware loading fails.  This results in a BUG() on a second attempt to
bring the interface up, reported in
<http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has even
worse effects if the driver is removed afterwards.

Call netdev_close() to clean up on failure.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=15091

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Reported-by: Michael Moffatt <michael@moffatt.org.nz>
Tested-by: Michael Moffatt <michael@moffatt.org.nz>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/starfire.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN drivers/net/starfire.c~starfire-clean-up-properly-if-firmware-loading-fails drivers/net/starfire.c
--- a/drivers/net/starfire.c~starfire-clean-up-properly-if-firmware-loading-fails
+++ a/drivers/net/starfire.c
@@ -1063,7 +1063,7 @@ static int netdev_open(struct net_device
 	if (retval) {
 		printk(KERN_ERR "starfire: Failed to load firmware \"%s\"\n",
 		       FIRMWARE_RX);
-		return retval;
+		goto out_init;
 	}
 	if (fw_rx->size % 4) {
 		printk(KERN_ERR "starfire: bogus length %zu in \"%s\"\n",
@@ -1108,6 +1108,9 @@ out_tx:
 	release_firmware(fw_tx);
 out_rx:
 	release_firmware(fw_rx);
+out_init:
+	if (retval)
+		netdev_close(dev);
 	return retval;
 }
 
_
