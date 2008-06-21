From: David Miller <davem@davemloft.net>
Subject: [PATCH]: SCTP length validation.
Date: Fri, 20 Jun 2008 22:12:05 -0700 (PDT)
Message-ID: <20080620.221205.183623344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vladislav.yasevich@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750913AbYFUFMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 01:12:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just checked in the following SCTP bug fix to net-2.6 and will make
sure it gets into -stable as well.

sctp: Make sure N * sizeof(union sctp_addr) does not overflow.

As noticed by Gabriel Campana, the kmalloc() length arg
passed in by sctp_getsockopt_local_addrs_old() can overflow
if ->addr_num is large enough.

Therefore, enforce an appropriate limit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/socket.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e7e3baf..0dbcde6 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4401,7 +4401,9 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 	if (copy_from_user(&getaddrs, optval, len))
 		return -EFAULT;
 
-	if (getaddrs.addr_num <= 0) return -EINVAL;
+	if (getaddrs.addr_num <= 0 ||
+	    getaddrs.addr_num >= (INT_MAX / sizeof(union sctp_addr)))
+		return -EINVAL;
 	/*
 	 *  For UDP-style sockets, id specifies the association to query.
 	 *  If the id field is set to the value '0' then the locally bound
-- 
1.5.6

