From: Ravikiran G Thirumalai <kiran@in.ibm.com>
Subject: [patch] Convert sockets_in_use to use per_cpu areas
Date: Mon, 23 Dec 2002 19:08:48 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021223190847.G23413@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller " <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Here's a simple patch to change sockets_in_use to make use of 
per-cpu areas.  

I have couple of questions though... 
1. Was this var made per-cpu just to avoid  atomic_t or locking 
   or are there real life workloads which cause too many sock_alloc
   and sock_releases to cause cacheline bouncing?
2. Is this var required? since we can just sum up all proto->stats.inuse 
   and remove this var altogether? (This var is read only for /proc 
   reporting)

Thanks,
Kiran


diff -ruN -X dontdiff linux-2.5.52/net/socket.c sockets_in_use-2.5.52/net/socket.c
--- linux-2.5.52/net/socket.c	Mon Dec 16 07:37:53 2002
+++ sockets_in_use-2.5.52/net/socket.c	Mon Dec 23 11:48:44 2002
@@ -189,10 +189,7 @@
  *	Statistics counters of the socket lists
  */
 
-static union {
-	int	counter;
-	char	__pad[SMP_CACHE_BYTES];
-} sockets_in_use[NR_CPUS] __cacheline_aligned = {{0}};
+static DEFINE_PER_CPU(int, sockets_in_use);
 
 /*
  *	Support routines. Move socket addresses back and forth across the kernel/user
@@ -475,7 +472,8 @@
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
 
-	sockets_in_use[smp_processor_id()].counter++;
+	get_cpu_var(sockets_in_use)++;
+	put_cpu_var(sockets_in_use);
 	return sock;
 }
 
@@ -511,7 +509,8 @@
 	if (sock->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
-	sockets_in_use[smp_processor_id()].counter--;
+	get_cpu_var(sockets_in_use)--;
+	put_cpu_var(sockets_in_use);
 	if (!sock->file) {
 		iput(SOCK_INODE(sock));
 		return;
@@ -1851,7 +1850,7 @@
 	int counter = 0;
 
 	for (cpu = 0; cpu < NR_CPUS; cpu++)
-		counter += sockets_in_use[cpu].counter;
+		counter += per_cpu(sockets_in_use, cpu);
 
 	/* It can be negative, by the way. 8) */
 	if (counter < 0)
