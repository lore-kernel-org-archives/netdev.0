From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Fri, 30 Apr 2010 15:30:14 -0400
Message-ID: <1272655814.3879.8.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-UTxF2UrxRozhR3NUMMwL"
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41377 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab0D3TaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 15:30:22 -0400
Received: by wye20 with SMTP id 20so444805wye.19
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:30:20 -0700 (PDT)
In-Reply-To: <1272573383.3969.8.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UTxF2UrxRozhR3NUMMwL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Eric!

I managed to mod your program to look conceptually similar to mine
and i reproduced the results with same test kernel from yesterday. 
So it is likely the issue is in using epoll vs not using any async as
in your case.
Results attached as well as modified program.

Note: the key things to remember:
rps with this program gets worse over time and different net-next
kernels since Apr14 (look at graph i supplied). Sorry, I am really
busy-ed out to dig any further.

cheers,
jamal



On Thu, 2010-04-29 at 16:36 -0400, jamal wrote:
> On Thu, 2010-04-29 at 09:56 -0400, jamal wrote:
> 
> > 
> > I will try your program instead so we can reduce the variables
> 
> Results attached.
> With your app rps does a hell lot better and non-rps worse ;->
> With my proggie, non-rps does much better than yours and rps does
> a lot worse for same setup. I see the scheduler kicking quiet a bit in
> non-rps for you...
> 
> The main difference between us as i see it is:
> a) i use epoll - actually linked to libevent (1.0.something)
> b) I fork processes and you use pthreads.
> 
> I dont have time to chase it today, but 1) I am either going to change
> yours to use libevent or make mine get rid of it then 2) move towards
> pthreads or have yours fork..
> then observe if that makes any difference..
> 
> 
> cheers,
> jamal

--=-UTxF2UrxRozhR3NUMMwL
Content-Disposition: attachment; filename="apr30-ericmod"
Content-Type: text/plain; name="apr30-ericmod"; charset="UTF-8"
Content-Transfer-Encoding: 7bit


First a few runs with Eric's code + epoll/libevent

-------------------------------------------------------------------------------
   PerfTop:    4009 irqs/sec  kernel:83.4% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

             2097.00  8.6% sky2_poll                   [sky2]              
             1742.00  7.2% _raw_spin_lock_irqsave      [kernel]            
              831.00  3.4% system_call                 [kernel]            
              654.00  2.7% copy_user_generic_string    [kernel]            
              654.00  2.7% datagram_poll               [kernel]            
              647.00  2.7% fget                        [kernel]            
              623.00  2.6% _raw_spin_unlock_irqrestore [kernel]            
              547.00  2.3% _raw_spin_lock_bh           [kernel]            
              506.00  2.1% sys_epoll_ctl               [kernel]            
              475.00  2.0% kmem_cache_free             [kernel]            
              466.00  1.9% schedule                    [kernel]            
              436.00  1.8% vread_tsc                   [kernel].vsyscall_fn
              417.00  1.7% fput                        [kernel]            
              415.00  1.7% sys_epoll_wait              [kernel]            
              402.00  1.7% _raw_spin_lock              [kernel]            


-------------------------------------------------------------------------------
   PerfTop:     616 irqs/sec  kernel:98.7% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ ________

             2534.00 28.6% sky2_poll              [sky2]  
              503.00  5.7% ip_route_input         [kernel]
              438.00  4.9% _raw_spin_lock_irqsave [kernel]
              418.00  4.7% __udp4_lib_lookup      [kernel]
              378.00  4.3% __alloc_skb            [kernel]
              364.00  4.1% ip_rcv                 [kernel]
              323.00  3.6% _raw_spin_lock         [kernel]
              315.00  3.5% sock_queue_rcv_skb     [kernel]
              284.00  3.2% __netif_receive_skb    [kernel]
              281.00  3.2% __udp4_lib_rcv         [kernel]
              266.00  3.0% __wake_up_common       [kernel]
              238.00  2.7% sock_def_readable      [kernel]
              181.00  2.0% __kmalloc              [kernel]
              163.00  1.8% kmem_cache_alloc       [kernel]
              150.00  1.7% ep_poll_callback       [kernel]


