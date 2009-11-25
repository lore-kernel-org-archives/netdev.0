From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: NUMA aware
Date: Wed, 25 Nov 2009 16:01:02 +0100
Message-ID: <4B0D46AE.3070700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38236 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbZKYPBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 10:01:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now my Nehalem dev machine is truly NUMA, time for new patches :)

David, this applies on last pktgen version (after last patches you added in net-2.6).

Thanks

[PATCH net-next-2.6] pktgen: NUMA aware

pktgen threads are bound to given CPU, we can allocate memory for
these threads in a NUMA aware way.

After a pktgen session on two threads, we can check flows memory was
allocated on right node, instead of a not related one.

# grep pktgen_thread_write /proc/vmallocinfo 
0xffffc90007204000-0xffffc90007385000 1576960 pktgen_thread_write+0x3a4/0x6b0 [pktgen] pages=384 vmalloc N0=384
0xffffc90007386000-0xffffc90007507000 1576960 pktgen_thread_write+0x3a4/0x6b0 [pktgen] pages=384 vmalloc N1=384

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6e79e96..f4f4c50 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3622,6 +3622,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 {
 	struct pktgen_dev *pkt_dev;
 	int err;
+	int node = cpu_to_node(t->cpu);
 
 	/* We don't allow a device to be on several threads */
 
@@ -3631,12 +3632,13 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		return -EBUSY;
 	}
 
-	pkt_dev = kzalloc(sizeof(struct pktgen_dev), GFP_KERNEL);
+	pkt_dev = kzalloc_node(sizeof(struct pktgen_dev), GFP_KERNEL, node);
 	if (!pkt_dev)
 		return -ENOMEM;
 
 	strcpy(pkt_dev->odevname, ifname);
-	pkt_dev->flows = vmalloc(MAX_CFLOWS * sizeof(struct flow_state));
+	pkt_dev->flows = vmalloc_node(MAX_CFLOWS * sizeof(struct flow_state),
+				      node);
 	if (pkt_dev->flows == NULL) {
 		kfree(pkt_dev);
 		return -ENOMEM;
@@ -3698,7 +3700,8 @@ static int __init pktgen_create_thread(int cpu)
 	struct proc_dir_entry *pe;
 	struct task_struct *p;
 
-	t = kzalloc(sizeof(struct pktgen_thread), GFP_KERNEL);
+	t = kzalloc_node(sizeof(struct pktgen_thread), GFP_KERNEL,
+			 cpu_to_node(cpu));
 	if (!t) {
 		printk(KERN_ERR "pktgen: ERROR: out of memory, can't "
 		       "create new thread.\n");
