From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] rds: avoid calling sock_kfree_s() on allocation
 failure
Date: Tue, 14 Oct 2014 17:03:11 -0400 (EDT)
Message-ID: <20141014.170311.2104285680542945400.davem@davemloft.net>
References: <1413315308-32288-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	chien.yen@oracle.com, stephen@networkplumber.org,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbaJNVDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:03:14 -0400
In-Reply-To: <1413315308-32288-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 14 Oct 2014 12:35:08 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> It is okay to free a NULL pointer but not okay to mischarge the socket optmem
> accounting. Compile test only.
> 
> Reported-by: rucsoftsec@gmail.com
> Cc: Chien Yen <chien.yen@oracle.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, and I'm going to add the following bug check to the tree too.

====================
[PATCH] net: Trap attempts to call sock_kfree_s() with a NULL pointer.

Unlike normal kfree() it is never right to call sock_kfree_s() with
a NULL pointer, because sock_kfree_s() also has the side effect of
discharging the memory from the sockets quota.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/sock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index b4f3ea2..15e0c67 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1718,6 +1718,8 @@ EXPORT_SYMBOL(sock_kmalloc);
  */
 void sock_kfree_s(struct sock *sk, void *mem, int size)
 {
+	if (WARN_ON_ONCE(!mem))
+		return;
 	kfree(mem);
 	atomic_sub(size, &sk->sk_omem_alloc);
 }
-- 
1.7.11.7
