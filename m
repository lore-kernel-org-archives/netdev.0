From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mkiss: Fix use after free in sixpack_close().
Date: Fri, 18 Dec 2015 16:03:45 -0500 (EST)
Message-ID: <20151218.160345.1312134246949260423.davem@davemloft.net>
References: <20151217.160549.1465333502952441538.davem@davemloft.net>
	<20151217213531.GB15130@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk, dvyukov@google.com,
	ajk@comnets.uni-bremen.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, jslaby@suse.com,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151217213531.GB15130@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 17 Dec 2015 22:35:31 +0100

> On Thu, Dec 17, 2015 at 04:05:49PM -0500, David Miller wrote:
> 
>> Subject: [PATCH 2/2] mkiss: Fix use after free in sixpack_close().
> 
> Make that subject "... mkiss_close()."

Durrr... indeed.  Thanks for catching that.

Committed as follows:

====================
[PATCH] mkiss: Fix use after free in mkiss_close().

Need to do the unregister_device() after all references to the driver
private have been done.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/hamradio/mkiss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 216bfd3..0b72b9d 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -798,13 +798,13 @@ static void mkiss_close(struct tty_struct *tty)
 	if (!atomic_dec_and_test(&ax->refcnt))
 		down(&ax->dead_sem);
 
-	unregister_netdev(ax->dev);
-
 	/* Free all AX25 frame buffers. */
 	kfree(ax->rbuff);
 	kfree(ax->xbuff);
 
 	ax->tty = NULL;
+
+	unregister_netdev(ax->dev);
 }
 
 /* Perform I/O control on an active ax25 channel. */
-- 
2.4.1
