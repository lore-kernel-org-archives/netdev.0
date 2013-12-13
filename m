From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux-3.10.y] ip6tnl: fix use after free of fb_tnl_dev
Date: Fri, 13 Dec 2013 10:06:35 +0100
Message-ID: <1386925595-4995-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20131212.153545.1184197791301496227.davem@davemloft.net>
Cc: gregkh@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	williams@redhat.com, linux-rt-users@vger.kernel.org,
	lclaudio@uudg.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131212.153545.1184197791301496227.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The upstream commit bb8140947a24 ("ip6tnl: allow to use rtnl ops on fb tunnel")
(backported into linux-3.10.y) left a bug which was fixed upstream by commit
1e9f3d6f1c40 ("ip6tnl: fix use after free of fb_tnl_dev").

The problem is a bit different in linux-3.10.y, because there is no x-netns
support (upstream commit 0bd8762824e7 ("ip6tnl: add x-netns support")).
When ip6_tunnel.ko is unloaded, FB device is deleted by rtnl_link_unregister()
and then we try to delete it again in ip6_tnl_destroy_tunnels().

This patch removes the second deletion.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0516ebbea80b..209bb4d6e188 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1711,8 +1711,6 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 		}
 	}
 
-	t = rtnl_dereference(ip6n->tnls_wc[0]);
-	unregister_netdevice_queue(t->dev, &list);
 	unregister_netdevice_many(&list);
 }
 
-- 
1.8.4.1
