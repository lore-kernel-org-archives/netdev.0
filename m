From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] udp: Resolve NULL pointer dereference
Date: Wed, 11 May 2016 19:24:06 -0700
Message-ID: <20160512022306.3691.40769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36132 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbcELCYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 22:24:08 -0400
Received: by mail-pa0-f49.google.com with SMTP id bt5so23665811pac.3
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 19:24:07 -0700 (PDT)
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

I believe the trace is pointing to the call to dev_net(dev) in
udp4_lib_lookup_skb.  If I am not mistaken I believe it is possible for us
to have skb_dst(skb)->dev be NULL.  So to resolve that I am adding a check
for this case and skipping the assignment if such an event occurs.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/udp.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f67f52ba4809..ff8d9ff3048b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -613,8 +613,12 @@ struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	const struct net_device *dev =
-	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
+	const struct net_device *dev;
+
+	if (skb_dst(skb) && skb_dst(skb)->dev)
+		dev = skb_dst(skb)->dev;
+	else
+		dev = skb->dev;
 
 	return __udp4_lib_lookup(dev_net(dev), iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
