From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 2/2] dlci: validate the net device in dlci_del()
Date: Wed, 26 Jun 2013 15:31:58 +0800
Message-ID: <51CA98EE.4050801@huawei.com>
References: <51CA9872.5050700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<trinity@vger.kernel.org>, Li Jinyue <lijinyue@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <51CA9872.5050700@huawei.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We triggered an oops while running trinity with 3.4 kernel:

BUG: unable to handle kernel paging request at 0000000100000d07
IP: [<ffffffffa0109738>] dlci_ioctl+0xd8/0x2d4 [dlci]
PGD 640c0d067 PUD 0
Oops: 0000 [#1] PREEMPT SMP
CPU 3
...
Pid: 7302, comm: trinity-child3 Not tainted 3.4.24.09+ 40 Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA
RIP: 0010:[<ffffffffa0109738>]  [<ffffffffa0109738>] dlci_ioctl+0xd8/0x2d4 [dlci]
...
Call Trace:
  [<ffffffff8137c5c3>] sock_ioctl+0x153/0x280
  [<ffffffff81195494>] do_vfs_ioctl+0xa4/0x5e0
  [<ffffffff8118354a>] ? fget_light+0x3ea/0x490
  [<ffffffff81195a1f>] sys_ioctl+0x4f/0x80
  [<ffffffff81478b69>] system_call_fastpath+0x16/0x1b
...

It's because the net device is not a dlci device.

Reported-by: Li Jinyue <lijinyue@huawei.com>
Signed-off-by: Li Zefan <lizefan@huawei.com>
Cc: stable@vger.kernel.org
---
 drivers/net/wan/dlci.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 1f6e053..6a8a382 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -384,6 +384,7 @@ static int dlci_del(struct dlci_add *dlci)
 	struct frad_local	*flp;
 	struct net_device	*master, *slave;
 	int			err;
+	bool			found = false;
 
 	rtnl_lock();
 
@@ -394,6 +395,17 @@ static int dlci_del(struct dlci_add *dlci)
 		goto out;
 	}
 
+	list_for_each_entry(dlp, &dlci_devs, list) {
+		if (dlp->master == master) {
+			found = true;
+			break;
+		}
+	}
+	if (!found) {
+		err = -ENODEV;
+		goto out;
+	}
+
 	if (netif_running(master)) {
 		err = -EBUSY;
 		goto out;
-- 
1.8.0.2
