From: Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de>
Subject: HELP for dccp implementation.
Date: Wed, 25 Aug 2004 18:46:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412CC269.8080907@rus.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: dccp@ietf.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, dear all

I could not assign __sk_head(head) value to sk in lookup_listen.

I have writen the partial code for receive the request packet at server 
accodring to kernel TCP stuff, which is almost closed to TCP stuff.

Anyone can tell me the reason or any hints? Thanks in advance.

The details is following:

The server for receiveing request packet firstly has following steps:
1. Initialize dccp sock,
2. dccp bind
3. get_port
3. hash
4. accpet and waiting packet
5. calling dccp_rcv to get packet ( I have checked dccp_rcv got the 
request packet).
6. to get sk value by call dccp_lookup
7 ....

My problem is still in geting sk value, The follwing is my printing out:

Aug 25 09:28:38 localhost kernel: DCCP: Hash tables configured 
(established 262144 bind 65536)

dccp_init_sock:
dccp_sock_init_common:
allocated cctp successfully
allocated pkt vectors successfully
dccp_bind.
New dccp_get_port start.65536
New dccp_get_port start.else:start
db not found.
bind hash add:sk:ee9fbc00,node:0,snum:7000
New dccp_get_port start.OK. sk:ee9fbc00,node:0
New dccp_get_port start.65536
New dccp_get_port start.else:start
hlist_empty(&db->owners) not empty.
New dccp_get_port start.OK. sk:ee9fbc00,node:ee5a0444
__dccp_v4_hash, list:c04eb670,num:7000,c0558780
__dccp_v4_hash, list:c04eb670,sk:ee9fbc00
dccp_accept start.7000,sk->sk_family=2,sk->sk_state=1,sk:ee9fbc00
dccp_accept 1 ..flags=2
dccp_accept 2 ..
dccp_accept 3 ..timeo=2147483647,sk:ee9fbc00
wait_for_incoming_connection:
dccp wait for connect start!sk:ee9fbc00
dccp wait for connect start!..sk:ee9fbc00
dccp_rcv start.ee9d3580
dccp_rcv: sk->sk_state=0, type=0,dh->dport=22555
dccp_v4_lookup
__dccp_v4_lookup.
dccp_v4_lookup_connection.
hash 13291
dccp_v4_lookup_connection. head:f7619f58,node:eeaf5834,sk:ee9d3580
dccp_v4_lookup_connection. head:f7619f58,node:,sk:0
dccp_bhash_size: 65536,ntohs(dport):7000
first of head is not empty
dccp_v4_lookup_listen: head: c04eb670,c0558780,__sk_head(head):ee9fbc00
dccp_v4_lookup_listen:sk: 0
dccp_rcv: unable to find socket()

At print out, dccp_bind did not call get_port and inet_sk(sk) is 
assigned a port number  which is 7000 from application.

For printing __sk_head(head):ee9fbc00, I let sk = NULL in the 
dccp_v4_lookup_listen.
HASH_TABLE = 32 or 128 I have the same result.
And the source code is enclosed.

Best regards,

Zhikui

------------------------------------------------------------------------

struct dccp_hashinfo __cacheline_aligned dccp_hashinfo = {
	.__dccp_lhash_lock	=	RW_LOCK_UNLOCKED,
	.__dccp_lhash_users	=	ATOMIC_INIT(0),
	.__dccp_lhash_wait
	  = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.__dccp_lhash_wait),
	.__dccp_portalloc_lock	=	SPIN_LOCK_UNLOCKED
};




struct sockaddr_dccp {
	struct sockaddr_in in;
	__u32		   service;
};

static __inline__ int dccp_hashfn(__u32 laddr, __u16 lport,
				 __u32 faddr, __u16 fport)
{
	int h = (laddr ^ lport) ^ (faddr ^ fport);
	h ^= h >> 16;
	h ^= h >> 8;
	return h & (dccp_ehash_size - 1);;
}

