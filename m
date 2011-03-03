From: David Miller <davem@davemloft.net>
Subject: Re: [BUG net-next-2.6] dst_release() crash
Date: Thu, 03 Mar 2011 10:38:35 -0800 (PST)
Message-ID: <20110303.103835.226796504.davem@davemloft.net>
References: <1299169686.2983.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758443Ab1CCSh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 13:37:58 -0500
In-Reply-To: <1299169686.2983.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Mar 2011 17:28:06 +0100

> We could add a sanity test in dst_release(), or fix callers ?

Callers are responsible for not passing garbage pointers around
:-)

Thanks for the report.

I just checked in the following fix.

--------------------
ipv4: Fix crash in dst_release when udp_sendmsg route lookup fails.

As reported by Eric:

[11483.697233] IP: [<c12b0638>] dst_release+0x18/0x60
 ...
[11483.697741] Call Trace:
[11483.697764]  [<c12fc9d2>] udp_sendmsg+0x282/0x6e0
[11483.697790]  [<c12a1c01>] ? memcpy_toiovec+0x51/0x70
[11483.697818]  [<c12dbd90>] ? ip_generic_getfrag+0x0/0xb0

The pointer passed to dst_release() is -EINVAL, that's because
we leave an error pointer in the local variable "rt" by accident.

NULL it out to fix the bug.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/udp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 95e0c2c..c9a73e5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -925,6 +925,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = ip_route_output_flow(net, &fl, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
+			rt = NULL;
 			if (err == -ENETUNREACH)
 				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 			goto out;
-- 
1.7.4.1

