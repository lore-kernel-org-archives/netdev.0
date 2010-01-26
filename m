From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Tue, 26 Jan 2010 02:02:12 +0000
Message-ID: <1264471333.373.349.camel@localhost>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	 <20100125170816.db9435ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, michael@moffatt.org.nz,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9363 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab0AZCCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:02:18 -0500
In-Reply-To: <20100125170816.db9435ed.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_open() will return without cleaning up net device or hardware
state if firmware loading fails.  This results in a BUG() on a second
attempt to bring the interface up, reported in
<http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has
even worse effects if the driver is removed afterwards.

Call netdev_close() to clean up on failure.
---
On Mon, 2010-01-25 at 17:08 -0800, Andrew Morton wrote: 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 20 Jan 2010 04:29:20 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=15091
> > 
> >            Summary: starfire causes kernel BUG when interface goes up
[...] 
> > I formerly used 2.6.20 and 2.6.24 with a couple of starfire 4 port ethernet
> > cards. On 2.6.32 the interfaces don't start on boot and when I issue "ifconfig
> > ethX up" (where X is a starfire port).
[...] 
> Starfire is triggering the BUG_ON(!test_bit(NAPI_STATE_SCHED,
> &n->state)); in napi_enable().
> 
> This is a regression somewhere between 2.6.24 and 2.6.32(!).

This driver now attempts to load firmware when an interface is brought
up, *after* calling napi_enable().  If that fails, it will return
without calling napi_disable().  On the second attempt to bring the
interface it calls napi_enable() a second time and triggers this
assertion.

As a workaround, try installing the necessary firmware. :-)

Ben.

 drivers/net/starfire.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 95db60a..f952113 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1063,7 +1063,7 @@ static int netdev_open(struct net_device *dev)
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
 
-- 
1.6.6

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

