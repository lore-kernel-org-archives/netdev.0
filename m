From: Yon Uriarte <havanna_moon@gmx.net>
Subject: [HELP] kernel_thread
Date: Mon, 8 Apr 2002 01:00:20 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0204080018501.19296-100000@havana.yon.net>
Reply-To: <havanna_moon@gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux netdev <netdev@oss.sgi.com>
To: <design-admin@lists.freeswan.org>
List-Id: netdev.vger.kernel.org

Hello,

 I'm developing the IPSEC NAT traversal patch and I've run on a little
problem. I'm crossposting this to both list in the hope of getting an
answer at all. I'm getting moderately desperate :-E3

 The issue: I need to 'steal' skbs from the receive queue of an udp
socket. My code only gets called as the data_ready() callback of the
struct sock (in softirq context, AFAIK).

 Apparently this means sometimes there are more than 1 packet on the
queue. Those packets can be normal packets(N), keepalive(K) or
udp-encapsulated-esp packets(E). Graphically:

Sock->receive_queue -> K->N->E->N->E->E->NULL

 At first, following the data path (udp_queue_rcv_skb), I thought only one
packet would be on the queue at any one time, so all I had to do was check
the last packet on the queue and handle it (drop, decode, let it stay
there and call the normal callback (to wake up the reading process)).

 But pinging -f led to packet loss, or better put, E-type packet passing
to user space.

 So my first question is: Any good idea on how to resolve this?
Would RTFinclude/linux/timer.hIF help (is it appropiate for this)?

 I decided to implement the following strategy: On callback I would walk
the whole queue, removing K's and enqueueing the E packets on another
private queue (after removing them off the sock). This queue is worked on
by a kernel thread (man kernel_thread(k) (I wish!)), just like
ksoftirqd_CPUN, kreiserfsd, etc...

 This has the nice property of being able to see how much time/cpu%
udp/esp packet decoding is taking. All is well (hmm, better put:it doesnt
crash, this has induced other funny bugs), until the module is unloaded.
The memory isnt being freed. So after a few load/unloads its reboot time
(I run my UMLs with mem=16m, so that would be around 3 cycles).

 I've looked at some of the users of kernel_thread (kreisersfsd,
ksoftirqd, apm, some weirdo drivers) and cant quite find the differences
between my usage and theirs, I've even suspected some UML bug, but I could
load/unload the reiserfs module (mounting/umount something, to trigger the
startup of the thread) without problems.

 I suspected I was starting the kernel thread on the wrong context and
changed the code to trigger the startup of the thread only when there are
active udp-encaps SAs around, at ipsec_sa_put() time. No luck, same
result. I've tried playing with the clone_flags argument to kernel_thread,
no luck. I suppose the correct argument to clone_flags for my needs is 0.

 I'm sleeping on module unload time, waiting for the threads to die. They
are all gone by the time I return to the caller of cleanup_module().

 I've played with __init/__exit, no luck.

 Questions: Is this overkill? What I'm doing wrong?

Code snippet (I'm only running one thread atm, but it will be easy
to add the code to expand this to 1 thread/cpu):
-----------------------------------
struct sk_buff_head udp_ipsec_list;
DECLARE_WAIT_QUEUE_HEAD(udp_decapsulators);
spinlock_t udp_decapsulators_lock;
atomic_t udp_threads = ATOMIC_INIT(0);

static volatile int udp_stop_threads = 0; /* XXX is volatile needed ? */

/* snip[the callback queueing the packets on udp_ipsec_list] */

static int k_ipsec_udp(void * __bind_cpu)
{
        int bind_cpu = (int) (long) __bind_cpu;
        int cpu = cpu_logical_map(bind_cpu);
        DECLARE_WAITQUEUE(wait, current);
	struct sk_buff *skb;

	/* MOD_INC_USE_COUNT not needed, we sleep on unload to wait for
the threads */
	atomic_inc(&udp_threads);
        daemonize();
	reparent_to_init();
        current->nice = 19;

        spin_lock_irq(&current->sigmask_lock);
        sigfillset(&current->blocked);
	recalc_sigpending(current);
        spin_unlock_irq(&current->sigmask_lock);

        sprintf(current->comm, "kipsec_udp_CPU%d", bind_cpu);

        /* Migrate to the right CPU */
        current->cpus_allowed = 1UL << cpu;
        while (smp_processor_id() != cpu)
                schedule();

        set_current_state(TASK_INTERRUPTIBLE);
        mb();

	add_wait_queue( &udp_decapsulators, &wait);
        for (;;) {
	  printk(KERN_CRIT "kipsec_udp_CPU%d main\n", bind_cpu);

	  set_current_state(TASK_INTERRUPTIBLE);
	  schedule();
	  set_current_state(TASK_RUNNING);
	  if ( udp_stop_threads )
	    break;
	  while ( skb_queue_len( &udp_ipsec_list) > 0 ) {
	    //int i = 0;
	    printk(KERN_CRIT "kipsec_udp_CPU%d processing\n", bind_cpu);
	    skb = skb_dequeue( &udp_ipsec_list );
	    if( skb != NULL )
	      ipsec_udp_input(skb);
	/* will call ipsec_rcv after mangling the skb a little */
	    /*	    if( ++i % 16 && current->need_resched)
		    schedule(); */
	  }
        }
	while ( ( skb = skb_dequeue( &udp_ipsec_list) ) != NULL )
	  kfree_skb( skb ) ;
	atomic_dec(&udp_threads);
	/* MOD_DEC_USE_COUNT not needed,
	 * we sleep on unload to wait for the threads */
	printk(KERN_CRIT "Exiting ipsec_udp thread  on cpu %d\n", bind_cpu);
	return 0;
}



int  /*__init*/  start_udp_threads(void)
{
  int cpu;
  spin_lock( &udp_decapsulators_lock );
  printk(KERN_CRIT "start_udp_threads()\n");
  skb_queue_head_init( &udp_ipsec_list );
  for (cpu = 0; cpu < smp_num_cpus; cpu++) {
    if (kernel_thread( k_ipsec_udp, (void *) (long) cpu, 0) < 0)
      printk("start_udp_threads() failed for cpu %d\n", cpu);
  }
  spin_unlock( &udp_decapsulators_lock );
    return 0;
}
/*__initcall(start_udp_threads);*/

int  /*__exit*/  stop_udp_threads(void)
{
  int n;
  printk(KERN_CRIT "stop_udp_threads()\n");
  spin_lock( &udp_decapsulators_lock );

  udp_stop_threads = 1;
  wake_up( &udp_decapsulators );
  while( ( n = atomic_read(&udp_threads)) > 0)
    {
      printk(KERN_CRIT "stop_udp_threads waiting 1 sec for threads, %d still running \n", n);
      set_current_state(TASK_UNINTERRUPTIBLE);
      schedule_timeout(1*HZ);
      set_current_state(TASK_RUNNING);
    }
  spin_unlock( &udp_decapsulators_lock );
  return 0;
}
-----------------------

 Any obvious error?

TIA, regards
 yon
