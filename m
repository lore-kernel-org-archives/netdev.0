From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Mon, 22 Jan 2007 10:06:16 -0700
Message-ID: <20070122170615.GA15293@xyzzy.farnsworth.org>
References: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com> <20070109130220.GA4060@ff.dom.local> <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com> <20070109200541.GA27089@xyzzy.farnsworth.org> <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com> <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com> <20070111104220.GA3171@ff.dom.local> <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com> <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com> <20070122100236.GC2079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thibaut VARENE <T-Bone@parisc-linux.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:2187 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932085AbXAVRGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 12:06:17 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070122100236.GC2079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek and Thibaut,

Thank you both very much for your work finding and fixing this bug.
Jarek, can you verify that the following patch fixes the problem you
were seeing?

-Dale

----- Patch follows -----

From: Dale Farnsworth <dale@farnsworth.org>

mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs

The bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
and Jarek Poplawski <jarkao2@o2.pl>.  This patch is a modification of their
fixes.  We acquire and release the lock for each descriptor that is freed
to minimize the time the lock is held.

---

 drivers/net/mv643xx_eth.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c41ae42..0d32381 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -314,6 +314,13 @@ int mv643xx_eth_free_tx_descs(struct net
 
 	while (mp->tx_desc_count > 0) {
 		spin_lock_irqsave(&mp->lock, flags);
+
+		/* maybe tx_desc_count changed before the lock was acquired */
+		if (mp->tx_desc_count <= 0) {
+			spin_unlock_irqrestore(&mp->lock, flags);
+			return released;
+		}
+
 		tx_index = mp->tx_used_desc_q;
 		desc = &mp->p_tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