-------------------------------------------------------------------------------
   PerfTop:     854 irqs/sec  kernel:80.2% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ____________________

              341.00  8.0% _raw_spin_lock_irqsave      [kernel]            
              235.00  5.5% system_call                 [kernel]            
              174.00  4.1% datagram_poll               [kernel]            
              174.00  4.1% fget                        [kernel]            
              173.00  4.1% copy_user_generic_string    [kernel]            
              135.00  3.2% _raw_spin_unlock_irqrestore [kernel]            
              125.00  2.9% _raw_spin_lock_bh           [kernel]            
              122.00  2.9% schedule                    [kernel]            
              113.00  2.6% sys_epoll_ctl               [kernel]            
              113.00  2.6% kmem_cache_free             [kernel]            
              108.00  2.5% vread_tsc                   [kernel].vsyscall_fn
              105.00  2.5% sys_epoll_wait              [kernel]            
              102.00  2.4% udp_recvmsg                 [kernel]            
               95.00  2.2% mutex_lock                  [kernel]            

Average 97.55% of 10M packets at 750Kpps

Turn on rps mask ee and irq affinity to cpu0

-------------------------------------------------------------------------------
   PerfTop:    3885 irqs/sec  kernel:83.6% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ________

             2945.00 16.7% sky2_poll                      [sky2]  
              653.00  3.7% _raw_spin_lock_irqsave         [kernel]
              460.00  2.6% system_call                    [kernel]
              420.00  2.4% _raw_spin_unlock_irqrestore    [kernel]
              414.00  2.3% sky2_intr                      [sky2]  
              392.00  2.2% fget                           [kernel]
              360.00  2.0% ip_rcv                         [kernel]
              324.00  1.8% sys_epoll_ctl                  [kernel]
              323.00  1.8% __netif_receive_skb            [kernel]
              310.00  1.8% schedule                       [kernel]
              292.00  1.7% ip_route_input                 [kernel]
              292.00  1.7% _raw_spin_lock                 [kernel]
              291.00  1.7% copy_user_generic_string       [kernel]
              284.00  1.6% kmem_cache_free                [kernel]
              262.00  1.5% call_function_single_interrupt [kernel]

-------------------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:98.1% [1000Hz cycles],  (all, cpu: 0)
-------------------------------------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ ________

             4170.00 61.9% sky2_poll                           [sky2]  
              723.00 10.7% sky2_intr                           [sky2]  
              159.00  2.4% __alloc_skb                         [kernel]
              140.00  2.1% get_rps_cpu                         [kernel]
              106.00  1.6% __kmalloc                           [kernel]
               95.00  1.4% enqueue_to_backlog                  [kernel]
               86.00  1.3% kmem_cache_alloc                    [kernel]
               85.00  1.3% irq_entries_start                   [kernel]
               85.00  1.3% _raw_spin_lock_irqsave              [kernel]
               82.00  1.2% _raw_spin_lock                      [kernel]
               66.00  1.0% swiotlb_sync_single                 [kernel]
               58.00  0.9% sky2_remove                         [sky2]  
               49.00  0.7% default_send_IPI_mask_sequence_phys [kernel]
               47.00  0.7% sky2_rx_submit                      [sky2]  
               36.00  0.5% _raw_spin_unlock_irqrestore         [kernel]

-------------------------------------------------------------------------------
   PerfTop:     344 irqs/sec  kernel:84.3% [1000Hz cycles],  (all, cpu: 2)
-------------------------------------------------------------------------------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ ____________________

              114.00  5.2% _raw_spin_lock_irqsave         [kernel]            
               79.00  3.6% fget                           [kernel]            
               78.00  3.6% ip_rcv                         [kernel]            
               78.00  3.6% system_call                    [kernel]            
               75.00  3.4% _raw_spin_unlock_irqrestore    [kernel]            
               67.00  3.1% sys_epoll_ctl                  [kernel]            
               65.00  3.0% schedule                       [kernel]            
               61.00  2.8% ip_route_input                 [kernel]            
               48.00  2.2% vread_tsc                      [kernel].vsyscall_fn
               48.00  2.2% call_function_single_interrupt [kernel]            
               46.00  2.1% kmem_cache_free                [kernel]            
               45.00  2.1% __netif_receive_skb            [kernel]            
               41.00  1.9% process_recv                   snkudp              
               40.00  1.8% kfree                          [kernel]            
               39.00  1.8% _raw_spin_lock                 [kernel]            

92.97% of 10M packets at 750Kpps


Ok, so this is exactly what i saw with my app. non-rps is better.
To summarize: It used to be the opposite on net-next before around
Apr14. rps has gotten worse.

--=-UTxF2UrxRozhR3NUMMwL
Content-Disposition: attachment; filename="udpsnkfrk.c"
Content-Type: text/x-csrc; name="udpsnkfrk.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

/*
 *  Usage: udpsink [ -p baseport] nbports
*/
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <event.h>

