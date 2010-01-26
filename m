From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] starfire: Clean up properly if firmware loading fails
Date: Mon, 25 Jan 2010 18:15:08 -0800
Message-ID: <20100125181508.790010cb.akpm@linux-foundation.org>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
	<20100125170816.db9435ed.akpm@linux-foundation.org>
	<1264471333.373.349.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, michael@moffatt.org.nz,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44351 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753524Ab0AZCQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:16:45 -0500
In-Reply-To: <1264471333.373.349.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2010 02:02:12 +0000 Ben Hutchings <bhutchings@solarflare.com> wrote:

> netdev_open() will return without cleaning up net device or hardware
> state if firmware loading fails.  This results in a BUG() on a second
> attempt to bring the interface up, reported in
> <http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has
> even worse effects if the driver is removed afterwards.

(That's the wrong bugzilla URL)

> 
> Call netdev_close() to clean up on failure.

OK, thanks.

> ---
> On Mon, 2010-01-25 at 17:08 -0800, Andrew Morton wrote: 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Wed, 20 Jan 2010 04:29:20 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=15091
> > > 
> > >            Summary: starfire causes kernel BUG when interface goes up
> [...] 
> > > I formerly used 2.6.20 and 2.6.24 with a couple of starfire 4 port ethernet
> > > cards. On 2.6.32 the interfaces don't start on boot and when I issue "ifconfig
> > > ethX up" (where X is a starfire port).
> [...] 
> > Starfire is triggering the BUG_ON(!test_bit(NAPI_STATE_SCHED,
> > &n->state)); in napi_enable().
> > 
> > This is a regression somewhere between 2.6.24 and 2.6.32(!).
> 
> This driver now attempts to load firmware when an interface is brought
> up, *after* calling napi_enable().  If that fails, it will return
> without calling napi_disable().  On the second attempt to bring the
> interface it calls napi_enable() a second time and triggers this
> assertion.
> 
> As a workaround, try installing the necessary firmware. :-)
> 

Missing signed-off-by.  I added it, OK?  Also added a Cc:stable.


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



