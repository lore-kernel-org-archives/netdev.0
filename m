From: nixiaoming <nixiaoming@huawei.com>
Subject: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Thu, 14 Sep 2017 10:44:41 +0800
Message-ID: <20170914024441.93056-1-nixiaoming@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <nixiaoming@huawei.com>, <dede.wu@huawei.com>
To: <davem@davemloft.net>, <edumazet@google.com>,
        <waltje@uWalt.NL.Mugnet.ORG>, <gw4pts@gw4pts.ampr.org>,
        <andreyknvl@google.com>, <tklauser@distanz.ch>,
        <philip.pettersson@gmail.com>, <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If fanout_add is preempted after running po-> fanout = match
and before running __fanout_link,
it will cause BUG_ON when __unregister_prot_hook call __fanout_unlink

so, we need add mutex_lock(&fanout_mutex) to __unregister_prot_hook
or add spin_lock(&po->bind_lock) before po-> fanout = match

test on linux 4.1.12:
./trinity -c setsockopt -C 2 -X &

BUG: failure at net/packet/af_packet.c:1414/__fanout_unlink()!
Kernel panic - not syncing: BUG!
CPU: 2 PID: 2271 Comm: trinity-c0 Tainted: G        W  O    4.1.12 #1
Hardware name: Hisilicon PhosphorHi1382 FPGA (DT)
Call trace:
[<ffffffc000209414>] dump_backtrace+0x0/0xf8
[<ffffffc00020952c>] show_stack+0x20/0x28
[<ffffffc000635574>] dump_stack+0xac/0xe4
[<ffffffc000633fb8>] panic+0xf8/0x268
[<ffffffc0005fa778>] __unregister_prot_hook+0xa0/0x144
[<ffffffc0005fba48>] packet_set_ring+0x280/0x5b4
[<ffffffc0005fc33c>] packet_setsockopt+0x320/0x950
[<ffffffc000554a04>] SyS_setsockopt+0xa4/0xd4

Signed-off-by: nixiaoming <nixiaoming@huawei.com>
Tested-by: wudesheng <dede.wu@huawei.com>
---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 008a45c..0300146 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -365,10 +365,12 @@ static void __unregister_prot_hook(struct sock *sk, bool sync)
 
 	po->running = 0;
 
+	mutex_lock(&fanout_mutex);
 	if (po->fanout)
 		__fanout_unlink(sk, po);
 	else
 		__dev_remove_pack(&po->prot_hook);
+	mutex_unlock(&fanout_mutex);
 
 	__sock_put(sk);
 
-- 
2.11.0.1
