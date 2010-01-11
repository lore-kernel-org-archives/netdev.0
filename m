From: "Berck E. Nash" <flyboy@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Sun, 10 Jan 2010 17:36:46 -0700
Message-ID: <4B4A729E.9060805@gmail.com>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera> <omZ8aBZReyD.A.I-H.eNlSLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:55875 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab0AKAgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 19:36:49 -0500
Received: by yxe17 with SMTP id 17so19890664yxe.33
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 16:36:48 -0800 (PST)
In-Reply-To: <omZ8aBZReyD.A.I-H.eNlSLB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> This message has been generated automatically as a part of a report
> of recent regressions.
> 
> The following bug entry is on the current list of known regressions
> from 2.6.32.  Please verify if it still should be listed and let me know
> (either way).
> 
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14925
> Subject		: sky2 panic under load
> Submitter	: Berck E. Nash <flyboy@gmail.com>
> Date		: 2009-12-21 23:52 (21 days old)
> References	: http://marc.info/?l=linux-kernel&m=126143955730347&w=4
> 		  http://marc.info/?l=linux-kernel&m=126160893126548&w=4
> Handled-By	: Stephen Hemminger <shemminger@vyatta.com>

The patch attached to the bug report did not fix the problem, but I'm
fairly certain that this one from Jarek P. did:

During TX timeout procedure dev could be awoken too early, e.g. by
sky2_complete_tx() called from sky2_down(). Then sky2_xmit_frame()
can run while buffers are freed causing an oops. This patch fixes it
by adding netif_device_present() test in sky2_tx_complete().

Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14925

With debugging by: Mike McCormack <mikem@ring3k.org>

Reported-by: Berck E. Nash <flyboy@gmail.com>
Tested-by: Berck E. Nash <flyboy@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 drivers/net/sky2.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 1c01b96..7650f73 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1844,7 +1844,8 @@ static void sky2_tx_complete(struct sky2_port
*sky2, u16 done)
 	sky2->tx_cons = idx;
 	smp_mb();

-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+	/* Wake unless it's detached, and called e.g. from sky2_down() */
+	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
 		netif_wake_queue(dev);
 }

