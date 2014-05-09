From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: avm: potential signedness issue in loading firmware
Date: Fri, 9 May 2014 14:54:37 +0300
Message-ID: <20140509115437.GA31764@mwanda>
References: <20140509102724.GF4963@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, security@kernel.org,
	Henry Hoggard <henry@henryhoggard.co.uk>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39994 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaEILy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 07:54:57 -0400
Content-Disposition: inline
In-Reply-To: <20140509102724.GF4963@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The concern here is that a negative value for "len" could lead underflow
the "while (left > FWBUF_SIZE) {" test and lead to memory corruption.
I do not believe this is possible because we test for negatives in
old_capi_manufacturer(), "if (ldef.t4file.len <= 0) {".

But it sort of makes the code nicer to only deal with positive lengths
so I have made it unsigned.  The length is still not capped and so if we
get a too large value, we keep on writing it out to the firmware byte by
byte until the writes start failing.

Loading the firmware requires CAP_SYS_ADMIN.

Reported-by: Henry Hoggard <henry@henryhoggard.co.uk>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
index 4d9b195..7f2ed49 100644
--- a/drivers/isdn/hardware/avm/b1.c
+++ b/drivers/isdn/hardware/avm/b1.c
@@ -153,7 +153,8 @@ int b1_load_t4file(avmcard *card, capiloaddatapart *t4file)
 {
 	unsigned char buf[FWBUF_SIZE];
 	unsigned char *dp;
-	int i, left;
+	unsigned int left;
+	int i;
 	unsigned int base = card->port;
 
 	dp = t4file->data;
