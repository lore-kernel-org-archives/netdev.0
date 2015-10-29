From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 05:35:19 -0700
Message-ID: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
	 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028223330.GD22011@ZenIV.linux.org.uk>
	 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029001532.GE22011@ZenIV.linux.org.uk>
	 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029041611.GF22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20151029041611.GF22011@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-29 at 04:16 +0000, Al Viro wrote:

> Have you tried to experiment with that in userland?  I mean, emulate that
> thing in normal userland code, count the cacheline accesses and drive it
> with the use patterns collected from actual applications.

Sure.

> 
> I can sit down and play with math expectations, but I suspect that it's
> easier to experiment.  It's nothing but an intuition (I hadn't seriously
> done probability theory in quite a while, and my mathematical tastes run
> more to geometry and topology anyway), but... I would expect it to degrade
> badly when the bitmap is reasonably dense.
> 
> Note, BTW, that vmalloc'ed memory gets populated as you read it, and it's
> not cheap - it's done via #PF triggered in kernel mode, with handler
> noticing that the faulting address is in vmalloc range and doing the
> right thing.  IOW, if your bitmap is very sparse, the price of page faults
> needs to be taken into account.

This vmalloc PF is pure noise.
This only matters for the very first allocations.

We target programs opening zillions of fd in their lifetime ;)

Not having to expand a 4,000,000 slots fd array while fully loaded also
removes a latency spike that is very often not desirable.


> 
> AFAICS, the only benefit of that thing is keeping dirtied cachelines far
> from each other.  Which might be a win overall, but I'm not convinced that
> the rest won't offset the effect of that...

Well, I already tested the O_FD_FASTALLOC thing, and I can tell you
find_next_zero_bit() is nowhere to be found in kernel profiles anymore.
It also lowers time we hold the fd array spinlock while doing fd alloc.

User land test program I wrote few months back

Current kernel :

    64.98%  [kernel]          [k] queued_spin_lock_slowpath    
    14.88%  opensock          [.] memset    // this part simulates user land actual work ;)                   
    11.15%  [kernel]          [k] _find_next_bit.part.0        
     0.69%  [kernel]          [k] _raw_spin_lock               
     0.46%  [kernel]          [k] memset_erms                  
     0.38%  [kernel]          [k] sk_alloc                     
     0.37%  [kernel]          [k] kmem_cache_alloc             
     0.33%  [kernel]          [k] get_empty_filp               
     0.31%  [kernel]          [k] kmem_cache_free              
     0.26%  [kernel]          [k] __alloc_fd                   
     0.26%  opensock          [.] child_function               
     0.18%  [kernel]          [k] inode_init_always            
     0.17%  opensock          [.] __random_r                   


/*
 * test for b/9072743 : fd scaling on gigantic process (with ~ 10,000,000 TCP sockets)
 * - Size fd arrays in kernel to avoid resizings that kill latencies.
 * - Then launch xx threads doing
 *    populate the fd array of the process, opening 'max' files.
 *    
 *    - Loop : close(randomfd()), socket(AF_INET, SOCK_STREAM, 0);
 *
 * Usage : opensock [ -n fds_count ] [ -t threads_count] [-f]
 */

#include <pthread.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

unsigned int count;
int skflags;

#define NBTHREADS_MAX 4096
pthread_t tid[NBTHREADS_MAX];
int nbthreads;
int nbthreads_req = 24;
int stop_all;

#ifndef O_FD_FASTALLOC
#define O_FD_FASTALLOC 0x40000000
#endif

#ifndef SOCK_FD_FASTALLOC
#define SOCK_FD_FASTALLOC O_FD_FASTALLOC
#endif

/* expand kernel fd array for optimal perf.
 * This could be done by doing a loop on dup(),
 * or can be done using dup2()
 */
int expand_fd_array(int max)
{
	int target, res;
	int fd = socket(AF_INET, SOCK_STREAM, 0);

	if (fd == -1) {
		perror("socket()");
		return -1;
	}
	for (;;) {
		count = max;
		target = count;
		if (skflags & SOCK_FD_FASTALLOC)
			target += count/10;
		res = dup2(fd, target);
		if (res != -1) {
			close(res);
			break;
		}
		max -= max/10;
	}
	printf("count=%u (check/increase ulimit -n)\n", count);
	return 0;
}

static char state[32] = {
	0, 1, 2, 3, 4, 5, 6, 7,
	8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20, 21, 22, 23,
	24, 25, 26, 27, 28, 29, 30, 31
};

/* each thread is using ~400 KB of data per unit of work */
#define WORKING_SET_SIZE 400000

static void *child_function(void *arg)
{
	unsigned int max = count / nbthreads_req;
	struct random_data buf;
	unsigned int idx;
	int *tab;
	unsigned long iter = 0;
	unsigned long *work_set = malloc(WORKING_SET_SIZE);
	int i;

	if (!work_set)
		return NULL;
	tab = malloc(max * sizeof(int));
	if (!tab) {
		free(work_set);
		return NULL;
	}
	memset(tab, 255, max * sizeof(int));
	
	initstate_r(getpid(), state, sizeof(state), &buf);

	tab[0] = socket(AF_INET, SOCK_STREAM | skflags, 0);
	for (i = 1; i < max; i++)
		tab[i] = dup(tab[0]);

	while (!stop_all) {
		random_r(&buf, &idx);
		idx = idx % max;
		close(tab[idx]);

		/* user space needs typically to use a bit of the memory. */
		memset(work_set, idx, WORKING_SET_SIZE);

		tab[idx] = socket(AF_INET, SOCK_STREAM | skflags, 0);
		if (tab[idx] == -1) {
			perror("socket");
			break;
		}
		iter++;
	}
	for (i = 0; i < max; i++)
		close(tab[idx]);
	free(tab);
	free(work_set);
	printf("%lu\n", iter);
	return NULL;
}

static int launch_threads(void)
{
	int i, err;

	for (i = 0; i < nbthreads_req; i++) {
		err = pthread_create(&tid[i], NULL, child_function, NULL);
		if (err)
			return err;
		nbthreads++;
	}
	return 0;
}

static void wait_end(void)
{
	int i;
	for (i = 0; i < nbthreads; i++)
		pthread_join(tid[i], NULL);
}

static void usage(int code)
{
	fprintf(stderr, "Usage : opensock [ -n fds_count ] [ -t threads_count] [-f]\n");
	exit(code);
}

int main(int argc, char *argv[])
{
	int c;
	int max = 1000000;
	int duration = 10;

	while ((c = getopt(argc, argv, "fn:t:l:")) != -1) {
		switch (c) {
		case 'f':
			skflags = SOCK_FD_FASTALLOC;
			break;
		case 'n':
			max = atoi(optarg);
			break;
		case 't':
			nbthreads_req = atoi(optarg);
			if (nbthreads_req > NBTHREADS_MAX)
				usage(1);
			break;
		case 'l':
			duration = atoi(optarg);
			break;
		default:
			usage(1);
		}
	}
	system("sysctl -w fs.file-max=8000000");
	expand_fd_array(max);
	launch_threads();
	sleep(duration);
	stop_all = 1;
	wait_end();
}


