From: Greg KH <gregkh@suse.de>
Subject: [patch 05/22] sky2: bad memory reference on dual port cards
Date: Thu, 13 Apr 2006 16:07:20 -0700
Message-ID: <20060413230720.GF5613@kroah.com>
References: <20060413230141.330705000@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965007AbWDMXIo@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename="sky2-bad-memory-reference-on-dual-port-cards.patch"
In-Reply-To: <20060413230637.GA5613@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
Sky2 driver will oops referencing bad memory if used on
a dual port card.  The problem is accessing past end of
MIB counter space.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>


---
 drivers/net/sky2.c |    4 ++--
 drivers/net/sky2.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.16.5.orig/drivers/net/sky2.c
+++ linux-2.6.16.5/drivers/net/sky2.c
@@ -579,8 +579,8 @@ static void sky2_mac_init(struct sky2_hw
 	reg = gma_read16(hw, port, GM_PHY_ADDR);
 	gma_write16(hw, port, GM_PHY_ADDR, reg | GM_PAR_MIB_CLR);
 
-	for (i = 0; i < GM_MIB_CNT_SIZE; i++)
-		gma_read16(hw, port, GM_MIB_CNT_BASE + 8 * i);
+	for (i = GM_MIB_CNT_BASE; i <= GM_MIB_CNT_END; i += 4)
+		gma_read16(hw, port, i);
 	gma_write16(hw, port, GM_PHY_ADDR, reg);
 
 	/* transmit control */
--- linux-2.6.16.5.orig/drivers/net/sky2.h
+++ linux-2.6.16.5/drivers/net/sky2.h
@@ -1380,6 +1380,7 @@ enum {
 /* MIB Counters */
 #define GM_MIB_CNT_BASE	0x0100		/* Base Address of MIB Counters */
 #define GM_MIB_CNT_SIZE	44		/* Number of MIB Counters */
+#define GM_MIB_CNT_END	0x025C		/* Last MIB counter */
 
 /*
  * MIB Counters base address definitions (low word) -

--
