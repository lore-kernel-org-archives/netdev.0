From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: set out of range ageing time
Date: Mon, 13 Mar 2017 15:19:32 -0400
Message-ID: <20170313191932.12149-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49514 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753860AbdCMTVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 15:21:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The minimum and maximum value of the ATU Age Time varies depending on
the switch model. The current code returns -ERANGE for out-of-range
values, and makes switchdev commit phase fail with this stacktrace:

    # brctl setageing br0 4
    [ 8530.082179] WARNING: CPU: 0 PID: 910 at net/switchdev/switchdev.c:291 switchdev_port_attr_set_now+0xbc/0xc0
    [ 8530.090679] br0: Commit of attribute (id=5) failed.
    [ 8530.094256] Modules linked in:
    [ 8530.096032] CPU: 0 PID: 910 Comm: kworker/0:4 Tainted: G        W       4.10.0 #361
    [ 8530.102412] Hardware name: Freescale Vybrid VF5xx/VF6xx (Device Tree)
    [ 8530.107571] Workqueue: events switchdev_deferred_process_work
    [ 8530.112039] Backtrace:
    [ 8530.113224] [<8010ca34>] (dump_backtrace) from [<8010cd3c>] (show_stack+0x20/0x24)
    [ 8530.119521]  r6:00000000 r5:80834da0 r4:80ca7e48 r3:8120ca3c
    [ 8530.123908] [<8010cd1c>] (show_stack) from [<8037ad40>] (dump_stack+0x24/0x28)
    [ 8530.129873] [<8037ad1c>] (dump_stack) from [<80118de4>] (__warn+0xf4/0x10c)
    [ 8530.135545] [<80118cf0>] (__warn) from [<80118e44>] (warn_slowpath_fmt+0x48/0x50)
    [ 8530.141760]  r9:00000000 r8:81252bec r7:80f19d90 r6:9dc3c000 r5:80ca7e7c r4:80834de8
    [ 8530.148235] [<80118e00>] (warn_slowpath_fmt) from [<80670b20>] (switchdev_port_attr_set_now+0xbc/0xc0)
    [ 8530.156240]  r3:9dc3c000 r2:80834de8
    [ 8530.158539]  r4:ffffffde
    [ 8530.159788] [<80670a64>] (switchdev_port_attr_set_now) from [<80670b44>] (switchdev_port_attr_set_deferred+0x20/0x6c)
    [ 8530.169118]  r7:806705a8 r6:9dc3c000 r5:80f19d90 r4:80f19d80
    [ 8530.173500] [<80670b24>] (switchdev_port_attr_set_deferred) from [<80670580>] (switchdev_deferred_process+0x50/0xe8)
    [ 8530.182742]  r6:80ca6000 r5:81252bec r4:80f19d80 r3:80670b24
    [ 8530.187115] [<80670530>] (switchdev_deferred_process) from [<80670930>] (switchdev_deferred_process_work+0x1c/0x24)
    [ 8530.196277]  r8:00000000 r7:9ffdc100 r6:8120ad6c r5:9ddefc00 r4:81252bf4 r3:9de343c0
    [ 8530.202756] [<80670914>] (switchdev_deferred_process_work) from [<8012f770>] (process_one_work+0x120/0x3b0)
    [ 8530.211231] [<8012f650>] (process_one_work) from [<8012fa70>] (worker_thread+0x70/0x534)
    [ 8530.218046]  r10:9ddefc00 r9:8120ad6c r8:80ca6038 r7:8120ad80 r6:81211f80 r5:9ddefc18
    [ 8530.224579]  r4:8120ad6c
    [ 8530.225830] [<8012fa00>] (worker_thread) from [<80135640>] (kthread+0x114/0x144)
    [ 8530.231955]  r10:9f4e9e94 r9:9de1fe58 r8:8012fa00 r7:9ddefc00 r6:9de1fdc0 r5:00000000
    [ 8530.238497]  r4:9de1fe40
    [ 8530.239750] [<8013552c>] (kthread) from [<80108cd8>] (ret_from_fork+0x14/0x3c)
    [ 8530.245679]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:8013552c
    [ 8530.252234]  r4:9de1fdc0 r3:80ca6000
    [ 8530.254512] ---[ end trace 87475cc71b80ef73 ]---
    [ 8530.257852] br0: failed (err=-34) to set attribute (id=5)

Fix this in the mv88e6xxx driver by limiting the 8-bit AgeTime value to
its minimum or maximum for out-of-range values.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reported-by: Jason Cobham <jcobham@questertangent.com>
---
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 120b7f41a735..f6cd3c939da4 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -49,11 +49,13 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	if (msecs < min || msecs > max)
-		return -ERANGE;
-
 	/* Round to nearest multiple of coeff */
-	age_time = (msecs + coeff / 2) / coeff;
+	if (msecs < min)
+		age_time = 0x1;
+	else if (msecs > max)
+		age_time = 0xff;
+	else
+		age_time = (msecs + coeff / 2) / coeff;
 
 	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
 	if (err)
-- 
2.12.0
