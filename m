From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/16] net/compat: Fix minor information leak in
 siocdevprivate_ioctl()
Date: Thu, 5 Dec 2013 23:42:02 +0000
Message-ID: <1386286922.1516.124.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34665 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3LEXmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:42:06 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to check that ifr_data itself is a valid user pointer,
but we should check &ifr_data is.  Thankfully the copy of ifr_name is
checked, so this can only leak a few bytes from immediately above the
user address limit.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This might deserve to go into net instead.  Not sure.

Ben.

 net/socket.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index c226aceee65b..fbb6ec13b1f4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3015,19 +3015,16 @@ static int siocdevprivate_ioctl(struct net *net, unsigned int cmd,
 	if (copy_from_user(&tmp_buf[0], &(u_ifreq32->ifr_ifrn.ifrn_name[0]),
 			   IFNAMSIZ))
 		return -EFAULT;
-	if (__get_user(data32, &u_ifreq32->ifr_ifru.ifru_data))
+	if (get_user(data32, &u_ifreq32->ifr_ifru.ifru_data))
 		return -EFAULT;
 	data64 = compat_ptr(data32);
 
 	u_ifreq64 = compat_alloc_user_space(sizeof(*u_ifreq64));
 
-	/* Don't check these user accesses, just let that get trapped
-	 * in the ioctl handler instead.
-	 */
 	if (copy_to_user(&u_ifreq64->ifr_ifrn.ifrn_name[0], &tmp_buf[0],
 			 IFNAMSIZ))
 		return -EFAULT;
-	if (__put_user(data64, &u_ifreq64->ifr_ifru.ifru_data))
+	if (put_user(data64, &u_ifreq64->ifr_ifru.ifru_data))
 		return -EFAULT;
 
 	return dev_ioctl(net, cmd, u_ifreq64);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
