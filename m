From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 4/5] ppp: protect access to ppp->last_{xmit,recv} in
 ppp_ioctl()
Date: Mon, 22 Feb 2016 20:47:19 +0100
Message-ID: <6778ebf050f00363ef5f4edfc53b7f905201abd5.1456167043.git.g.nault@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:53804 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbcBVUtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:49:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp->last_xmit is witten to by ppp_send_frame() while protected by
ppp_xmit_lock().
Likewise, ppp->last_recv is written to by ppp_receive_nonmp_frame()
while protected by ppp_recv_lock().

Holding both locks is therefore necessary before ppp_ioctl() can safely
read these fields.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 183d89c..24777f4 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -726,8 +726,11 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		break;
 
 	case PPPIOCGIDLE:
+		ppp_lock(ppp);
 		idle.xmit_idle = (jiffies - ppp->last_xmit) / HZ;
 		idle.recv_idle = (jiffies - ppp->last_recv) / HZ;
+		ppp_unlock(ppp);
+
 		if (copy_to_user(argp, &idle, sizeof(idle)))
 			break;
 		err = 0;
-- 
2.7.0
