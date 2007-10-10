From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] more robust inet range checking
Date: Wed, 10 Oct 2007 15:24:20 -0400
Message-ID: <470D26E4.2050708@hp.com>
References: <20071010141530.GA10661@iris.sw.ru> <20071010100939.0783febb@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030702020500020208090801"
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	aarapov@redhat.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:41279 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbXJJTYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 15:24:23 -0400
In-Reply-To: <20071010100939.0783febb@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030702020500020208090801
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
>  int inet_csk_bind_conflict(const struct sock *sk,
>  			   const struct inet_bind_bucket *tb)
> @@ -77,10 +90,11 @@ int inet_csk_get_port(struct inet_hashin
>  
>  	local_bh_disable();
>  	if (!snum) {
> -		int low = sysctl_local_port_range[0];
> -		int high = sysctl_local_port_range[1];
> -		int remaining = (high - low) + 1;
> -		int rover = net_random() % (high - low) + low;
> +		int remaining, range[2], rover;
> +
> +		inet_get_local_port_range(range);
> +		remaining = range[1] - range[0];
> +		rover = net_random() % (range[1] - range[0]) + range[0];

nit-pick:
		rover = net_random() % remaining + range[0];

> --- a/net/ipv4/udp.c	2007-10-10 08:27:00.000000000 -0700
> +++ b/net/ipv4/udp.c	2007-10-10 09:44:35.000000000 -0700
> @@ -147,13 +147,13 @@ int __udp_lib_get_port(struct sock *sk, 
>  	write_lock_bh(&udp_hash_lock);
>  
>  	if (!snum) {
> -		int i;
> -		int low = sysctl_local_port_range[0];
> -		int high = sysctl_local_port_range[1];
> +		int i, range[2];
>  		unsigned rover, best, best_size_so_far;

Should these be signed ints?  They're the only ones that are unsigned, 
but I don't know why.

> --- a/net/sctp/protocol.c	2007-10-10 08:27:00.000000000 -0700
> +++ b/net/sctp/protocol.c	2007-10-10 09:58:21.000000000 -0700
> @@ -1173,7 +1173,6 @@ SCTP_STATIC __init int sctp_init(void)
>  	}
>  
>  	spin_lock_init(&sctp_port_alloc_lock);
> -	sctp_port_rover = sysctl_local_port_range[0] - 1;

I think you can remove the port_rover definition in sctp/structs.h and 
also the lock that protects it.  Patch below for that which can be 
applied on-top of yours.

-Brian


Remove SCTP port_rover and port_alloc_lock as they're no longer required.

Signed-off-by: Brian Haley <brian.haley@hp.com>


--------------030702020500020208090801
Content-Type: text/x-patch;
 name="sctp.port_rover_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp.port_rover_cleanup.patch"

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 448f713..c1a083c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -197,8 +197,6 @@ extern struct sctp_globals {
 
 	/* This is the sctp port control hash.	*/
 	int port_hashsize;
-	int port_rover;
-	spinlock_t port_alloc_lock;  /* Protects port_rover. */
 	struct sctp_bind_hashbucket *port_hashtable;
 
 	/* This is the global local address list.
@@ -245,8 +243,6 @@ extern struct sctp_globals {
 #define sctp_assoc_hashsize		(sctp_globals.assoc_hashsize)
 #define sctp_assoc_hashtable		(sctp_globals.assoc_hashtable)
 #define sctp_port_hashsize		(sctp_globals.port_hashsize)
-#define sctp_port_rover			(sctp_globals.port_rover)
-#define sctp_port_alloc_lock		(sctp_globals.port_alloc_lock)
 #define sctp_port_hashtable		(sctp_globals.port_hashtable)
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
 #define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 80df457..81b26c5 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1172,8 +1172,6 @@ SCTP_STATIC __init int sctp_init(void)
 		sctp_port_hashtable[i].chain = NULL;
 	}
 
-	spin_lock_init(&sctp_port_alloc_lock);
-
 	printk(KERN_INFO "SCTP: Hash tables configured "
 			 "(established %d bind %d)\n",
 		sctp_assoc_hashsize, sctp_port_hashsize);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e1e2d2c..293200d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5321,7 +5321,6 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		remaining = range[1] - range[0];
 		rover = net_random() % remaining + range[0];
 
-		sctp_spin_lock(&sctp_port_alloc_lock);
 		do {
 			rover++;
 			if ((rover < range[0]) || (rover > range[1]))
@@ -5337,7 +5336,6 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		next:
 			sctp_spin_unlock(&head->lock);
 		} while (--remaining > 0);
-		sctp_spin_unlock(&sctp_port_alloc_lock);
 
 		/* Exhausted local port range during search? */
 		ret = 1;

--------------030702020500020208090801--
