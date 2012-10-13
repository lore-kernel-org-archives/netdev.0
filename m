From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sock filter: fix copy of filter from userspace
Date: Sat, 13 Oct 2012 11:40:32 -0700
Message-ID: <20121013114032.2d1c1434@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41254 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005Ab2JMSlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2012 14:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_unattached_filter_create function is passed a socket
filter structure and the copies the contents of the filter from
userspace. Sparse detected that this code was incorrectly using
memcpy when it needed to use copy_from_user instead.

The only use of sk_unattached_filter_create at present is in
the team driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/filter.c	2012-10-09 10:35:03.183141638 -0700
+++ b/net/core/filter.c	2012-10-13 11:33:05.955531440 -0700
@@ -666,7 +666,9 @@ int sk_unattached_filter_create(struct s
 	fp = kmalloc(fsize + sizeof(*fp), GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
-	memcpy(fp->insns, fprog->filter, fsize);
+
+	if (copy_from_user(fp->insns, fprog->filter, fsize))
+		return -EFAULT;
 
 	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
