From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] fix secure tcp sequence number generation
Date: Sat, 02 Oct 2004 20:10:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415EEF0E.3080808@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020503080807000603060306"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020503080807000603060306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

Ted's recent random.c update broke the periodic rekeying:
schedule_work() doesn't provide synchronization. Additionally the first
syn values after boot are generated with secret 0 - not good.

Attached is a big cleanup. Linus asked me to send to to you for merging:

Description:
The tcp sequence number generator needs a random seed that is reset every
few minutes. Since the sequence numbers should be constantly increasing,
for each rekey 2^24 is added to the sequence number.
The actual use of the sequence number generator is lockless,
synchronization is achieved by having two copies of the control structure.

The attached patch:
- fixes a race in rekey_seq_generator(): schedule_work doesn't
   provide synchronization.
- Uses schedule_delayed_work() for the rekey: simplifies synchronization
   and speeds up the hot path.
- replaces do_gettimeofday with get_seconds(): get_seconds is faster and
   usec resolution is not required.
- removes tmpdata - not needed with new locking.
- Adds a late_initcall for the first initialization after boot.
   init_call would be too early, I've checked that the late_initcall runs
   before net/ipv4/ipconfig.c, i.e. the BOOTP/DHCP autoconfiguration.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>



--------------020503080807000603060306
Content-Type: text/plain;
 name="patch-random-cleanup"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-random-cleanup"

--- 2.6/drivers/char/random.c	2004-10-02 19:30:18.583688301 +0200
+++ build-2.6/drivers/char/random.c	2004-10-02 19:09:54.288451293 +0200
@@ -2184,7 +2184,7 @@
 #undef K3
 
 /* This should not be decreased so low that ISNs wrap too fast. */
-#define REKEY_INTERVAL	300
+#define REKEY_INTERVAL	(300*HZ)
 /*
  * Bit layout of the tcp sequence numbers (before adding current time):
  * bit 24-31: increased after every key exchange
@@ -2210,49 +2210,55 @@
 #define HASH_MASK	( (1<<HASH_BITS)-1 )
 
 static struct keydata {
-	time_t rekey_time;
 	__u32	count;		// already shifted to the final position
 	__u32	secret[12];
 } ____cacheline_aligned ip_keydata[2];
 
-static spinlock_t ip_lock = SPIN_LOCK_UNLOCKED;
 static unsigned int ip_cnt;
 
-static void rekey_seq_generator(void *private_)
-{
-	struct keydata *keyptr, tmp;
-	struct timeval 	tv;
+static void rekey_seq_generator(void *private_);
 
-	do_gettimeofday(&tv);
-	get_random_bytes(tmp.secret, sizeof(tmp.secret));
+static DECLARE_WORK(rekey_work, rekey_seq_generator, NULL);
 
-	spin_lock_bh(&ip_lock);
-	keyptr = &ip_keydata[ip_cnt&1];
+/*
+ * Lock avoidance:
+ * The ISN generation runs lockless - it's just a hash over random data.
+ * State changes happen every 5 minutes when the random key is replaced.
+ * Synchronization is performed by having two copies of the hash function
+ * state and rekey_seq_generator always updates the inactive copy.
+ * The copy is then activated by updating ip_cnt.
+ * The implementation breaks down if someone blocks the thread
+ * that processes SYN requests for more than 5 minutes. Should never
+ * happen, and even if that happens only a not perfectly compliant
+ * ISN is generated, nothing fatal.
+ */
+static void rekey_seq_generator(void *private_)
+{
+	struct keydata *keyptr = &ip_keydata[1^(ip_cnt&1)];
 
-	keyptr = &ip_keydata[1^(ip_cnt&1)];
-	keyptr->rekey_time = tv.tv_sec;
-	memcpy(keyptr->secret, tmp.secret, sizeof(keyptr->secret));
+	get_random_bytes(keyptr->secret, sizeof(keyptr->secret));
 	keyptr->count = (ip_cnt&COUNT_MASK)<<HASH_BITS;
-	mb();
+	smp_wmb();
 	ip_cnt++;
-
-	spin_unlock_bh(&ip_lock);
+	schedule_delayed_work(&rekey_work, REKEY_INTERVAL);
 }
 
-static DECLARE_WORK(rekey_work, rekey_seq_generator, NULL);
-
-static inline struct keydata *check_and_rekey(time_t time)
+static inline struct keydata *get_keyptr(void)
 {
 	struct keydata *keyptr = &ip_keydata[ip_cnt&1];
 
-	rmb();
-	if (!keyptr->rekey_time || (time - keyptr->rekey_time) > REKEY_INTERVAL) {
-		schedule_work(&rekey_work);
-	}
+	smp_rmb();
 
 	return keyptr;
 }
 
+static __init int seqgen_init(void)
+{
+	rekey_seq_generator(NULL);
+	return 0;
+}
+late_initcall(seqgen_init);
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 __u32 secure_tcpv6_sequence_number(__u32 *saddr, __u32 *daddr,
 				   __u16 sport, __u16 dport)
@@ -2260,14 +2266,12 @@
 	struct timeval 	tv;
 	__u32		seq;
 	__u32		hash[12];
-	struct keydata *keyptr;
+	struct keydata *keyptr = get_keyptr();
 
 	/* The procedure is the same as for IPv4, but addresses are longer.
 	 * Thus we must use twothirdsMD4Transform.
 	 */
 
-	do_gettimeofday(&tv);	/* We need the usecs below... */
-	keyptr = check_and_rekey(tv.tv_sec);
 
 	memcpy(hash, saddr, 16);
 	hash[4]=(sport << 16) + dport;
@@ -2275,6 +2279,8 @@
 
 	seq = twothirdsMD4Transform(daddr, hash) & HASH_MASK;
 	seq += keyptr->count;
+
+	do_gettimeofday(&tv);
 	seq += tv.tv_usec + tv.tv_sec*1000000;
 
 	return seq;
@@ -2288,13 +2294,7 @@
 	struct timeval 	tv;
 	__u32		seq;
 	__u32	hash[4];
-	struct keydata *keyptr;
-
-	/*
-	 * Pick a random secret every REKEY_INTERVAL seconds.
-	 */
-	do_gettimeofday(&tv);	/* We need the usecs below... */
-	keyptr = check_and_rekey(tv.tv_sec);
+	struct keydata *keyptr = get_keyptr();
 
 	/*
 	 *  Pick a unique starting offset for each TCP connection endpoints
@@ -2317,6 +2317,7 @@
 	 *	That's funny, Linux has one built in!  Use it!
 	 *	(Networks are faster now - should this be increased?)
 	 */
+	do_gettimeofday(&tv);
 	seq += tv.tv_usec + tv.tv_sec*1000000;
 #if 0
 	printk("init_seq(%lx, %lx, %d, %d) = %d\n",
@@ -2335,7 +2336,7 @@
 	struct keydata *keyptr;
 	__u32 hash[4];
 
-	keyptr = check_and_rekey(get_seconds());
+	keyptr = get_keyptr();
 
 	/*
 	 *  Pick a unique starting offset for each IP destination.


--------------020503080807000603060306--
