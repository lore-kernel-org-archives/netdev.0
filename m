From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] ray_cs: reduce stack usage
Date: Thu, 27 Jan 2005 21:49:46 -0800
Message-ID: <41F9D27A.8090204@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090109010602020104060907"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>, corey@world.std.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090109010602020104060907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


ray_cs: reduce local stack usage in ray_dev_ioctl
   from 1048 to 468 (on i386) by making 'range' kmalloc-ed
   instead of an automatic stack variable.
         struct iw_range range;	// 564 bytes

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/wireless/ray_cs.c |   35 +++++++++++++++++++++--------------
  1 files changed, 21 insertions(+), 14 deletions(-)

--------------090109010602020104060907
Content-Type: text/x-patch;
 name="raycs_stack1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="raycs_stack1.patch"


diff -Naurp ./drivers/net/wireless/ray_cs.c~raycs_stack ./drivers/net/wireless/ray_cs.c
--- ./drivers/net/wireless/ray_cs.c~raycs_stack	2005-01-27 20:38:05.678592648 -0800
+++ ./drivers/net/wireless/ray_cs.c	2005-01-27 21:05:51.637328424 -0800
@@ -1467,33 +1467,39 @@ static int ray_dev_ioctl(struct net_devi
       /* Basic checking... */
       if(wrq->u.data.pointer != (caddr_t) 0)
 	{
-	  struct iw_range	range;
-	  memset((char *) &range, 0, sizeof(struct iw_range));
+	  struct iw_range	*range;
+	  range = kmalloc(sizeof(struct iw_range), GFP_KERNEL);
+	  if (!range) {
+	    err = -ENOMEM;
+	    goto ioc_out;
+	  }
+	  memset((char *) range, 0, sizeof(struct iw_range));
 
 	  /* Set the length (very important for backward compatibility) */
 	  wrq->u.data.length = sizeof(struct iw_range);
 
 #if WIRELESS_EXT > 10
 	  /* Set the Wireless Extension versions */
-	  range.we_version_compiled = WIRELESS_EXT;
-	  range.we_version_source = 9;
+	  range->we_version_compiled = WIRELESS_EXT;
+	  range->we_version_source = 9;
 #endif /* WIRELESS_EXT > 10 */
 
 	  /* Set information in the range struct */
-	  range.throughput = 1.1 * 1000 * 1000;	/* Put the right number here */
-	  range.num_channels = hop_pattern_length[(int)country]; 
-	  range.num_frequency = 0;
-	  range.max_qual.qual = 0;
-	  range.max_qual.level = 255;	/* What's the correct value ? */
-	  range.max_qual.noise = 255;	/* Idem */
-	  range.num_bitrates = 2;
-	  range.bitrate[0] = 1000000;	/* 1 Mb/s */
-	  range.bitrate[1] = 2000000;	/* 2 Mb/s */
+	  range->throughput = 1.1 * 1000 * 1000;	/* Put the right number here */
+	  range->num_channels = hop_pattern_length[(int)country]; 
+	  range->num_frequency = 0;
+	  range->max_qual.qual = 0;
+	  range->max_qual.level = 255;	/* What's the correct value ? */
+	  range->max_qual.noise = 255;	/* Idem */
+	  range->num_bitrates = 2;
+	  range->bitrate[0] = 1000000;	/* 1 Mb/s */
+	  range->bitrate[1] = 2000000;	/* 2 Mb/s */
 
 	  /* Copy structure to the user buffer */
-	  if(copy_to_user(wrq->u.data.pointer, &range,
+	  if(copy_to_user(wrq->u.data.pointer, range,
 			  sizeof(struct iw_range)))
 	    err = -EFAULT;
+	  kfree(range);
 	}
       break;
 
@@ -1632,6 +1638,7 @@ static int ray_dev_ioctl(struct net_devi
             DEBUG(0,"ray_dev_ioctl cmd = 0x%x\n", cmd);
             err = -EOPNOTSUPP;
     }
+ioc_out:
     return err;
 } /* end ray_dev_ioctl */
 /*===========================================================================*/

--------------090109010602020104060907--
