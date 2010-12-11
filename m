From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Fri, 10 Dec 2010 16:50:03 -0800 (PST)
Message-ID: <20101210.165003.267942493.davem@davemloft.net>
References: <20101210124009.GC10623@bicker>
	<20101211014154.3157588b@absol.kitzblitz>
	<20101210.164721.85429801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: nikai@nikai.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756609Ab0LKAtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:49:35 -0500
In-Reply-To: <20101210.164721.85429801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 10 Dec 2010 16:47:21 -0800 (PST)

> From: Nicolas Kaiser <nikai@nikai.net>
> Date: Sat, 11 Dec 2010 01:41:54 +0100
> 
>> Ahem, we're printing this return value:
>> 
>> * Dan Carpenter <error27@gmail.com>:
>>> -	if ((ret = copy_from_user(&size, p, sizeof(int)))) {
>>              ^^^
>>> +	if (copy_from_user(&size, p, sizeof(int))) {
>>>  		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", ret);
>>                                                                              ^^^
>>> -		return ret;
>>> +		return -EFAULT;
> 
> I'll fix this, thanks.

As follows:

>From cf108fdd482e80161128c2ed01e7f4fb5bc728b9 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Fri, 10 Dec 2010 16:49:24 -0800
Subject: [PATCH] isdn: Fix printed out copy_from_user() return value after previous change.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/isar.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index c9cd4d2..313ce2d 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -189,7 +189,7 @@ ISARVersion(struct IsdnCardState *cs, char *s)
 static int
 isar_load_firmware(struct IsdnCardState *cs, u_char __user *buf)
 {
-	int ret, size, cnt, debug;
+	int cfu_ret, size, cnt, debug;
 	u_char len, nom, noc;
 	u_short sadr, left, *sp;
 	u_char __user *p = buf;
@@ -212,8 +212,9 @@ isar_load_firmware(struct IsdnCardState *cs, u_char __user *buf)
 	cs->debug &= ~(L1_DEB_HSCX | L1_DEB_HSCX_FIFO);
 #endif
 	
-	if (copy_from_user(&size, p, sizeof(int))) {
-		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", ret);
+	cfu_ret = copy_from_user(&size, p, sizeof(int));
+	if (cfu_ret) {
+		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", cfu_ret);
 		return -EFAULT;
 	}
 	p += sizeof(int);
-- 
1.7.3.2

