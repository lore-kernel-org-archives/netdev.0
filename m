From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Thu, 10 Jan 2008 21:22:42 -0800 (PST)
Message-ID: <20080110.212242.42433023.davem@davemloft.net>
References: <20071228214857.GA3290@ami.dom.local>
	<20071229.191443.10947724.davem@davemloft.net>
	<20071230141323.GA3377@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, ralf@linux-mips.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750809AbYAKFWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 00:22:42 -0500
In-Reply-To: <20071230141323.GA3377@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 30 Dec 2007 15:13:23 +0100

> On Sat, Dec 29, 2007 at 07:14:43PM -0800, David Miller wrote:
> ...
> > You can't just drop this linked list lock and expect it to stay
> > consistent like that.
> > 
> > Once you drop it, any thread of control can get in there and delete
> > entries from the list.
> > 
> > Since we know it can happen, using a WARN_ON_ONCE(1) is not
> > appropriate.
> 
> The problem is 'we' don't know if it can happen... In the first
> message with this patch I've tried to get this information, and
> now it seems you are the only one with this knowledge, but of
> course this is more than enough for me to agree with your decision
> to dump this patch.

I've removed the warning and made the branch back to 'again'
unconditional as I think this is the safest version of the
change.

I'll push this upstream, thanks for fixing this Jarek.

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index ecb14ee..b4725ff 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -87,10 +87,22 @@ static void ax25_kill_by_device(struct net_device *dev)
 		return;
 
 	spin_lock_bh(&ax25_list_lock);
+again:
 	ax25_for_each(s, node, &ax25_list) {
 		if (s->ax25_dev == ax25_dev) {
 			s->ax25_dev = NULL;
+			spin_unlock_bh(&ax25_list_lock);
 			ax25_disconnect(s, ENETUNREACH);
+			spin_lock_bh(&ax25_list_lock);
+
+			/* The entry could have been deleted from the
+			 * list meanwhile and thus the next pointer is
+			 * no longer valid.  Play it safe and restart
+			 * the scan.  Forward progress is ensured
+			 * because we set s->ax25_dev to NULL and we
+			 * are never passed a NULL 'dev' argument.
+			 */
+			goto again;
 		}
 	}
 	spin_unlock_bh(&ax25_list_lock);
-- 
1.5.4.rc2.84.gf85fd

