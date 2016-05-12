From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Thu, 12 May 2016 16:23:44 -0700
Message-ID: <20160512232203.12606.41050.stgit@localhost.localdomain>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, tom@herbertland.com, jbenc@redhat.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33068 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbcELXXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 19:23:47 -0400
Received: by mail-pa0-f41.google.com with SMTP id xk12so34276086pac.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 16:23:46 -0700 (PDT)
In-Reply-To: <20160512022306.3691.40769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing an OpenStack configuration using VXLANs I saw the following
call trace:

 RIP: 0010:[<ffffffff815fad49>] udp4_lib_lookup_skb+0x49/0x80
 RSP: 0018:ffff88103867bc50  EFLAGS: 00010286
 RAX: ffff88103269bf00 RBX: ffff88103269bf00 RCX: 00000000ffffffff
 RDX: 0000000000004300 RSI: 0000000000000000 RDI: ffff880f2932e780
 RBP: ffff88103867bc60 R08: 0000000000000000 R09: 000000009001a8c0
 R10: 0000000000004400 R11: ffffffff81333a58 R12: ffff880f2932e794
 R13: 0000000000000014 R14: 0000000000000014 R15: ffffe8efbfd89ca0
 FS:  0000000000000000(0000) GS:ffff88103fd80000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 0000000000000488 CR3: 0000000001c06000 CR4: 00000000001426e0
 Stack:
  ffffffff81576515 ffffffff815733c0 ffff88103867bc98 ffffffff815fcc17
  ffff88103269bf00 ffffe8efbfd89ca0 0000000000000014 0000000000000080
  ffffe8efbfd89ca0 ffff88103867bcc8 ffffffff815fcf8b ffff880f2932e794
 Call Trace:
  [<ffffffff81576515>] ? skb_checksum+0x35/0x50
  [<ffffffff815733c0>] ? skb_push+0x40/0x40
  [<ffffffff815fcc17>] udp_gro_receive+0x57/0x130
  [<ffffffff815fcf8b>] udp4_gro_receive+0x10b/0x2c0
  [<ffffffff81605863>] inet_gro_receive+0x1d3/0x270
  [<ffffffff81589e59>] dev_gro_receive+0x269/0x3b0
  [<ffffffff8158a1b8>] napi_gro_receive+0x38/0x120
  [<ffffffffa0871297>] gro_cell_poll+0x57/0x80 [vxlan]
  [<ffffffff815899d0>] net_rx_action+0x160/0x380
  [<ffffffff816965c7>] __do_softirq+0xd7/0x2c5
  [<ffffffff8107d969>] run_ksoftirqd+0x29/0x50
  [<ffffffff8109a50f>] smpboot_thread_fn+0x10f/0x160
  [<ffffffff8109a400>] ? sort_range+0x30/0x30
  [<ffffffff81096da8>] kthread+0xd8/0xf0
  [<ffffffff81693c82>] ret_from_fork+0x22/0x40
  [<ffffffff81096cd0>] ? kthread_park+0x60/0x60

The following trace is seen when receiving a DHCP request over a flow-based
VXLAN tunnel.  I believe this is caused by the metadata dst having a NULL
dev value and as a result dev_net(dev) is causing a NULL pointer dereference.

To resolve this I am replacing the check for skb_dst(skb)->dev with just
skb->dev.  This makes sense as the callers of this function are usually in
the receive path and as such skb->dev should always be populated.  In
addition other functions in the area where these are called are already
using dev_net(skb->dev) to determine the namespace the UDP packet belongs
in.

Fixes: 63058308cd55 ("udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: Replaced skb_dst(skb)->dev == NULL test with skb_valid_dst(skb).
    Added update for IPv6 as well since issue would affect both.
v3: Dropped use of skb_dst(skb) entirely and instead just used skb->dev.

 net/ipv4/udp.c |   10 ++--------
 net/ipv6/udp.c |    8 +++-----
 2 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f67f52ba4809..2e3ebfe5549e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -604,7 +604,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 
-	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
+	return __udp4_lib_lookup(dev_net(skb->dev), iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
 				 udptable, skb);
 }
@@ -612,13 +612,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct net_device *dev =
-	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
-
-	return __udp4_lib_lookup(dev_net(dev), iph->saddr, sport,
-				 iph->daddr, dport, inet_iif(skb),
-				 &udp_table, skb);
+	return __udp4_lib_lookup_skb(skb, sport, dport, &udp_table);
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index aca06094110f..2ba6a77a8815 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -315,13 +315,13 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 					  __be16 sport, __be16 dport,
 					  struct udp_table *udptable)
 {
-	struct sock *sk;
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct sock *sk;
 
 	sk = skb_steal_sock(skb);
 	if (unlikely(sk))
 		return sk;
-	return __udp6_lib_lookup(dev_net(skb_dst(skb)->dev), &iph->saddr, sport,
+	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
 				 udptable, skb);
 }
@@ -330,10 +330,8 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	const struct net_device *dev =
-	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
 
-	return __udp6_lib_lookup(dev_net(dev), &iph->saddr, sport,
+	return __udp6_lib_lookup(dev_net(skb->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
 				 &udp_table, skb);
 }
