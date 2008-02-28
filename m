From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 09/15] [PKTGEN]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:57:18 +0800
Message-ID: <47C6938E.8010006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61412 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbYB1K7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:59:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/core/pktgen.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index bfcdfae..20e63b3 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3570,14 +3570,14 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	if (err)
 		goto out1;
 
-	pkt_dev->entry = create_proc_entry(ifname, 0600, pg_proc_dir);
+	pkt_dev->entry = proc_create(ifname, 0600,
+				     pg_proc_dir, &pktgen_if_fops);
 	if (!pkt_dev->entry) {
 		printk(KERN_ERR "pktgen: cannot create %s/%s procfs entry.\n",
 		       PG_PROC_DIR, ifname);
 		err = -EINVAL;
 		goto out2;
 	}
-	pkt_dev->entry->proc_fops = &pktgen_if_fops;
 	pkt_dev->entry->data = pkt_dev;
 #ifdef CONFIG_XFRM
 	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;
@@ -3628,7 +3628,7 @@ static int __init pktgen_create_thread(int cpu)
 	kthread_bind(p, cpu);
 	t->tsk = p;
 
-	pe = create_proc_entry(t->tsk->comm, 0600, pg_proc_dir);
+	pe = proc_create(t->tsk->comm, 0600, pg_proc_dir, &pktgen_thread_fops);
 	if (!pe) {
 		printk(KERN_ERR "pktgen: cannot create %s/%s procfs entry.\n",
 		       PG_PROC_DIR, t->tsk->comm);
@@ -3638,7 +3638,6 @@ static int __init pktgen_create_thread(int cpu)
 		return -EINVAL;
 	}
 
-	pe->proc_fops = &pktgen_thread_fops;
 	pe->data = t;
 
 	wake_up_process(p);
@@ -3709,7 +3708,7 @@ static int __init pg_init(void)
 		return -ENODEV;
 	pg_proc_dir->owner = THIS_MODULE;
 
-	pe = create_proc_entry(PGCTRL, 0600, pg_proc_dir);
+	pe = proc_create(PGCTRL, 0600, pg_proc_dir, &pktgen_fops);
 	if (pe == NULL) {
 		printk(KERN_ERR "pktgen: ERROR: cannot create %s "
 		       "procfs entry.\n", PGCTRL);
@@ -3717,7 +3716,6 @@ static int __init pg_init(void)
 		return -EINVAL;
 	}
 
-	pe->proc_fops = &pktgen_fops;
 	pe->data = NULL;
 
 	/* Register us to receive netdevice events */
-- 
WCN


