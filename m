From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ISDN: pcbit: off by one bugs in pcbit_set_msn()
Date: Thu, 31 Jul 2014 18:30:11 +0300
Message-ID: <20140731153011.GF31539@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) We don't allocate enough space for the NUL terminator so we end up
   corrupting one character beyond the end of the buffer.

2) The "len - 1" should just be "len".  The code is trying to copy a
   word from a buffer up to a comma or the last word in the buffer.
   Say you have the buffer, "foo,bar,baz", then this code truncates the
   last letter off each word so you get "fo", "ba", and "ba".  You would
   hope this kind of bug would get noticed in testing...

   I'm not very familiar with this code and I can't test it, but I think
   we should copy the final character.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/pcbit/drv.c b/drivers/isdn/pcbit/drv.c
index f02cc50..4172e22 100644
--- a/drivers/isdn/pcbit/drv.c
+++ b/drivers/isdn/pcbit/drv.c
@@ -1035,14 +1035,14 @@ static void pcbit_set_msn(struct pcbit_dev *dev, char *list)
 		}
 		ptr->next = NULL;
 
-		ptr->msn = kmalloc(len, GFP_ATOMIC);
+		ptr->msn = kmalloc(len + 1, GFP_ATOMIC);
 		if (!ptr->msn) {
 			printk(KERN_WARNING "kmalloc failed\n");
 			kfree(ptr);
 			return;
 		}
 
-		memcpy(ptr->msn, sp, len - 1);
+		memcpy(ptr->msn, sp, len);
 		ptr->msn[len] = 0;
 
 #ifdef DEBUG
