From: nixiaoming <nixiaoming@huawei.com>
Subject: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Thu, 14 Sep 2017 22:07:22 +0800
Message-ID: <20170914140722.44292-1-nixiaoming@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <nixiaoming@huawei.com>, <dede.wu@huawei.com>
To: <davem@davemloft.net>, <edumazet@google.com>,
        <waltje@uWalt.NL.Mugnet.ORG>, <gw4pts@gw4pts.ampr.org>,
        <andreyknvl@google.com>, <tklauser@distanz.ch>,
        <philip.pettersson@gmail.com>, <glider@google.com>,
        <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: l00219569 <lisimin@huawei.com>

If fanout_add is preempted after running po-> fanout = match
and before running __fanout_link,
it will cause BUG_ON when __unregister_prot_hook call __fanout_unlink

so, we need add mutex_lock(&fanout_mutex) to __unregister_prot_hook
or add spin_lock(&po->bind_lock) before po-> fanout = match

this is a patch for add po->bind_lock in fanout_add

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
 net/packet/af_packet.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 54a18a8..7a52a3b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1446,12 +1446,16 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	default:
 		return -EINVAL;
 	}
-
-	if (!po->running)
+	spin_lock(&po->bind_lock);
+	if (!po->running) {
+		spin_unlock(&po->bind_lock);
 		return -EINVAL;
+	}
 
-	if (po->fanout)
+	if (po->fanout) {
+		spin_unlock(&po->bind_lock);
 		return -EALREADY;
+	}
 
 	mutex_lock(&fanout_mutex);
 	match = NULL;
@@ -1501,6 +1505,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	}
 out:
 	mutex_unlock(&fanout_mutex);
+	spin_unlock(&po->bind_lock);
 	return err;
 }
 
-- 
2.10.1
