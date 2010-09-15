From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] drivers/net/cxgb3/cxgb3_main.c: prevent reading
 uninitialized stack memory
Date: Wed, 15 Sep 2010 17:43:12 -0400
Message-ID: <1284586992.6275.93.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed formatting (tabs and line breaks).

The CHELSIO_GET_QSET_NUM device ioctl allows unprivileged users to read
4 bytes of uninitialized stack memory, because the "addr" member of the
ch_reg struct declared on the stack in cxgb_extension_ioctl() is not
altered or zeroed before being copied back to the user.  This patch
takes care of it.

Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

--- linux-2.6.35.4.orig/drivers/net/cxgb3/cxgb3_main.c	2010-08-26 19:47:12.000000000 -0400
+++ linux-2.6.35.4/drivers/net/cxgb3/cxgb3_main.c	2010-09-14 21:24:34.369511115 -0400
@@ -2296,6 +2296,8 @@ static int cxgb_extension_ioctl(struct n
 	case CHELSIO_GET_QSET_NUM:{
 		struct ch_reg edata;
 
+		memset(&edata, 0, sizeof(struct ch_reg));
+
 		edata.cmd = CHELSIO_GET_QSET_NUM;
 		edata.val = pi->nqsets;
 		if (copy_to_user(useraddr, &edata, sizeof(edata)))
