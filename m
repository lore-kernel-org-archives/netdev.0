From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] no more rwlock_t inside tcp_ehash_bucket
Date: Tue, 15 Mar 2005 17:13:11 +0100
Message-ID: <42370997.6010302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A machine with large tcp_ehash uses half the size of the hash to store rwlocks.

That seems not really necessary :

- Most accesses to tcp_ehash[] are done with read_locks(), so dirtying the memory (because of embedded rwlocks) all over the hash table is not 
SMP friendly. The cache hit given by the fact that the rwlock and chain were in the same cache line is not really a gain, because of the 
dirtying of the cache line (and exclusive use because of lock operations)

I suggest in this patch using an array of 256 rwlocks.

- Less memory used (or 2 x more entries in hash table if size >= (2^MAX_ORDER)*PAGE_SIZE)
- less memory touched during read_lock()/read_unlock()
- Better sharing of hash entries between cpus

tests done on a production machine (1 million slots, size 8MB). No differences found in performance (oprofile).

5 files changed :

- net/ipv4/tcp_diag.c
- net/ipv4/tcp_minisocks.c
- net/ipv4/tcp_ipv4.c
- net/ipv4/tcp.c
- include/net/tcp.h
- include/net/sock.h

(i converted also __tcp_bhash_size , __tcp_ehash_size , sk_hashent to 'unsigned int' to let compiler chose a better code)

Eric Dumazet

# diff -Nru linux-2.6.11 linux-2.6.11-ed
diff -Nru linux-2.6.11/include/net/sock.h linux-2.6.11-ed/include/net/sock.h
--- linux-2.6.11/include/net/sock.h     2005-03-02 08:38:17.000000000 +0100
+++ linux-2.6.11-ed/include/net/sock.h  2005-03-15 17:02:52.000000000 +0100
@@ -217,7 +217,7 @@
         unsigned char           sk_no_largesend;
         int                     sk_route_caps;
         unsigned long           sk_lingertime;
-       int                     sk_hashent;
+       unsigned int                    sk_hashent;
         /*
          * The backlog queue is special, it is always used with
          * the per-socket spinlock held and requires low latency

diff -Nru linux-2.6.11/include/net/tcp.h linux-2.6.11-ed/include/net/tcp.h
--- linux-2.6.11/include/net/tcp.h      2005-03-02 08:37:48.000000000 +0100
+++ linux-2.6.11-ed/include/net/tcp.h   2005-03-15 15:06:31.000000000 +0100
@@ -44,9 +44,14 @@
   * for the rest.  I'll experiment with dynamic table growth later.
   */
  struct tcp_ehash_bucket {
-       rwlock_t          lock;
         struct hlist_head chain;
-} __attribute__((__aligned__(8)));
+} ;
+
+/*
+ * instead of using one rwlock_t for each ehash_bucket, use a table of 256 rwlock_t
+ */
+#define TCP_EHASH_RWLOCK_SZ 256
+extern rwlock_t tcp_ehash_lock[TCP_EHASH_RWLOCK_SZ] ;

  /* This is for listening sockets, thus all sockets which possess wildcards. */
  #define TCP_LHTABLE_SIZE       32      /* Yes, really, this is all you need. */
@@ -106,6 +111,7 @@
         return hlist_empty(&head->chain) ? NULL : __tb_head(head);
  }

