From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] X.25 remove bkl in accept
Date: Tue, 14 Sep 2010 20:40:49 -0700 (PDT)
Message-ID: <20100914.204049.104051991.davem@davemloft.net>
References: <1284507110.1742.56.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37269
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753161Ab0IODkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:40:31 -0400
In-Reply-To: <1284507110.1742.56.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Wed, 15 Sep 2010 09:31:50 +1000

> Accept already has socket locking.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied, but I took the liberty of moving the socket locking
above the TCP_LISTEN state check as follows:

--------------------
X.25 remove bkl in accept

Accept already has socket locking.

[ Extend socket locking over TCP_LISTEN state test. -DaveM ]

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/x25/af_x25.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index bd6fce3..04321ee 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -869,8 +869,7 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int rc = -EINVAL;
 
-	lock_kernel();
-	if (!sk || sk->sk_state != TCP_LISTEN)
+	if (!sk)
 		goto out;
 
 	rc = -EOPNOTSUPP;
@@ -878,6 +877,10 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 		goto out;
 
 	lock_sock(sk);
+	rc = -EINVAL;
+	if (sk->sk_state != TCP_LISTEN)
+		goto out2;
+
 	rc = x25_wait_for_data(sk, sk->sk_rcvtimeo);
 	if (rc)
 		goto out2;
@@ -897,7 +900,6 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 out2:
 	release_sock(sk);
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.2.2

