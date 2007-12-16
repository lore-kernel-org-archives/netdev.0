From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Badness at net/core/dev.c:2199
Date: Sun, 16 Dec 2007 21:20:57 +0300
Message-ID: <20071216182057.GB31380@2ka.mipt.ru>
References: <Pine.SOC.4.64.0712161952130.27147@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47900 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515AbXLPSVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 13:21:32 -0500
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0712161952130.27147@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 07:55:55PM +0200, Meelis Roos (mroos@linux.ee) wrote:
> Just got this trace from current 2.6.24-rc5+git running on 32-bit ppc 
> (PReP subarch, tulip NIC's) during apt-get update (logged in via ssh so 
> also ssh traffic):
> 
> ------------[ cut here ]------------
> Badness at net/core/dev.c:2199

Please test attached patch.
If I understood ltulip correctly, it is posible, that number of entries
can be higher than requested budget. When work_done is equal to
budget-1, the last skb has to be processed, after 154'th line
work_done will become equal to budget and thus loop has to break,
check on the same 154 line will become false, but work_done will be
increased nevertheless, which will make work_done being equal to
budget+1 at exit, which will fire warning you saw.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 3653314..9e0e97a 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -151,8 +151,9 @@ int tulip_poll(struct napi_struct *napi, int budget)
                        if (tulip_debug > 5)
                                printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
                                       dev->name, entry, status);
-		       if (work_done++ >= budget)
+		       if (work_done >= budget)
                                goto not_done;
+		       work_done++;
 
                        if ((status & 0x38008300) != 0x0300) {
                                if ((status & 0x38000300) != 0x0300) {


-- 
	Evgeniy Polyakov
