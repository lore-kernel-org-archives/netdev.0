From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: fix double request socket freeing
Date: Mon, 23 Mar 2015 10:06:29 -0700
Message-ID: <1427130389.25985.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150323090317.GB8934@haze> <550FEA98.3040009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34192 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbCWRGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:06:32 -0400
Received: by iedfl3 with SMTP id fl3so46919391ied.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 10:06:31 -0700 (PDT)
In-Reply-To: <550FEA98.3040009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>

Eric Hugne reported following error :

I'm hitting this warning on latest net-next when i try to SSH into a machine
with eth0 added to a bridge (but i think the problem is older than that)

Steps to reproduce:
node2 ~ # brctl addif br0 eth0
[  223.758785] device eth0 entered promiscuous mode
node2 ~ # ip link set br0 up
[  244.503614] br0: port 1(eth0) entered forwarding state
[  244.505108] br0: port 1(eth0) entered forwarding state
node2 ~ # [  251.160159] ------------[ cut here ]------------
[  251.160831] WARNING: CPU: 0 PID: 3 at include/net/request_sock.h:102 tcp_v4_err+0x6b1/0x720()
[  251.162077] Modules linked in:
[  251.162496] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 4.0.0-rc3+ #18
[  251.163334] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  251.164078]  ffffffff81a8365c ffff880038a6ba18 ffffffff8162ace4 0000000000009898
[  251.165084]  0000000000000000 ffff880038a6ba58 ffffffff8104da85 ffff88003fa437c0
[  251.166195]  ffff88003fa437c0 ffff88003fa74e00 ffff88003fa43bb8 ffff88003fad99a0
[  251.167203] Call Trace:
[  251.167533]  [<ffffffff8162ace4>] dump_stack+0x45/0x57
[  251.168206]  [<ffffffff8104da85>] warn_slowpath_common+0x85/0xc0
[  251.169239]  [<ffffffff8104db65>] warn_slowpath_null+0x15/0x20
[  251.170271]  [<ffffffff81559d51>] tcp_v4_err+0x6b1/0x720
[  251.171408]  [<ffffffff81630d03>] ? _raw_read_lock_irq+0x3/0x10
[  251.172589]  [<ffffffff81534e20>] ? inet_del_offload+0x40/0x40
[  251.173366]  [<ffffffff81569295>] icmp_socket_deliver+0x65/0xb0
[  251.174134]  [<ffffffff815693a2>] icmp_unreach+0xc2/0x280
[  251.174820]  [<ffffffff8156a82d>] icmp_rcv+0x2bd/0x3a0
[  251.175473]  [<ffffffff81534ea2>] ip_local_deliver_finish+0x82/0x1e0
[  251.176282]  [<ffffffff815354d8>] ip_local_deliver+0x88/0x90
[  251.177004]  [<ffffffff815350f0>] ip_rcv_finish+0xf0/0x310
[  251.177693]  [<ffffffff815357bc>] ip_rcv+0x2dc/0x390
[  251.178336]  [<ffffffff814f5da3>] __netif_receive_skb_core+0x713/0xa20
[  251.179170]  [<ffffffff814f7fca>] __netif_receive_skb+0x1a/0x80
[  251.179922]  [<ffffffff814f97d4>] process_backlog+0x94/0x120
[  251.180639]  [<ffffffff814f9612>] net_rx_action+0x1e2/0x310
[  251.181356]  [<ffffffff81051267>] __do_softirq+0xa7/0x290
[  251.182046]  [<ffffffff81051469>] run_ksoftirqd+0x19/0x30
[  251.182726]  [<ffffffff8106cc23>] smpboot_thread_fn+0x153/0x1d0
[  251.183485]  [<ffffffff8106cad0>] ? SyS_setgroups+0x130/0x130
[  251.184228]  [<ffffffff8106935e>] kthread+0xee/0x110
[  251.184871]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0/0x1b0
[  251.185690]  [<ffffffff81631108>] ret_from_fork+0x58/0x90
[  251.186385]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0/0x1b0
[  251.187216] ---[ end trace c947fc7b24e42ea1 ]---
[  259.542268] br0: port 1(eth0) entered forwarding state

Remove the double calls to reqsk_put()

[edumazet] :

I got confused because reqsk_timer_handler() _has_ to call
reqsk_put(req) after calling inet_csk_reqsk_queue_drop(), as
the timer handler holds a reference on req.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
---
 net/dccp/ipv4.c     |    1 -
 net/dccp/ipv6.c     |    1 -
 net/ipv4/tcp_ipv4.c |    1 -
 net/ipv6/tcp_ipv6.c |    1 -
 4 files changed, 4 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 25a9615b3b88993208a1e73f312103646c2d557f..fd805c08a8dcaeed01ffb0f951a8205141d0788c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -316,7 +316,6 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		 * errors returned from accept().
 		 */
 		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
 		goto out;
 
 	case DCCP_REQUESTING:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 69d8f13895bac406a275ecd6ece4334c8d1ebb95..5137ab387d292c3ec221489381fe59b80fc931ff 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -174,7 +174,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 
 		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
 		goto out;
 
 	case DCCP_REQUESTING:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5554b8f33d41b43dc4ccf3b95322e362bbe3844a..b1eaf3d56d09f97fe118b08a7d04c96ed2f812b5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -487,7 +487,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 */
 		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-		reqsk_put(req);
 		goto out;
 
 	case TCP_SYN_SENT:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6e3f90db038cb001dad5c4dddef88d93ecdbf5f3..1d551faec4e0a346c390de13ba6b71bf7e930a73 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -427,7 +427,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-		reqsk_put(req);
 		goto out;
 
 	case TCP_SYN_SENT:
