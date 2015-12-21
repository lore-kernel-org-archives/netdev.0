From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] ipv6/addrlabel: fix ip6addrlbl_get()
Date: Mon, 21 Dec 2015 12:54:45 +0300
Message-ID: <1450691685-29413-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6addrlbl_get() has never worked. If ip6addrlbl_hold() succeeded,
ip6addrlbl_get() will exit with '-ESRCH'. If ip6addrlbl_hold() failed,
ip6addrlbl_get() will use about to be free ip6addrlbl_entry pointer.

Fix this by inverting ip6addrlbl_hold() check.

Fixes: 2a8cc6c89039 ("[IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 net/ipv6/addrlabel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 882124e..a8f6986 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -552,7 +552,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	rcu_read_lock();
 	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
-	if (p && ip6addrlbl_hold(p))
+	if (p && !ip6addrlbl_hold(p))
 		p = NULL;
 	lseq = ip6addrlbl_table.seq;
 	rcu_read_unlock();
-- 
2.4.10