static __inline__ int dccp_sk_hashfn(struct sock *sk)
{
	struct inet_opt *inet = inet_sk(sk);
	__u32 laddr = inet->rcv_saddr;
	__u16 lport = inet->num;
	__u32 faddr = inet->daddr;
	__u16 fport = inet->dport;

	return dccp_hashfn(laddr, lport, faddr, fport);
}

kmem_cache_t *dccp_bucket_cachep;

struct dccp_bind_bucket *dccp_bucket_create(struct dccp_bind_hashbucket *head,
					  unsigned short snum)
{
	struct dccp_bind_bucket *db = kmem_cache_alloc(dccp_bucket_cachep,
						      SLAB_ATOMIC);
	if (db) {
		db->port = snum;
		db->fastreuse = 0;
		INIT_HLIST_HEAD(&db->owners);
		hlist_add_head(&db->node, &head->chain);
	}
	return db;
}

void dccp_bucket_destroy(struct dccp_bind_bucket *db)
{
	if (hlist_empty(&db->owners)) {
		__hlist_del(&db->node);
		kmem_cache_free(dccp_bucket_cachep, db);
	}
}

/******************************************************************************/

static int parse_uaddr(struct sockaddr *uaddr, int addr_len, struct sockaddr_in **iaddr, struct sockaddr_dccp **dccp_addr){
	if(addr_len < sizeof(struct sockaddr_in)) return -1;
	if(addr_len >= sizeof(struct sockaddr_dccp)){
		*dccp_addr = (struct sockaddr_dccp *)uaddr;
		*iaddr     = &((*dccp_addr)->in);
	}else{
		*dccp_addr = NULL;
		*iaddr     = (struct sockaddr_in *)uaddr;
	}
	return 0;
}

