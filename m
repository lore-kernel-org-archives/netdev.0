From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] ipvs: Fix state variable on failure to start ipvs threads
Date: Fri, 8 Jun 2007 15:52:05 -0400
Message-ID: <20070608195205.GA4529@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2694 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbXFHTxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 15:53:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey all-
	ip_vs currently fails to reset its ip_vs_sync_state variable if the sync
thread fails to start properly.  The result is that the kernel will report a
running daemon when their actuall is none.  If you issue the following commands:
1. ipvsadm --start-daemon master --mcast-interface bla
2. ipvsadm -L --daemon
3. ipvsadm --stop-daemon master

Assuming that bla is not an actual interface, step 2 should return no data, but
instead returns:
$ ipvsadm -L --daemon
master sync daemon (mcast=bla, syncid=0)

The following patch corrects this behavior.  Tested successfully by myself

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 ip_vs_sync.c |   41 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 39 insertions(+), 2 deletions(-)



diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 7ea2d98..ff4df68 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -67,6 +67,11 @@ struct ip_vs_sync_conn_options {
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
 };
 
+struct ip_vs_sync_thread_data {
+	struct completion *startup;
+	int state;
+};
+
 #define IP_VS_SYNC_CONN_TIMEOUT (3*60*HZ)
 #define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
 #define FULL_CONN_SIZE  \
@@ -751,6 +756,7 @@ static int sync_thread(void *startup)
 	mm_segment_t oldmm;
 	int state;
 	const char *name;
+	struct ip_vs_sync_thread_data *tinfo = startup;
 
 	/* increase the module use count */
 	ip_vs_use_count_inc();
@@ -789,7 +795,14 @@ static int sync_thread(void *startup)
 	add_wait_queue(&sync_wait, &wait);
 
 	set_sync_pid(state, current->pid);
-	complete((struct completion *)startup);
+	complete(tinfo->startup);
+
+	/*
+	 * once we call the completion queue above, we should
+	 * null out that reference, since its allocated on the
+	 * stack of the creating kernel thread
+	 */
+	tinfo->startup = NULL;
 
 	/* processing master/backup loop here */
 	if (state == IP_VS_STATE_MASTER)
@@ -801,6 +814,14 @@ static int sync_thread(void *startup)
 	remove_wait_queue(&sync_wait, &wait);
 
 	/* thread exits */
+
+	/*
+	 * If we weren't explicitly stopped, then we
+	 * exited in error, and should undo our state
+	 */
+	if ((!stop_master_sync) && (!stop_backup_sync))
+		ip_vs_sync_state -= tinfo->state;
+
 	set_sync_pid(state, 0);
 	IP_VS_INFO("sync thread stopped!\n");
 
@@ -812,6 +833,11 @@ static int sync_thread(void *startup)
 	set_stop_sync(state, 0);
 	wake_up(&stop_sync_wait);
 
+	/*
+	 * we need to free the structure that was allocated 
+	 * for us in start_sync_thread
+	 */
+	kfree(tinfo);
 	return 0;
 }
 
@@ -838,11 +864,19 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 {
 	DECLARE_COMPLETION_ONSTACK(startup);
 	pid_t pid;
+	struct ip_vs_sync_thread_data *tinfo;
 
 	if ((state == IP_VS_STATE_MASTER && sync_master_pid) ||
 	    (state == IP_VS_STATE_BACKUP && sync_backup_pid))
 		return -EEXIST;
 
+	/*
+	 * Note that tinfo will be freed in sync_thread on exit
+	 */
+	tinfo = kmalloc(sizeof(struct ip_vs_sync_thread_data), GFP_KERNEL);
+	if (!tinfo)
+		return -ENOMEM;
+
 	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, current->pid);
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn));
@@ -858,8 +892,11 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 		ip_vs_backup_syncid = syncid;
 	}
 
+	tinfo->state = state;
+	tinfo->startup = &startup;
+
   repeat:
-	if ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
+	if ((pid = kernel_thread(fork_sync_thread, tinfo, 0)) < 0) {
 		IP_VS_ERR("could not create fork_sync_thread due to %d... "
 			  "retrying.\n", pid);
 		msleep_interruptible(1000);
