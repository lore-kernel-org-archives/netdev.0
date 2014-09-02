From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Tue, 02 Sep 2014 14:31:53 +0800
Message-ID: <54056459.4060100@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>	 <1408683665.5648.69.camel@marge.simpson.net>	 <20140822073653.GA7372@gmail.com> <53F70887.8030602@redhat.com> <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com> <53FB3715.7070009@linux.intel.com> <53FC3466.8000304@redhat.com> <5404186E.4090409@linux.intel.com> <54053AF8.6070907@redhat.com> <54055D9F.7000108@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	"Ingo Molnar jacob.e.keller@intel.com" <mingo@elte.hu>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54055D9F.7000108@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/2014 02:03 PM, Eliezer Tamir wrote:
> On 02/09/2014 06:35, Jason Wang wrote:
>> On 09/01/2014 02:55 PM, Eliezer Tamir wrote:
>>> On 26/08/2014 10:16, Jason Wang wrote:
>>>> On 08/25/2014 09:16 PM, Eliezer Tamir wrote:
>>> Think about the case where two processes are busy polling on the
>>> same CPU and the same device queue. Since busy polling processes
>>> incoming packets on the queue from any process, this scenario works
>>> well currently,
>> I see, but looks like we can simply do this by exiting the busy loop
>> when ndo_busy_poll() finds something but not for current socket?
> I don't think there is a need for that.
>
> When ndo_busy_poll() finds something it feeds it to the stack, which
> will process the packet, just as if it came from NAPI polling.
> So, if this is data that someone is blocked waiting on, the stack will
> wake them up, and then you presumably can decide which app should get
> the cpu.

Yes, but current code can not do this. In most of the cases, the new
woke up process have no chance to run if another process is busy loop in
the same cpu.
>
> Note, that there is no easy way to know, when looking at the
> incoming traffic, whether it is important, or even if you are seeing
> a full message. (Maybe you only have 9 packets out of 10?)
> The only place this knowledge might exist is in the layers of the
> stack closer to the user.
>
>>>  and will not work at all when polling yields to other
>>> processes that are of the same priority that are running on the same
>>> CPU.
>>> Maybe the networking subsystem should maintain a list of device
>>> queues that need busypolling and have a thread that would poll
>>> all of them when there's nothing better to do.
>> Not sure whether this method will scale considering thousands of sockets
>> and processes.
> There may be millions of sockets, but in most cases only a handful of
> device queues per CPU to busy poll on. I have tested the epoll rfc
> code with hundreds of thousands of sockets and one or two device
> queues and is scales pretty well.
>
> The part I don't like in that code is the cumbersome mechanism I used
> to track the socket -> queue relationship. I think that if I had more
> time to work on it, I would instead look into extending the epoll
> interface so that libevent can tell the kernel what it wants, instead
> of having the busypoll code try and learn it.

I'd like to have a look at this rfc. Could you please give me a pointer?
I've done a quick search on kernel mailing list but didn't find it.

Thanks
>
> Cheers,
> Eliezer
