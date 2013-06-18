From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next] net: poll/select low latency socket support
Date: Tue, 18 Jun 2013 13:37:18 +0300
Message-ID: <51C0385E.8030403@linux.intel.com>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>  <20130618085810.10941.55039.stgit@ladj378.jer.intel.com> <1371551139.3252.249.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371551139.3252.249.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/06/2013 13:25, Eric Dumazet wrote:
> On Tue, 2013-06-18 at 11:58 +0300, Eliezer Tamir wrote:

>> @@ -393,6 +394,15 @@ static inline void wait_key_set(poll_table *wait, unsigned long in,
>>   		wait->_key |= POLLOUT_SET;
>>   }
>>
>> +static inline void wait_key_set_lls(poll_table *wait, bool set)
>> +{
>> +	if (set)
>> +		wait->_key |= POLL_LL;
>> +	else
>> +		wait->_key &= ~POLL_LL;
>> +}
>> +
>
> Instead of "bool set" you could use "unsigned int lls_bit"
>
> and avoid conditional :
>
> wait->_key |= lls_bit;
>
> (you do not need to clear the bit in wait->_key, its already cleared in
> wait_key_set())
>
> Alternatively, add a parameter to wait_key_set(), it will be cleaner

OK

>> @@ -486,6 +504,11 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>>   			break;
>>   		}
>>
>> +		if (can_poll_ll(ll_time) && can_ll) {
>
> 	reorder tests to avoid sched_clock() call :
>
> 		if (can_ll && can_poll_ll(ll_time))
>

right

>> -static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
>> +static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
>> +					bool *can_ll, bool try_ll)
>>   {
>>   	unsigned int mask;
>>   	int fd;
>> @@ -731,7 +755,11 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
>>   			mask = DEFAULT_POLLMASK;
>>   			if (f.file->f_op && f.file->f_op->poll) {
>>   				pwait->_key = pollfd->events|POLLERR|POLLHUP;
>> +				if (try_ll)
>> +					pwait->_key |= POLL_LL;
>
> Well, why enforce POLL_LL ?
>
> Sure we do this for select() as the API doesn't allow us to add the LL
> flag, but poll() can do that.
>
> An application might set POLL_LL flag only on selected fds.
>
> I understand you want nice benchmarks for existing applications,
> but I still think that globally enable/disable LLS for the whole host
> is not a good thing.
>
> POLL_LL wont be a win once we are over committing cpus (too many sockets
> to poll)

I did not intend POLL_LL to be a user visible flag.
But maybe your way will work better.
Do you think we should also report POLL_LL to the user, so it will know
if there are currently ll capable sockets?
That might be hard to do without breaking the flag semantics,
Since we might not want to wake up the user just to report that.

Also, any suggestion on how not to depend on the global sysctl value for 
poll? (we can't use a socket option here)

-Eliezer
