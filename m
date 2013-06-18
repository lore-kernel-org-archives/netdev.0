From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: poll/select low latency socket support
Date: Tue, 18 Jun 2013 03:25:39 -0700
Message-ID: <1371551139.3252.249.camel@edumazet-glaptop>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>
	 <20130618085810.10941.55039.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130618085810.10941.55039.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-18 at 11:58 +0300, Eliezer Tamir wrote:
> select/poll busy-poll support.
> 
> Add a new poll flag POLL_LL. When this flag is set, sock poll will call
> sk_poll_ll() if possible. sock_poll sets this flag in its return value
> to indicate to select/poll when a socket that can busy poll is found.
> 
> When poll/select have nothing to report, call the low-level
> sock_poll() again until we are out of time or we find something.
> 
> Once the system call finds something, it stops setting POLL_LL, so it can
> return the result to the user ASAP.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Is the right order ? 

It seems you wrote the patch, not Alexander or Jesse ?

They might Ack it eventually.

> ---
> 
>  fs/select.c                     |   40 +++++++++++++++++++++++++++++++++++++--
>  include/net/ll_poll.h           |   34 +++++++++++++++++++++------------
>  include/uapi/asm-generic/poll.h |    2 ++
>  net/socket.c                    |   14 +++++++++++++-
>  4 files changed, 75 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/select.c b/fs/select.c
> index 8c1c96c..1d081f7 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -27,6 +27,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/hrtimer.h>
>  #include <linux/sched/rt.h>
> +#include <net/ll_poll.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -393,6 +394,15 @@ static inline void wait_key_set(poll_table *wait, unsigned long in,
>  		wait->_key |= POLLOUT_SET;
>  }
>  
> +static inline void wait_key_set_lls(poll_table *wait, bool set)
> +{
> +	if (set)
> +		wait->_key |= POLL_LL;
> +	else
> +		wait->_key &= ~POLL_LL;
> +}
> +

Instead of "bool set" you could use "unsigned int lls_bit"

and avoid conditional :

wait->_key |= lls_bit;

(you do not need to clear the bit in wait->_key, its already cleared in
wait_key_set())

Alternatively, add a parameter to wait_key_set(), it will be cleaner

> +
>  int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  {
>  	ktime_t expire, *to = NULL;
> @@ -400,6 +410,9 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  	poll_table *wait;
>  	int retval, i, timed_out = 0;
>  	unsigned long slack = 0;
> +	u64 ll_time = ll_end_time();
> +	bool try_ll = true;

	unsigned int lls_bit = POLL_LL;

> +	bool can_ll = false;
>  
>  	rcu_read_lock();
>  	retval = max_select_fd(n, fds);
> @@ -450,6 +463,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  					mask = DEFAULT_POLLMASK;
>  					if (f_op && f_op->poll) {
>  						wait_key_set(wait, in, out, bit);
> +						wait_key_set_lls(wait, try_ll);
>  						mask = (*f_op->poll)(f.file, wait);
>  					}
>  					fdput(f);
> @@ -468,6 +482,10 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  						retval++;
>  						wait->_qproc = NULL;
>  					}
> +					if (retval)
> +						try_ll = false;
			if (retval)
				lls_bit = 0;

> +					if (mask & POLL_LL)
> +						can_ll = true;

			can_ll |= (mask & POLL_LL);

>  				}
>  			}
>  			if (res_in)
> @@ -486,6 +504,11 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  			break;
>  		}
>  
> +		if (can_poll_ll(ll_time) && can_ll) {

	reorder tests to avoid sched_clock() call :

		if (can_ll && can_poll_ll(ll_time))

> +			can_ll = false;
> +			continue;
> +		}
> +
>  		/*
>  		 * If this is the first loop and we have a timeout
>  		 * given, then we convert to ktime_t and set the to
> @@ -717,7 +740,8 @@ struct poll_list {
>   * pwait poll_table will be used by the fd-provided poll handler for waiting,
>   * if pwait->_qproc is non-NULL.
>   */
> -static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
> +static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
> +					bool *can_ll, bool try_ll)
>  {
>  	unsigned int mask;
>  	int fd;
> @@ -731,7 +755,11 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
>  			mask = DEFAULT_POLLMASK;
>  			if (f.file->f_op && f.file->f_op->poll) {
>  				pwait->_key = pollfd->events|POLLERR|POLLHUP;
> +				if (try_ll)
> +					pwait->_key |= POLL_LL;

Well, why enforce POLL_LL ? 

Sure we do this for select() as the API doesn't allow us to add the LL
flag, but poll() can do that.

An application might set POLL_LL flag only on selected fds.

I understand you want nice benchmarks for existing applications,
but I still think that globally enable/disable LLS for the whole host
is not a good thing.

POLL_LL wont be a win once we are over committing cpus (too many sockets
to poll)


>  				mask = f.file->f_op->poll(f.file, pwait);
> +				if (mask & POLL_LL)
> +					*can_ll = true;


>  			}
>  			/* Mask out unneeded events. */
>  			mask &= pollfd->events | POLLERR | POLLHUP;
> @@ -750,6 +778,9 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
>  	ktime_t expire, *to = NULL;
>  	int timed_out = 0, count = 0;
>  	unsigned long slack = 0;
> +	u64 ll_time = ll_end_time();
> +	bool can_ll = false;
> +	bool try_ll = true;
>  
>  	/* Optimise the no-wait case */
>  	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
> @@ -776,9 +807,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
>  				 * this. They'll get immediately deregistered
>  				 * when we break out and return.
>  				 */
> -				if (do_pollfd(pfd, pt)) {
> +				if (do_pollfd(pfd, pt, &can_ll, try_ll)) {
>  					count++;
>  					pt->_qproc = NULL;
> +					try_ll = false;
>  				}
>  			}
>  		}
> @@ -795,6 +827,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
>  		if (count || timed_out)
>  			break;
>  
> +		if (can_poll_ll(ll_time) && can_ll) {

	if (can_ll && ...

> +			can_ll = false;
> +			continue;
> +		}
>  		/*
>  		 * If this is the first loop and we have a timeout
>  		 * given, then we convert to ktime_t and set the to
