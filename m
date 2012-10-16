From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: addrconf: fix /proc/net/if_inet6
Date: Tue, 16 Oct 2012 19:37:27 +0200
Message-ID: <1350409047.3954.1295.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
	 <1350285275.22442.17.camel@joe-AO722>
	 <1350286790.21172.17414.camel@edumazet-glaptop>
	 <1350300302.22442.25.camel@joe-AO722>
	 <1350304308.3954.66.camel@edumazet-glaptop>
	 <CAO_aot59XNERsb7q9pZSpSzyFLv=pKEk6wb82PE-sNMf4TDXow@mail.gmail.com>
	 <1350307293.3954.119.camel@edumazet-glaptop>
	 <CAO_aot44shT8CKtCi8Zv0GWN7wjybHX+d5SFQ1daVOh84v+L1g@mail.gmail.com>
	 <CAO_aot66K-7Je8dSnYTxxkoaDgQ3JpG7t=MdTK0A0ixPX_AP-A@mail.gmail.com>
	 <1350405787.3954.1229.camel@edumazet-glaptop>
	 <1350406522.3954.1242.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mihai Maruseac <mihai.maruseac@gmail.com>
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42379 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab2JPRhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:37:32 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3155393bkc.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 10:37:31 -0700 (PDT)
In-Reply-To: <1350406522.3954.1242.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 1d5783030a1 (ipv6/addrconf: speedup /proc/net/if_inet6 filling)
added bugs hiding some devices from if_inet6 and breaking applications.

"ip -6 addr" could still display all IPv6 addresses, while "ifconfig -a"
couldnt.

One way to reproduce the bug is by starting in a shell :

unshare -n /bin/bash
ifconfig lo up

And in original net namespace, lo device disappeared from if_inet6

Reported-by: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Mihai Maruseac <mihai.maruseac@gmail.com>
---
Please Jan test following fix, thanks !

 net/ipv6/addrconf.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d7c56f8..0424e4e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3064,14 +3064,15 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq, loff_t pos)
 		struct hlist_node *n;
 		hlist_for_each_entry_rcu_bh(ifa, n, &inet6_addr_lst[state->bucket],
 					 addr_lst) {
+			if (!net_eq(dev_net(ifa->idev->dev), net))
+				continue;
 			/* sync with offset */
 			if (p < state->offset) {
 				p++;
 				continue;
 			}
 			state->offset++;
-			if (net_eq(dev_net(ifa->idev->dev), net))
-				return ifa;
+			return ifa;
 		}
 
 		/* prepare for next bucket */
@@ -3089,18 +3090,20 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 	struct hlist_node *n = &ifa->addr_lst;
 
 	hlist_for_each_entry_continue_rcu_bh(ifa, n, addr_lst) {
+		if (!net_eq(dev_net(ifa->idev->dev), net))
+			continue;
 		state->offset++;
-		if (net_eq(dev_net(ifa->idev->dev), net))
-			return ifa;
+		return ifa;
 	}
 
 	while (++state->bucket < IN6_ADDR_HSIZE) {
 		state->offset = 0;
 		hlist_for_each_entry_rcu_bh(ifa, n,
 				     &inet6_addr_lst[state->bucket], addr_lst) {
+			if (!net_eq(dev_net(ifa->idev->dev), net))
+				continue;
 			state->offset++;
-			if (net_eq(dev_net(ifa->idev->dev), net))
-				return ifa;
+			return ifa;
 		}
 	}
 