/******************************************************************************/
/* refer to net/ipv4/af_inet.c:inet_bind() */
static int dccp_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len){
  printk("dccp_bind.\n");
	struct sockaddr_in   *iaddr;
	struct sockaddr_dccp *dccp_addr;
	struct inet_opt *inet = inet_sk(sk);
	int		      addr_type;
	int		      err;
	unsigned short	      port;

	if(parse_uaddr(uaddr, addr_len, &iaddr, &dccp_addr)) return -EINVAL;

	addr_type = inet_addr_type(iaddr->sin_addr.s_addr);
	if(   inet->freebind == 0
	   && iaddr->sin_addr.s_addr != INADDR_ANY && addr_type != RTN_LOCAL
	   && addr_type != RTN_MULTICAST && addr_type != RTN_BROADCAST)
		                return -EADDRNOTAVAIL;

	port = ntohs(iaddr->sin_port);
	if(port && port < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
		return -EACCES;

	lock_sock(sk);

	if(sk->sk_state != DCCP_STATE_CLOSED) ERR(-EISCONN);

	if(inet->num) ERR(-EINVAL);

	inet->rcv_saddr = inet->saddr = iaddr->sin_addr.s_addr;
	if(addr_type == RTN_MULTICAST || addr_type == RTN_BROADCAST)
		inet->saddr = 0;

	if(dccp_addr) dccp_sk(sk)->service = dccp_addr->service;
	else          dccp_sk(sk)->service = 0;
/*Note if we comment sk_port->getport() function calling, we should assign a local listen port number for building a listen hash and adding hash to node.*/  
/*
	if(sk->sk_prot->get_port(sk, port) != 0){
		inet->saddr = inet->rcv_saddr = 0;
		ERR(-EADDRINUSE);
	}
*/
	if(inet->rcv_saddr) sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
	if(port)          sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
  inet->num = port;/*added 24.08.04, Note if we comment sk_port->getport() function calling, we should assign a local listen port number for building a listen hash and adding hash to node.*/  
	inet->dport = inet->daddr = 0;	
	sk_dst_reset(sk); 			
	err = 0;
out:
	release_sock(sk);       
	return err;
}

void dccp_bind_hash(struct sock *sk, struct dccp_bind_bucket *db,
		   unsigned short snum)
{
	inet_sk(sk)->num = snum;
	sk_add_bind_node(sk, &db->owners);
	dccp_sk(sk)->bind_hash = db;
}

static inline int dccp_bind_conflict(struct sock *sk, struct dccp_bind_bucket *db)
{
  printk("dccp_bind_conflict is called.\n");
  const u32 sk_rcv_saddr = dccp_v4_rcv_saddr(sk);
	struct sock *sk2;
	struct hlist_node *node;
	int reuse = sk->sk_reuse;

	sk_for_each_bound(sk2, node, &db->owners) {
		if (sk != sk2 &&
		    !dccp_v6_ipv6only(sk2) &&
		    (!sk->sk_bound_dev_if ||
		     !sk2->sk_bound_dev_if ||
		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
			if (!reuse || !sk2->sk_reuse ||
			    sk2->sk_state == DCCP_STATE_LISTEN) {
				const u32 sk2_rcv_saddr = dccp_v4_rcv_saddr(sk2);
				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
				    sk2_rcv_saddr == sk_rcv_saddr)
					break;
			}
		}
	}
	return node != NULL;
}

/* Obtain a reference to a local port for the given sock,
 * if snum is zero it means select any available local port.
 */
static int dccp_get_port(struct sock *sk, unsigned short snum)
{
  printk("New dccp_get_port start.%d, inet_sk(sk)->num=%d\n",dccp_bhash_size,inet_sk(sk)->num);
  struct dccp_bind_hashbucket *head;

  struct hlist_node *node;
	struct dccp_bind_bucket *db;
	int ret;

  if(inet_sk(sk)->num !=snum)
     snum=inet_sk(sk)->num;
	local_bh_disable();
	if (!snum) {
		int low = sysctl_local_port_range[0];
		int high = sysctl_local_port_range[1];
		int remaining = (high - low) + 1;
		int rover;

		spin_lock(&dccp_portalloc_lock);
		rover = dccp_port_rover;
		do {
      printk("New dccp_get_port start.rover:%d\n",rover);
			rover++;
			if (rover < low || rover > high)
				rover = low;
			head = &dccp_bhash[dccp_bhashfn(rover)];
			spin_lock(&head->lock);
			db_for_each(db, node, &head->chain)
				if (db->port == rover)
					goto next;
			break;
		next:
			spin_unlock(&head->lock);
		} while (--remaining > 0);
		dccp_port_rover = rover;
		spin_unlock(&dccp_portalloc_lock);

		/* Exhausted local port range during search? */
		ret = 1;
		if (remaining <= 0)
			goto fail;

		/* OK, here is the one we will use.  HEAD is
		 * non-NULL and we hold it's mutex.
		 */
    printk("New dccp_get_port start.if:OK\n");
		snum = rover;
	} else {
    printk("New dccp_get_port start.else:start\n");
		head = &dccp_bhash[dccp_bhashfn(snum)];
		spin_lock(&head->lock);
		db_for_each(db, node, &head->chain)
			if (db->port == snum)
				goto db_found;
	}
	db = NULL;
	goto db_not_found;
db_found:
	if (!hlist_empty(&db->owners)) {
    printk("hlist_empty(&db->owners) not empty.\n");
		if (sk->sk_reuse > 1)
			goto success;
		if (db->fastreuse > 0 &&
		    sk->sk_reuse && sk->sk_state != DCCP_STATE_LISTEN) {
			goto success;
		} else {
			ret = 1;
			if (dccp_bind_conflict(sk, db))
				goto fail_unlock;
		}
	}
db_not_found:
    printk("db not found.\n");
	ret = 1;
	if (!db && (db = dccp_bucket_create(head, snum)) == NULL)
		goto fail_unlock;
	if (hlist_empty(&db->owners)) {
		if (sk->sk_reuse && sk->sk_state != DCCP_STATE_LISTEN)
			db->fastreuse = 1;
		else
			db->fastreuse = 0;
	} else if (db->fastreuse &&
		   (!sk->sk_reuse || sk->sk_state == DCCP_STATE_LISTEN))
		db->fastreuse = 0;
success:
	if (!dccp_sk(sk)->bind_hash){
		dccp_bind_hash(sk, db, snum);
    printk("bind hash add:sk:%x,node:%x,snum:%d\n",sk,node,snum);
    }
	BUG_TRAP(dccp_sk(sk)->bind_hash == db);
 	ret = 0;

fail_unlock:
	spin_unlock(&head->lock);
fail:
	local_bh_enable();
    printk("New dccp_get_port start.OK. sk:%x,node:%x\n",sk,node);
	return ret;
}
/*****************************************************************************/
static int wait_for_incoming_connection(struct sock *sk, long timeo)
{
    printk("wait_for_incoming_connection: \n");
	DECLARE_WAITQUEUE(wait, current);
	int 			err;
	struct dccp_opt *tp = dccp_sk(sk);

	/*
	 * True wake-one mechanism for incoming connections: only
	 * one process gets woken up, not the 'whole herd'.
	 * Since we do not 'race & poll' for established sockets
	 * anymore, the common case will execute the loop only once.
	 *
	 * Subtle issue: "add_wait_queue_exclusive()" will be added
	 * after any current non-exclusive waiters, and we know that
	 * it will always _stay_ after any new non-exclusive waiters
	 * because all non-exclusive waiters are added at the
	 * beginning of the wait-queue. As such, it's ok to "drop"
	 * our exclusiveness temporarily when we get woken up without
	 * having to remove and re-insert us on the wait queue.
	 */
	add_wait_queue_exclusive(sk->sk_sleep, &wait);
     printk("dccp wait for connect start!sk:%x\n",sk);
	for (;;) {
		current->state = TASK_INTERRUPTIBLE;
		release_sock(sk);
     printk("dccp wait for connect start!..sk:%x\n",sk);
		if (tp->accept_queue == NULL){
			timeo = schedule_timeout(timeo);
		}
     printk("dccp wait for connect start .1!sk_state=%d, sk_family=%d\n",sk->sk_state,sk->sk_family);
		lock_sock(sk);
		err = 0;
		if (tp->accept_queue){
			break;
		}
		err = -EINVAL;
     printk("dccp wait for connect start .1!sk_state=%d, sk_family=%d\n",sk->sk_state,sk->sk_family);
		if (sk->sk_state != DCCP_STATE_LISTEN){
     printk("dccp wait for connect start .01!sk_state=%d\n",sk->sk_state);
			break;
		}
		err = sock_intr_errno(timeo);
     printk("dccp wait for connect start .2!\n");
		if (signal_pending(current)){
			break;
		}
		err = -EAGAIN;
		if (!timeo)
			break;
	}
     printk("dccp wait for connect end!\n");
	current->state = TASK_RUNNING;
	remove_wait_queue(sk->sk_sleep, &wait);
     printk("dccp wait for connect end ok err=%d\n",err);
	return err;
}

struct sock *dccp_accept(struct sock *sk, int flags, int *err){
	struct dccp_opt *tp = dccp_sk(sk);
	int              error;
	struct sock          *newsk = NULL;

	lock_sock(sk);

   printk("dccp_accept start.%d,sk->sk_family=%d,sk->sk_state=%d,sk:%x\n",inet_sk(sk)->num,sk->sk_family,sk->sk_state,sk);
	/* this socket must be listening */
  error = -EINVAL;
  printk("dccp_accept 1 ..flags=%d\n",flags);
	if(sk->sk_state != DCCP_STATE_LISTEN)
    goto out;
  printk("dccp_accept 2 ..\n");

	/* Find already established connection */
	if(!tp->accept_queue){
		long timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
  printk("dccp_accept 3 ..timeo=%d,sk:%x\n",timeo,sk);

    error = -EAGAIN;
    if(!timeo)
      goto out;

		error = wait_for_incoming_connection(sk, timeo);
//		error = wait_for_connection(sk, timeo);
  printk("dccp_accept 4 ..\n");
  //sleep(1000);
		if(error) goto out;
		BUG_TRAP(tp->accept_queue);
	}
  printk("dccp_accept 5 ..\n");
	newsk = tp->accept_queue;
	tp->accept_queue = sk_next(newsk);//newsk->sk_bind_next;
	if(tp->accept_queue == NULL) tp->accept_queue_tail = NULL;
	BUG_TRAP(sk->sk_ack_backlog);
	sk->sk_ack_backlog -- ;	/* since we are removing one */
	dccp_sk(newsk)->flag_hashandle = 1;
#if 0
	/* remove from accept queue, will be referenced by socket */
	sock_put(newsk);		/* removed from the queue */
	sock_hold(newsk);
#endif

	error = 0;
out:
  printk("dccp_accept 6 ..err=%d\n",err);
	release_sock(sk);
	*err = error;
	return newsk;
}

void dccp_listen_wlock(void)
{
	write_lock(&dccp_lhash_lock);

	if (atomic_read(&dccp_lhash_users)) {
		DEFINE_WAIT(wait);

		for (;;) {
			prepare_to_wait_exclusive(&dccp_lhash_wait,
						&wait, TASK_UNINTERRUPTIBLE);
			if (!atomic_read(&dccp_lhash_users))
				break;
			write_unlock_bh(&dccp_lhash_lock);
			schedule();
			write_lock_bh(&dccp_lhash_lock);
		}

		finish_wait(&dccp_lhash_wait, &wait);
	}
}

static __inline__ void __dccp_v4_hash(struct sock *sk, const int listen_possible)
{
	struct hlist_head *list;
	rwlock_t *lock;

	BUG_TRAP(sk_unhashed(sk));
	if (listen_possible && sk->sk_state == DCCP_STATE_LISTEN) {
		list = &dccp_listening_hash[dccp_sk_listen_hashfn(sk)];
 
    printk("__dccp_v4_hash, list:%x,num:%d,%x\n",list,inet_sk(sk)->num,&dccp_hash[inet_sk(sk)->num & (DCCP_HTABLE_SIZE - 1)]);
		lock = &dccp_lhash_lock;
		dccp_listen_wlock();
	} else {
		list = &dccp_ehash[(sk->sk_hashent = dccp_sk_hashfn(sk))].chain;
		lock = &dccp_ehash[sk->sk_hashent].lock;
		write_lock(lock);
	}
	__sk_add_node(sk, list);
	sock_prot_inc_use(sk->sk_prot);
	write_unlock(lock);
	if (listen_possible && sk->sk_state == DCCP_STATE_LISTEN)
		wake_up(&dccp_lhash_wait);
  printk("__dccp_v4_hash, list:%x,sk:%x\n",list,sk);
}

static void dccp_v4_hash(struct sock *sk)
{
	if (sk->sk_state != DCCP_STATE_CLOSED) {
		local_bh_disable();
		__dccp_v4_hash(sk, 1);
		local_bh_enable();
	}
}

void dccp_unhash(struct sock *sk)
{
	rwlock_t *lock;

	if (sk_unhashed(sk))
		goto ende;

	if (sk->sk_state == DCCP_STATE_LISTEN) {
		local_bh_disable();
		dccp_listen_wlock();
		lock = &dccp_lhash_lock;
	} else {
		struct dccp_ehash_bucket *head = &dccp_ehash[sk->sk_hashent];
		lock = &head->lock;
		write_lock_bh(&head->lock);
	}

	if (__sk_del_node_init(sk))
		sock_prot_dec_use(sk->sk_prot);
	write_unlock_bh(lock);

 ende:
	if (sk->sk_state == DCCP_STATE_LISTEN)
		wake_up(&dccp_lhash_wait);
}

/*****************************************************************************/
static struct sock *__dccp_v4_lookup_listen(struct hlist_head *head, u32 daddr,
					     unsigned short hnum, int dif)
{
	struct sock *result = NULL, *sk;
	struct hlist_node *node;
	int score, hiscore;

  printk("__dccp_v4_lookup_listen: sk:%x,node:%x,head:%x,sk_state:%d\n",sk,node,head,sk->sk_state);
	hiscore=-1;
	sk_for_each(sk, node, head) {
		struct inet_opt *inet = inet_sk(sk);

		if (inet->num == hnum && !ipv6_only_sock(sk)) {
			__u32 rcv_saddr = inet->rcv_saddr;

			score = (sk->sk_family == PF_INET ? 1 : 0);
			if (rcv_saddr) {
				if (rcv_saddr != daddr)
					continue;
				score+=2;
			}
			if (sk->sk_bound_dev_if) {
				if (sk->sk_bound_dev_if != dif)
					continue;
				score+=2;
			}
			if (score == 5)
				return sk;
			if (score > hiscore) {
				hiscore = score;
				result = sk;
			}
		}
	}
  printk("dccp_v4_lookup_listen:sk:%x,result:%x\n",sk,result);
	return result;
}

/* Optimize the common listener case. */
inline struct sock *dccp_v4_lookup_listen(u32 daddr, u16 hnum,int dif)
{
	struct sock *sk = NULL;
	struct hlist_head *head;

	read_lock(&dccp_lhash_lock);
  printk("dccp_bhash_size: %d,ntohs(dport):%d\n",dccp_bhash_size,hnum);
	head = &dccp_listening_hash[dccp_lhashfn(hnum)];

  if(head->first)
  printk("first of head is not empty\n");

  printk("dccp_v4_lookup_listen: head: %x,%x,__sk_head(head):%x\n",head,&dccp_hash[hnum & (DCCP_HTABLE_SIZE - 1)],__sk_head(head));
	
	if (!hlist_empty(head)) {
		struct inet_opt *inet = inet_sk((sk = __sk_head(head)));
    printk("dccp_v4_lookup_listen:sk: %x\n",sk);

		if (inet->num == hnum && !sk->sk_node.next &&
		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
		    !sk->sk_bound_dev_if)
			goto sherry_cache;
		sk = __dccp_v4_lookup_listen(head, daddr, hnum, dif);
	}
  else
  printk("hlist_empty(head) is empty.\n");
	if (sk) {
sherry_cache:
		sock_hold(sk);
	}
  printk("dccp_v4_lookup_listen:sk: %x\n",sk);
	read_unlock(&dccp_lhash_lock);
	return sk;
}


/*****************************************************************************/

static inline struct sock *dccp_v4_lookup_connection(u32 saddr, u16 sport, u32 daddr, u16 hnum, int dif){
  printk("dccp_v4_lookup_connection.\n");
	struct dccp_ehash_bucket *head;
	DCCP_V4_ADDR_COOKIE(acookie, saddr, daddr)
	__u32 ports = DCCP_COMBINED_PORTS(sport, hnum);
	struct sock *sk;
	struct hlist_node *node;
	int hash = dccp_hashfn(daddr, hnum, saddr, sport);
  printk("hash %d\n",hash);
	head = &dccp_ehash[hash];
  printk("dccp_v4_lookup_connection. head:%x,node:%x,sk:%x\n",head,node,sk);
	read_lock(&head->lock);
	sk_for_each(sk, node, &head->chain) {
		if (DCCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
			goto hit; 
	}

	sk_for_each(sk, node, &(head + dccp_ehash_size)->chain) {
		if (DCCP_IPV4_DW_MATCH(sk, acookie, saddr, daddr, ports, dif))
			goto hit;
	}
	sk = NULL;
out:
	read_unlock(&head->lock);
  printk("dccp_v4_lookup_connection. head:%x,node:,sk:%x\n",head,sk);
	return sk;
hit:
	sock_hold(sk);
	goto out;
}

/*****************************************************************************/

static inline struct sock *__dccp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport,int dif){
  printk("__dccp_v4_lookup.\n");

	struct sock *sk = dccp_v4_lookup_connection(saddr, sport, daddr, ntohs(dport), dif);
	return sk ? : dccp_v4_lookup_listen(daddr, ntohs(dport),dif);
}

inline struct sock *dccp_v4_lookup(u32 saddr, u16 sport, u32 daddr,
				  u16 dport, int dif)
{
  printk("dccp_v4_lookup\n");
  struct sock *sk;

	local_bh_disable();
	sk = __dccp_v4_lookup(saddr, sport, daddr, dport, dif);
	local_bh_enable();

	return sk;
}

Best regards,

Zhikui
