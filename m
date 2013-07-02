From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC ] netlink: limit large vmalloc() based skbs to NETLINK_NETFILTER
Date: Tue, 2 Jul 2013 23:50:15 +0200
Message-ID: <20130702215015.GA1979@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48363 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755105Ab3GBVuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 17:50:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c05cdb1b ("netlink: allow large data transfers from
user-space") the large skbs are allocated via vmalloc(). Trinity
triggered this in response:

| BUG: unable to handle kernel paging request at ffffc900001bf001
| IP: [<ffffffff8135270a>] skb_clone+0x1a/0xa0
| Call Trace:
|  [<ffffffff813cb107>] nl_fib_input+0x37/0x230
|  [<ffffffff8142c9b2>] ? _raw_read_unlock+0x22/0x40
|  [<ffffffff81380b1a>] netlink_unicast+0x13a/0x1f0
|  [<ffffffff81380ef7>] netlink_sendmsg+0x327/0x420

The problem is that the vmalloc() based skb ends exactly at size (where
->end is pointing) and skb_shinfo() starts past ->end where we have our
guard page and hence we BUG().
The question is should we fix this or forbid the skb_clone(). Fixing this
behaviour is tricky because even after we add space for struct
skb_shared_info we release the memory from the destructor so once the
first skbs is gone, the memory in the clone is invalid.
The other case where skb_clone() is used is when we have mutltiple
destinations.
Since I assume the initial target was to extend the size for
NETLINK_NETFILTER this patch limits to this target only and with single
destination.
Is this okay?

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 net/netlink/af_netlink.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 68c1673..9926453 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2129,7 +2129,11 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = netlink_alloc_large_skb(len);
+	if (netlink_is_kernel(sk) && sk->sk_protocol == NETLINK_NETFILTER &&
+			!dst_group)
+		skb = netlink_alloc_large_skb(len);
+	else
+		skb = alloc_skb(len, GFP_KERNEL);
 	if (skb == NULL)
 		goto out;
 
-- 
1.8.3.1
