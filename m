From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Mon, 28 Aug 2017 13:23:09 -0700
Message-ID: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, bhumirks@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38668 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1UXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 16:23:14 -0400
Received: by mail-pf0-f194.google.com with SMTP id r187so952880pfr.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 13:23:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit aa8db499ea67cff1f5f049033810ffede2fe5ae4.

Early demux structs can not be made const. Doing so results in:
[   84.967355] BUG: unable to handle kernel paging request at ffffffff81684b10
[   84.969272] IP: proc_configure_early_demux+0x1e/0x3d
[   84.970544] PGD 1a0a067
[   84.970546] P4D 1a0a067
[   84.971212] PUD 1a0b063
[   84.971733] PMD 80000000016001e1

[   84.972669] Oops: 0003 [#1] SMP
[   84.973065] Modules linked in: ip6table_filter ip6_tables veth vrf
[   84.973833] CPU: 0 PID: 955 Comm: sysctl Not tainted 4.13.0-rc6+ #22
[   84.974612] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   84.975855] task: ffff88003854ce00 task.stack: ffffc900005a4000
[   84.976580] RIP: 0010:proc_configure_early_demux+0x1e/0x3d
[   84.977253] RSP: 0018:ffffc900005a7dd0 EFLAGS: 00010246
[   84.977891] RAX: ffffffff81684b10 RBX: 0000000000000001 RCX: 0000000000000000
[   84.978759] RDX: 0000000000000000 RSI: 0000000000000006 RDI: 0000000000000000
[   84.979628] RBP: ffffc900005a7dd0 R08: 0000000000000000 R09: 0000000000000000
[   84.980501] R10: 0000000000000001 R11: 0000000000000008 R12: 0000000000000001
[   84.981373] R13: ffffffffffffffea R14: ffffffff81a9b4c0 R15: 0000000000000002
[   84.982249] FS:  00007feb237b7700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[   84.983231] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   84.983941] CR2: ffffffff81684b10 CR3: 0000000038492000 CR4: 00000000000406f0
[   84.984817] Call Trace:
[   84.985133]  proc_tcp_early_demux+0x29/0x30

I think this is the second time such a patch has been reverted.

Cc: Bhumika Goyal <bhumirks@gmail.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
Bhumika: How are you testing these constify changes? In this case a simple
sysctl -w net.ipv4.tcp_early_demux=1 would have shown the problem

 net/ipv4/af_inet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 19aee073ba29..d678820e4306 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1596,7 +1596,7 @@ static const struct net_protocol igmp_protocol = {
 };
 #endif
 
-static const struct net_protocol tcp_protocol = {
+static struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.early_demux_handler =  tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
@@ -1606,7 +1606,7 @@ static const struct net_protocol tcp_protocol = {
 	.icmp_strict_tag_validation = 1,
 };
 
-static const struct net_protocol udp_protocol = {
+static struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.early_demux_handler =	udp_v4_early_demux,
 	.handler =	udp_rcv,
-- 
2.1.4
