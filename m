From: David Miller <davem@davemloft.net>
Subject: Re: inconsistent null checking in ipx_ioctl()
Date: Sat, 19 May 2012 00:51:37 -0400 (EDT)
Message-ID: <20120519.005137.1933841560668190190.davem@davemloft.net>
References: <20120514205618.GB20836@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab2ESEvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 00:51:40 -0400
In-Reply-To: <20120514205618.GB20836@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 May 2012 23:56:18 +0300

> Hi, I'm working on some new Smatch stuff and going through some warnings
> in old code.
> 
> ----
> This is a semi-automatic email about new static checker warnings.
> 
> The patch b0d0d915d1d1: "ipx: remove the BKL" from Jan 25, 2011, 
> leads to the following Smatch complaint:
> 
> net/ipx/af_ipx.c:1928 ipx_ioctl()
> 	 error: we previously assumed 'sk' could be null (see line 1913)

Thanks Dan, I've commited the following:

--------------------
ipx: Remove spurious NULL checking in ipx_ioctl().

We already unconditionally dereference 'sk' via lock_sock(sk) earlier
in this function, and our caller (sock_do_ioctl()) makes takes similar
liberties.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipx/af_ipx.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 824d4a3..dfd6faa 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1901,9 +1901,7 @@ static int ipx_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			      (const unsigned short __user *)argp);
 		break;
 	case SIOCGSTAMP:
-		rc = -EINVAL;
-		if (sk)
-			rc = sock_get_timestamp(sk, argp);
+		rc = sock_get_timestamp(sk, argp);
 		break;
 	case SIOCGIFDSTADDR:
 	case SIOCSIFDSTADDR:
-- 
1.7.10.1
