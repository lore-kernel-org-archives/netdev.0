From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: fix tunnels in netns after ndo_ changes
Date: Sun, 23 Nov 2008 16:43:00 +0300
Message-ID: <20081123134300.GA470@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:48391 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756292AbYKWNjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 08:39:10 -0500
Received: by ey-out-2122.google.com with SMTP id 6so671134eyi.37
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 05:39:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_net_set() should be the very first thing after alloc_netdev().

"ndo_" changes turned simple assignment (which is OK to do before netns
assignment) into quite non-trivial operation (which is not OK, init_net was
used). This leads to incomplete initialisation of tunnel device in netns.

BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c02efdb5>] ip6_tnl_exit_net+0x37/0x4f
*pde = 00000000 
Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/class/net/lo/operstate

Pid: 10, comm: netns Not tainted (2.6.28-rc6 #1) 
EIP: 0060:[<c02efdb5>] EFLAGS: 00010246 CPU: 0
EIP is at ip6_tnl_exit_net+0x37/0x4f
EAX: 00000000 EBX: 00000020 ECX: 00000000 EDX: 00000003
ESI: c5caef30 EDI: c782bbe8 EBP: c7909f50 ESP: c7909f48
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process netns (pid: 10, ti=c7908000 task=c7905780 task.ti=c7908000)
Stack:
 c03e75e0 c7390bc8 c7909f60 c0245448 c7390bd8 c7390bf0 c7909fa8 c012577a
 00000000 00000002 00000000 c0125736 c782bbe8 c7909f90 c0308fe3 c782bc04
 c7390bd4 c0245406 c084b718 c04f0770 c03ad785 c782bbe8 c782bc04 c782bc0c
Call Trace:
 [<c0245448>] ? cleanup_net+0x42/0x82
 [<c012577a>] ? run_workqueue+0xd6/0x1ae
 [<c0125736>] ? run_workqueue+0x92/0x1ae
 [<c0308fe3>] ? schedule+0x275/0x285
 [<c0245406>] ? cleanup_net+0x0/0x82
 [<c0125ae1>] ? worker_thread+0x81/0x8d
 [<c0128344>] ? autoremove_wake_function+0x0/0x33
 [<c0125a60>] ? worker_thread+0x0/0x8d
 [<c012815c>] ? kthread+0x39/0x5e
 [<c0128123>] ? kthread+0x0/0x5e
 [<c0103b9f>] ? kernel_thread_helper+0x7/0x10
Code: db e8 05 ff ff ff 89 c6 e8 dc 04 f6 ff eb 08 8b 40 04 e8 38 89 f5 ff 8b 44 9e 04 85 c0 75 f0 43 83 fb 20 75 f2 8b 86 84 00 00 00 <8b> 40 04 e8 1c 89 f5 ff e8 98 04 f6 ff 89 f0 e8 f8 63 e6 ff 5b 
EIP: [<c02efdb5>] ip6_tnl_exit_net+0x37/0x4f SS:ESP 0068:c7909f48
---[ end trace 6c2f2328fccd3e0c ]---

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ip_gre.c     |    2 +-
 net/ipv4/ipip.c       |    2 +-
 net/ipv6/ip6_tunnel.c |    2 +-
 net/ipv6/sit.c        |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1268,9 +1268,9 @@ static int ipgre_init_net(struct net *net)
 		err = -ENOMEM;
 		goto err_alloc_dev;
 	}
+	dev_net_set(ign->fb_tunnel_dev, net);
 
 	ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
-	dev_net_set(ign->fb_tunnel_dev, net);
 	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
 
 	if ((err = register_netdev(ign->fb_tunnel_dev)))
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -793,9 +793,9 @@ static int ipip_init_net(struct net *net)
 		err = -ENOMEM;
 		goto err_alloc_dev;
 	}
+	dev_net_set(ipn->fb_tunnel_dev, net);
 
 	ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
-	dev_net_set(ipn->fb_tunnel_dev, net);
 
 	if ((err = register_netdev(ipn->fb_tunnel_dev)))
 		goto err_reg_dev;
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1428,9 +1428,9 @@ static int ip6_tnl_init_net(struct net *net)
 
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
+	dev_net_set(ip6n->fb_tnl_dev, net);
 
 	ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
-	dev_net_set(ip6n->fb_tnl_dev, net);
 
 	err = register_netdev(ip6n->fb_tnl_dev);
 	if (err < 0)
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1025,9 +1025,9 @@ static int sit_init_net(struct net *net)
 		err = -ENOMEM;
 		goto err_alloc_dev;
 	}
+	dev_net_set(sitn->fb_tunnel_dev, net);
 
 	ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
-	dev_net_set(sitn->fb_tunnel_dev, net);
 
 	if ((err = register_netdev(sitn->fb_tunnel_dev)))
 		goto err_reg_dev;