struct worker_data {
	struct event *snk_ev;
	struct event_base *base;
	struct timeval t;
	unsigned long pack_count;
	unsigned long bytes_count;
	unsigned long tout;
	int fd;			/* move to avoid hole on 64-bit */
	int pad1;		/*64B - let Eric figure the math;-> */
	//unsigned long _padd[16 - 3]; /* alignment */ 
};

void usage(int code)
{
	fprintf(stderr, "Usage: udpsink [-p baseport] nbports\n");
	exit(code);
}

void process_recv(int fd, short ev, void *arg)
{
	char buffer[4096];
	struct sockaddr_in addr;
	socklen_t len = sizeof(addr);
	struct worker_data *wdata = (struct worker_data *)arg;
	int lu = 0;

	if ((event_add(wdata->snk_ev, &wdata->t)) < 0) {
		perror("cb event_add");
		return;
	}

	if (ev == EV_TIMEOUT) {
		wdata->tout++;
	} else {
		lu = recvfrom(wdata->fd, buffer, sizeof(buffer), 0,
			      (struct sockaddr *)&addr, &len);
		if (lu > 0) {
			wdata->pack_count++;
			wdata->bytes_count += lu;
		}
	}
}

int prep_thread(struct worker_data *wdata)
{
	wdata->t.tv_sec = 1;
	wdata->t.tv_usec = random() % 50000L;

	wdata->base = event_init();
	event_set(wdata->snk_ev, wdata->fd, EV_READ, process_recv, wdata);
	event_base_set(wdata->base, wdata->snk_ev);
	if ((event_add(wdata->snk_ev, &wdata->t)) < 0) {
		perror("event_add");
		return -1;
	}
	return 0;
}

void *worker_func(void *arg)
{
	struct worker_data *wdata = (struct worker_data *)arg;

	return (void *)event_base_loop(wdata->base, 0);
}

int main(int argc, char *argv[])
{
	int c;
	int baseport = 4000;
	int nbthreads;
	struct worker_data *wdata;
	unsigned long ototal = 0;
	int concurrent = 0;
	int verbose = 0;
	int i;
	while ((c = getopt(argc, argv, "cvp:")) != -1) {
		if (c == 'p')
			baseport = atoi(optarg);
		else if (c == 'c')
			concurrent = 1;
		else if (c == 'v')
			verbose++;
		else
			usage(1);
	}
	if (optind == argc)
		usage(1);
	nbthreads = atoi(argv[optind]);
	wdata = calloc(sizeof(struct worker_data), nbthreads);
	if (!wdata) {
		perror("calloc");
		return 1;
	}

	for (i = 0; i < nbthreads; i++) {
		struct sockaddr_in addr;
		pthread_t tid;

		if (i && concurrent) {
			wdata[i].fd = wdata[0].fd;
		} else {
			wdata[i].snk_ev = malloc(sizeof(struct event));
			if (!wdata[i].snk_ev)
				return 1;
			memset(wdata[i].snk_ev, 0, sizeof(struct event));

			wdata[i].fd = socket(PF_INET, SOCK_DGRAM, 0);
			if (wdata[i].fd == -1) {
				free(wdata[i].snk_ev);
				perror("socket");
				return 1;
			}
			memset(&addr, 0, sizeof(addr));
			addr.sin_family = AF_INET;
//                      addr.sin_addr.s_addr = inet_addr(argv[optind]);
			addr.sin_port = htons(baseport + i);
			if (bind
			    (wdata[i].fd, (struct sockaddr *)&addr,
			     sizeof(addr)) < 0) {
				free(wdata[i].snk_ev);
				perror("bind");
				return 1;
			}
//                      fcntl(wdata[i].fd, F_SETFL, O_NDELAY);
		}
		if (prep_thread(wdata + i)) {
			printf("failed to allocate thread %d, exit\n", i);
			exit(0);
		}
		pthread_create(&tid, NULL, worker_func, wdata + i);
	}

	for (;;) {
		unsigned long total;
		long delta;

		sleep(1);
		total = 0;
		for (i = 0; i < nbthreads; i++) {
			total += wdata[i].pack_count;
		}
		delta = total - ototal;
		if (delta) {
			printf("%lu pps (%lu", delta, total);
			if (verbose) {
				for (i = 0; i < nbthreads; i++) {
					if (wdata[i].pack_count)
						printf(" %d:%lu", i,
						       wdata[i].pack_count);
				}
			}
			printf(")\n");
		}
		ototal = total;
	}
}

--=-UTxF2UrxRozhR3NUMMwL--

