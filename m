From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] SCTP: port randomization
Date: Wed, 10 Oct 2007 17:00:21 -0700
Message-ID: <20071011000042.624753621@linux-foundation.org>
References: <20071011000020.907277335@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36209 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755154AbXJKAET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 20:04:19 -0400
Content-Disposition: inline; filename=sctp-port-random.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add port randomization rather than a simple fixed rover
for use with SCTP.  This makes it act similar to TCP, UDP, DCCP
when allocating ports.

No longer need port_alloc_lock as well (suggestion by Brian Haley).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 include/net/sctp/structs.h |    2 --
 net/sctp/protocol.c        |    3 ---
 net/sctp/socket.c          |   21 +++++----------------
 3 files changed, 5 insertions(+), 21 deletions(-)

--- a/include/net/sctp/structs.h	2007-10-10 08:26:57.000000000 -0700
+++ b/include/net/sctp/structs.h	2007-10-10 14:57:28.000000000 -0700
@@ -197,8 +197,6 @@ extern struct sctp_globals {
 
 	/* This is the sctp port control hash.	*/
 	int port_hashsize;
-	int port_rover;
-	spinlock_t port_alloc_lock;  /* Protects port_rover. */
 	struct sctp_bind_hashbucket *port_hashtable;
 
 	/* This is the global local address list.
--- a/net/sctp/protocol.c	2007-10-10 14:51:03.000000000 -0700
+++ b/net/sctp/protocol.c	2007-10-10 14:53:13.000000000 -0700
@@ -1172,9 +1172,6 @@ SCTP_STATIC __init int sctp_init(void)
 		sctp_port_hashtable[i].chain = NULL;
 	}
 
-	spin_lock_init(&sctp_port_alloc_lock);
-	sctp_port_rover = sysctl_local_port_range[0] - 1;
-
 	printk(KERN_INFO "SCTP: Hash tables configured "
 			 "(established %d bind %d)\n",
 		sctp_assoc_hashsize, sctp_port_hashsize);
--- a/net/sctp/socket.c	2007-10-10 14:51:03.000000000 -0700
+++ b/net/sctp/socket.c	2007-10-10 14:55:22.000000000 -0700
@@ -5314,22 +5314,13 @@ static long sctp_get_port_local(struct s
 	sctp_local_bh_disable();
 
 	if (snum == 0) {
-		/* Search for an available port.
-		 *
-		 * 'sctp_port_rover' was the last port assigned, so
-		 * we start to search from 'sctp_port_rover +
-		 * 1'. What we do is first check if port 'rover' is
-		 * already in the hash table; if not, we use that; if
-		 * it is, we try next.
-		 */
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int remaining = (high - low) + 1;
-		int rover;
+		/* Search for an available port. */
+		unsigned int low = sysctl_local_port_range[0];
+		unsigned int high = sysctl_local_port_range[1];
+		unsigned int remaining = (high - low) + 1;
+		unsigned int rover = net_random() % remaining + low;
 		int index;
 
-		sctp_spin_lock(&sctp_port_alloc_lock);
-		rover = sctp_port_rover;
 		do {
 			rover++;
 			if ((rover < low) || (rover > high))
@@ -5344,8 +5335,6 @@ static long sctp_get_port_local(struct s
 		next:
 			sctp_spin_unlock(&head->lock);
 		} while (--remaining > 0);
-		sctp_port_rover = rover;
-		sctp_spin_unlock(&sctp_port_alloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