+
  extern struct tcp_hashinfo {
         /* This is for sockets with full identity only.  Sockets here will
          * always be without wildcards and will have the following invariant:
@@ -122,8 +128,9 @@
          */
         struct tcp_bind_hashbucket *__tcp_bhash;

-       int __tcp_bhash_size;
-       int __tcp_ehash_size;
+       unsigned int __tcp_bhash_size;
+       unsigned int __tcp_ehash_size;
+

         /* All sockets in TCP_LISTEN state will be in here.  This is the only
          * table where wildcard'd TCP sockets can exist.  Hash function here

diff -Nru linux-2.6.11/net/ipv4/tcp.c linux-2.6.11-ed/net/ipv4/tcp.c
--- linux-2.6.11/net/ipv4/tcp.c 2005-03-15 14:50:53.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/tcp.c      2005-03-15 15:08:28.000000000 +0100
@@ -2309,10 +2309,10 @@
                                         0);
         tcp_ehash_size = (1 << tcp_ehash_size) >> 1;
         for (i = 0; i < (tcp_ehash_size << 1); i++) {
-               rwlock_init(&tcp_ehash[i].lock);
                 INIT_HLIST_HEAD(&tcp_ehash[i].chain);
         }
-
+       for (i = 0; i < TCP_EHASH_RWLOCK_SZ; i++)
+               rwlock_init(&tcp_ehash_lock[i]);
         tcp_bhash = (struct tcp_bind_hashbucket *)
                 alloc_large_system_hash("TCP bind",
                                         sizeof(struct tcp_bind_hashbucket),

diff -Nru linux-2.6.11/net/ipv4/tcp_diag.c linux-2.6.11-ed/net/ipv4/tcp_diag.c
--- linux-2.6.11/net/ipv4/tcp_diag.c    2005-03-02 08:37:31.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/tcp_diag.c 2005-03-15 15:22:30.000000000 +0100
@@ -666,7 +666,7 @@
                 if (i > s_i)
                         s_num = 0;

-               read_lock_bh(&head->lock);
+               read_lock_bh(&tcp_ehash_lock[i%TCP_EHASH_RWLOCK_SZ]);

                 num = 0;
                 sk_for_each(sk, node, &head->chain) {
@@ -682,7 +682,7 @@
                         if (r->id.tcpdiag_dport != inet->dport && r->id.tcpdiag_dport)
                                 goto next_normal;
                         if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
-                               read_unlock_bh(&head->lock);
+                               read_unlock_bh(&tcp_ehash_lock[i%TCP_EHASH_RWLOCK_SZ]);
                                 goto done;
                         }
  next_normal:
@@ -703,14 +703,14 @@
                                     r->id.tcpdiag_dport)
                                         goto next_dying;
                                 if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
-                                       read_unlock_bh(&head->lock);
+                                       read_unlock_bh(&tcp_ehash_lock[i%TCP_EHASH_RWLOCK_SZ]);
                                         goto done;
                                 }
  next_dying:
                                 ++num;
                         }
                 }
-               read_unlock_bh(&head->lock);
+               read_unlock_bh(&tcp_ehash_lock[i%TCP_EHASH_RWLOCK_SZ]);
         }

  done:

diff -Nru linux-2.6.11/net/ipv4/tcp_ipv4.c linux-2.6.11-ed/net/ipv4/tcp_ipv4.c
--- linux-2.6.11/net/ipv4/tcp_ipv4.c    2005-03-02 08:37:54.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/tcp_ipv4.c 2005-03-15 17:02:52.000000000 +0100
@@ -96,6 +96,8 @@
         .__tcp_portalloc_lock   =       SPIN_LOCK_UNLOCKED
  };

+rwlock_t tcp_ehash_lock[TCP_EHASH_RWLOCK_SZ] ;
+
  /*
   * This array holds the first and last local port number.
   * For high-usage systems, use sysctl to change this to
@@ -104,16 +106,16 @@
  int sysctl_local_port_range[2] = { 1024, 4999 };
  int tcp_port_rover = 1024 - 1;

-static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
+static __inline__ unsigned int tcp_hashfn(__u32 laddr, __u16 lport,
                                  __u32 faddr, __u16 fport)
  {
-       int h = (laddr ^ lport) ^ (faddr ^ fport);
+       unsigned int h = (laddr ^ lport) ^ (faddr ^ fport);
         h ^= h >> 16;
         h ^= h >> 8;
         return h & (tcp_ehash_size - 1);
  }

-static __inline__ int tcp_sk_hashfn(struct sock *sk)
+static __inline__ unsigned int tcp_sk_hashfn(struct sock *sk)
  {
         struct inet_sock *inet = inet_sk(sk);
         __u32 laddr = inet->rcv_saddr;
@@ -360,7 +362,7 @@
                 tcp_listen_wlock();
         } else {
                 list = &tcp_ehash[(sk->sk_hashent = tcp_sk_hashfn(sk))].chain;
-               lock = &tcp_ehash[sk->sk_hashent].lock;
+               lock = &tcp_ehash_lock[sk->sk_hashent%TCP_EHASH_RWLOCK_SZ];
                 write_lock(lock);
         }
         __sk_add_node(sk, list);
@@ -391,9 +393,8 @@
                 tcp_listen_wlock();
                 lock = &tcp_lhash_lock;
         } else {
-               struct tcp_ehash_bucket *head = &tcp_ehash[sk->sk_hashent];
-               lock = &head->lock;
-               write_lock_bh(&head->lock);
+               lock = &tcp_ehash_lock[sk->sk_hashent%TCP_EHASH_RWLOCK_SZ];
+               write_lock_bh(lock);
         }

         if (__sk_del_node_init(sk))
@@ -492,9 +493,9 @@
         /* Optimize here for direct hit, only listening connections can
          * have wildcards anyways.
          */
-       int hash = tcp_hashfn(daddr, hnum, saddr, sport);
+       unsigned int hash = tcp_hashfn(daddr, hnum, saddr, sport);
         head = &tcp_ehash[hash];
-       read_lock(&head->lock);
+       read_lock(&tcp_ehash_lock[hash%TCP_EHASH_RWLOCK_SZ]);
         sk_for_each(sk, node, &head->chain) {
                 if (TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
                         goto hit; /* You sunk my battleship! */
@@ -507,7 +508,7 @@
         }
         sk = NULL;
  out:
-       read_unlock(&head->lock);
+       read_unlock(&tcp_ehash_lock[hash%TCP_EHASH_RWLOCK_SZ]);
         return sk;
  hit:
         sock_hold(sk);
@@ -555,13 +556,13 @@
         int dif = sk->sk_bound_dev_if;
         TCP_V4_ADDR_COOKIE(acookie, saddr, daddr)
         __u32 ports = TCP_COMBINED_PORTS(inet->dport, lport);
-       int hash = tcp_hashfn(daddr, lport, saddr, inet->dport);
+       unsigned int hash = tcp_hashfn(daddr, lport, saddr, inet->dport);
         struct tcp_ehash_bucket *head = &tcp_ehash[hash];
         struct sock *sk2;
         struct hlist_node *node;
         struct tcp_tw_bucket *tw;

-       write_lock(&head->lock);
+       write_lock(&tcp_ehash_lock[hash%TCP_EHASH_RWLOCK_SZ]);

         /* Check TIME-WAIT sockets first. */
         sk_for_each(sk2, node, &(head + tcp_ehash_size)->chain) {
@@ -616,7 +617,7 @@
         BUG_TRAP(sk_unhashed(sk));
         __sk_add_node(sk, &head->chain);
         sock_prot_inc_use(sk->sk_prot);
-       write_unlock(&head->lock);
+       write_unlock(&tcp_ehash_lock[hash%TCP_EHASH_RWLOCK_SZ]);

         if (twp) {
                 *twp = tw;
@@ -632,7 +633,7 @@
         return 0;

  not_unique:
-       write_unlock(&head->lock);
+       write_unlock(&tcp_ehash_lock[hash%TCP_EHASH_RWLOCK_SZ]);
         return -EADDRNOTAVAIL;
  }

@@ -2224,7 +2225,7 @@
                 /* We can reschedule _before_ having picked the target: */
                 cond_resched_softirq();

-               read_lock(&tcp_ehash[st->bucket].lock);
+               read_lock(&tcp_ehash_lock[st->bucket%TCP_EHASH_RWLOCK_SZ]);
                 sk_for_each(sk, node, &tcp_ehash[st->bucket].chain) {
                         if (sk->sk_family != st->family) {
                                 continue;
@@ -2241,7 +2242,7 @@
                         rc = tw;
                         goto out;
                 }
-               read_unlock(&tcp_ehash[st->bucket].lock);
+               read_unlock(&tcp_ehash_lock[st->bucket%TCP_EHASH_RWLOCK_SZ]);
                 st->state = TCP_SEQ_STATE_ESTABLISHED;
         }
  out:
@@ -2268,14 +2269,14 @@
                         cur = tw;
                         goto out;
                 }
-               read_unlock(&tcp_ehash[st->bucket].lock);
+               read_unlock(&tcp_ehash_lock[st->bucket%TCP_EHASH_RWLOCK_SZ]);
                 st->state = TCP_SEQ_STATE_ESTABLISHED;

                 /* We can reschedule between buckets: */
                 cond_resched_softirq();

                 if (++st->bucket < tcp_ehash_size) {
-                       read_lock(&tcp_ehash[st->bucket].lock);
+                       read_lock(&tcp_ehash_lock[st->bucket%TCP_EHASH_RWLOCK_SZ]);
                         sk = sk_head(&tcp_ehash[st->bucket].chain);
                 } else {
                         cur = NULL;
@@ -2385,7 +2386,7 @@
         case TCP_SEQ_STATE_TIME_WAIT:
         case TCP_SEQ_STATE_ESTABLISHED:
                 if (v)
-                       read_unlock(&tcp_ehash[st->bucket].lock);
+                       read_unlock(&tcp_ehash_lock[st->bucket%TCP_EHASH_RWLOCK_SZ]);
                 local_bh_enable();
                 break;
         }

diff -Nru linux-2.6.11/net/ipv4/tcp_minisocks.c linux-2.6.11-ed/net/ipv4/tcp_minisocks.c
--- linux-2.6.11/net/ipv4/tcp_minisocks.c       2005-03-02 08:38:17.000000000 +0100
+++ linux-2.6.11-ed/net/ipv4/tcp_minisocks.c    2005-03-15 15:21:05.000000000 +0100
@@ -66,14 +66,14 @@

         /* Unlink from established hashes. */
         ehead = &tcp_ehash[tw->tw_hashent];
-       write_lock(&ehead->lock);
+       write_lock(&tcp_ehash_lock[tw->tw_hashent%TCP_EHASH_RWLOCK_SZ]);
         if (hlist_unhashed(&tw->tw_node)) {
-               write_unlock(&ehead->lock);
+               write_unlock(&tcp_ehash_lock[tw->tw_hashent%TCP_EHASH_RWLOCK_SZ]);
                 return;
         }
         __hlist_del(&tw->tw_node);
         sk_node_init(&tw->tw_node);
-       write_unlock(&ehead->lock);
+       write_unlock(&tcp_ehash_lock[tw->tw_hashent%TCP_EHASH_RWLOCK_SZ]);

         /* Disassociate with bind bucket. */
         bhead = &tcp_bhash[tcp_bhashfn(tw->tw_num)];
@@ -297,6 +297,7 @@
  static void __tcp_tw_hashdance(struct sock *sk, struct tcp_tw_bucket *tw)
  {
         struct tcp_ehash_bucket *ehead = &tcp_ehash[sk->sk_hashent];
+       rwlock_t *rwp = &tcp_ehash_lock[sk->sk_hashent%TCP_EHASH_RWLOCK_SZ] ;
         struct tcp_bind_hashbucket *bhead;

         /* Step 1: Put TW into bind hash. Original socket stays there too.
@@ -310,7 +311,7 @@
         tw_add_bind_node(tw, &tw->tw_tb->owners);
         spin_unlock(&bhead->lock);

-       write_lock(&ehead->lock);
+       write_lock(rwp);

         /* Step 2: Remove SK from established hash. */
         if (__sk_del_node_init(sk))
@@ -320,7 +321,7 @@
         tw_add_node(tw, &(ehead + tcp_ehash_size)->chain);
         atomic_inc(&tw->tw_refcnt);

-       write_unlock(&ehead->lock);
+       write_unlock(rwp);
  }

  /*
