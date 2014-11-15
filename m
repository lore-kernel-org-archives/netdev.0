From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 16:06:23 -0800
Message-ID: <CA+mtBx9Z33O0x4-MG=66Fb4qvBJfxV54xOyiYvWydr=4Bka2xw@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
	<CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
	<1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
	<CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
	<CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
	<CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
	<CA+mtBx9dSNOD5Z8GinU8F1mj_PgU0sTC5g8S9vRuSnSUzAoD=g@mail.gmail.com>
	<CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 2:10 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Nov 14, 2014 at 1:36 PM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> On Fri, Nov 14, 2014 at 12:34 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>> On Fri, Nov 14, 2014 at 12:25 PM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>>> On Fri, Nov 14, 2014 at 12:16 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>>> On Fri, Nov 14, 2014 at 11:52 AM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>>>>> On Fri, Nov 14, 2014 at 11:33 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>>> On Fri, 2014-11-14 at 09:17 -0800, Andy Lutomirski wrote:
>>>>>>>
>>>>>>>> As a heavy user of RFS (and finder of bugs in it, too), here's my
>>>>>>>> question about this API:
>>>>>>>>
>>>>>>>> How does an application tell whether the socket represents a
>>>>>>>> non-actively-steered flow?  If the flow is subject to RFS, then moving
>>>>>>>> the application handling to the socket's CPU seems problematic, as the
>>>>>>>> socket's CPU might move as well.  The current implementation in this
>>>>>>>> patch seems to tell me which CPU the most recent packet came in on,
>>>>>>>> which is not necessarily very useful.
>>>>>>>
>>>>>>> Its the cpu that hit the TCP stack, bringing dozens of cache lines in
>>>>>>> its cache. This is all that matters,
>>>>>>>
>>>>>>>>
>>>>>>>> Some possibilities:
>>>>>>>>
>>>>>>>> 1. Let SO_INCOMING_CPU fail if RFS or RPS are in play.
>>>>>>>
>>>>>>> Well, idea is to not use RFS at all. Otherwise, it is useless.
>>>>>
>>>>> Sure, but how do I know that it'll be the same CPU next time?
>>>>>
>>>>>>>
>>>>>> Bear in mind this is only an interface to report RX CPU and in itself
>>>>>> doesn't provide any functionality for changing scheduling, there is
>>>>>> obviously logic needed in user space that would need to do something.
>>>>>>
>>>>>> If we track the interrupting CPU in skb, the interface could be easily
>>>>>> extended to provide the interrupting CPU, the RPS CPU (calculated at
>>>>>> reported time), and the CPU processing transport (post steering which
>>>>>> is what is currently returned). That would provide the complete
>>>>>> picture to control scheduling a flow from userspace, and an interface
>>>>>> to selectively turn off RFS for a socket would make sense then.
>>>>>
>>>>> I think that a turn-off-RFS interface would also want a way to figure
>>>>> out where the flow would go without RFS.  Can the network stack do
>>>>> that (e.g. evaluate the rx indirection hash or whatever happens these
>>>>> days)?
>>>>>
>>>> Yes,. We need the rxhash and the CPU that packets are received on from
>>>> the device for the socket. The former we already have, the latter
>>>> might be done by adding a field to skbuff to set received CPU. Given
>>>> the L4 hash and interrupting CPU we can calculated the RPS CPU which
>>>> is where packet would have landed with RFS off.
>>>
>>> Hmm.  I think this would be useful for me.  It would *definitely* be
>>> useful for me if I could pin an RFS flow to a cpu of my choice.
>>>
>> Andy, can you elaborate a little more on your use case. I've thought
>> several times about an interface to program the flow table from
>> userspace, but never quite came up with a compelling use case and
>> there is the security concern that a user could "steal" cycles from
>> arbitrary CPUs.
>
> I have a bunch of threads that are pinned to various CPUs or groups of
> CPUs.  Each thread is responsible for a fixed set of flows.  I'd like
> those flows to go to those CPUs.
>
> RFS will eventually do it, but it would be nice if I could
> deterministically ask for a flow to be routed to the right CPU.  Also,
> if my thread bounces temporarily to another CPU, I don't really need
> the flow to follow it -- I'd like it to stay put.
>
Okay, how about it we have a SO_RFS_LOCK_FLOW sockopt. When this is
called on a socket we can lock the socket to CPU binding to the
current CPU it is called from. It could be unlocked at a later point.
Would this satisfy your requirements?

> This has a significant benefit over using automatic steering: with
> automatic steering, I have to make all of the hash tables have a size
> around the square of the total number of the flows in order to make it
> reliable.
>
> Something like SO_STEER_TO_THIS_CPU would be fine, as long as it
> reported whether it worked (for my diagnostics).
>
>>
>>> With SO_INCOMING_CPU as described, I'm worried that people will write
>>> programs that perform very well if RFS is off, but that once that code
>>> runs with RFS on, weird things could happen.
>>>
>>> (On a side note: the RFS flow hash stuff seems to be rather buggy.
>>> Some Solarflare engineers know about this, but a fix seems to be
>>> rather slow in the works.  I think that some of the bugs are in core
>>> code, though.)
>>
>> This is problems with accelerated RFS or just getting the flow hash for packets?
>
> Accelerated RFS.
>
> Digging through my email, I thought that
> net.core.rps_sock_flow_entries != the per-queue rps_flow_cnt would
> make no sense, although I haven't configured it that way.
>
> More importantly, though, I think that some of the has table stuff is
> problematic.  My understanding is:
>
> get_rps_cpu may call set_rps_cpu, passing rflow =
> flow_table->flows[hash & flow_table->mask];
>
> set_rps_cpu will compute flow_id = hash & flow_table->mask, which
> looks to me like it has the property that rflow == flow_table[hash]
> (unless we race with a hash table resize).
>
> Now set_rps_cpu tries to steer the new flow to the right CPU (all good
> so far), but then it gets weird.  We have a very high probability of
> old_flow == rflow.  rflow->filter gets overwritten with the filter id,
> the if condition doesn't execute, and nothing gets set to
> RPS_NO_FILTER.
>
> This is technically all correct, but if there are two active flows
> with the same hash, they'll each keep getting steered to the same
> place.  This wastes cycles and seems to anger the sfc driver (the
> latter is presumably an sfc bug).  It also means that some of the
> filters are likely to get expired for no good reason.
>
Yes, I could see where persistent hash collisions could cause an issue
with aRFS. IIRC, I saw programming the filters to be quite an
expensive operation. Minimally if seems like there some rate limiting
change to avoid hysteresis.

> Also, shouldn't ndo_rx_flow_steer be passed the full hash, not just
> the index into the hash table?  What's the point of cutting off the
> high bits?
>
In order to make aRFS transparent to the user, it was implemented to
be driven from the RFS table which hashes based on the mask so that is
why it is limited. An alternative would be to program the filters
directly from a socket using the full hash, that interface might
already exist in ntuple filtering I suppose.

> --Andy
>
> --Andy
