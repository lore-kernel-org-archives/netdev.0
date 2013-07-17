From: David Miller <davem@davemloft.net>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 17:10:27 -0700 (PDT)
Message-ID: <20130716.171027.644149479332356036.davem@davemloft.net>
References: <1374009169.1949.38.camel@joe-AO722>
	<20130716.162549.1211987183945448630.davem@davemloft.net>
	<1374017532.1949.57.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933828Ab3GQAKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 20:10:30 -0400
In-Reply-To: <1374017532.1949.57.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 16 Jul 2013 16:32:12 -0700

> On Tue, 2013-07-16 at 16:25 -0700, David Miller wrote:
>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> []
>>  ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
> []
>> -       l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
>> -       l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
> []
>> +       return scnprintf(buf, PAGE_SIZE, "%*phC", len, addr);
> 
> missing newline?
> 
> 	scnprintf(buf, PAGE_ SIZE, "%*phC\n", len, addr);

Thanks again Joe, I just commited the following patch:

--------------------
[PATCH] net: Fix sysfs_format_mac() code duplication.

It's just a duplicate implementation of "%*phC".  Thanks to Joe
Perches for showing that we had exactly this support in the
lib/vsprintf.c code already.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ethernet/eth.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5359560..be1f64d 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -401,27 +401,8 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
-static size_t _format_mac_addr(char *buf, int buflen,
-			       const unsigned char *addr, int len)
-{
-	int i;
-	char *cp = buf;
-
-	for (i = 0; i < len; i++) {
-		cp += scnprintf(cp, buflen - (cp - buf), "%02x", addr[i]);
-		if (i == len - 1)
-			break;
-		cp += scnprintf(cp, buflen - (cp - buf), ":");
-	}
-	return cp - buf;
-}
-
 ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 {
-	size_t l;
-
-	l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
-	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
-	return (ssize_t)l;
+	return scnprintf(buf, PAGE_SIZE, "%*phC\n", len, addr);
 }
 EXPORT_SYMBOL(sysfs_format_mac);
-- 
1.7.11.7
