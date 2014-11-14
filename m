From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 12:34:26 -0800
Message-ID: <CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
 <CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
 <1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
 <CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com> <CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 12:25 PM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Nov 14, 2014 at 12:16 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Fri, Nov 14, 2014 at 11:52 AM, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>> On Fri, Nov 14, 2014 at 11:33 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>> On Fri, 2014-11-14 at 09:17 -0800, Andy Lutomirski wrote:
>>>>
>>>>> As a heavy user of RFS (and finder of bugs in it, too), here's my
>>>>> question about this API:
>>>>>
>>>>> How does an application tell whether the socket represents a
>>>>> non-actively-steered flow?  If the flow is subject to RFS, then moving
>>>>> the application handling to the socket's CPU seems problematic, as the
>>>>> socket's CPU might move as well.  The current implementation in this
>>>>> patch seems to tell me which CPU the most recent packet came in on,
>>>>> which is not necessarily very useful.
>>>>
>>>> Its the cpu that hit the TCP stack, bringing dozens of cache lines in
>>>> its cache. This is all that matters,
>>>>
>>>>>
>>>>> Some possibilities:
>>>>>
>>>>> 1. Let SO_INCOMING_CPU fail if RFS or RPS are in play.
>>>>
>>>> Well, idea is to not use RFS at all. Otherwise, it is useless.
>>
>> Sure, but how do I know that it'll be the same CPU next time?
>>
>>>>
>>> Bear in mind this is only an interface to report RX CPU and in itself
>>> doesn't provide any functionality for changing scheduling, there is
>>> obviously logic needed in user space that would need to do something.
>>>
>>> If we track the interrupting CPU in skb, the interface could be easily
>>> extended to provide the interrupting CPU, the RPS CPU (calculated at
>>> reported time), and the CPU processing transport (post steering which
>>> is what is currently returned). That would provide the complete
>>> picture to control scheduling a flow from userspace, and an interface
>>> to selectively turn off RFS for a socket would make sense then.
>>
>> I think that a turn-off-RFS interface would also want a way to figure
>> out where the flow would go without RFS.  Can the network stack do
>> that (e.g. evaluate the rx indirection hash or whatever happens these
>> days)?
>>
> Yes,. We need the rxhash and the CPU that packets are received on from
> the device for the socket. The former we already have, the latter
> might be done by adding a field to skbuff to set received CPU. Given
> the L4 hash and interrupting CPU we can calculated the RPS CPU which
> is where packet would have landed with RFS off.

Hmm.  I think this would be useful for me.  It would *definitely* be
useful for me if I could pin an RFS flow to a cpu of my choice.

With SO_INCOMING_CPU as described, I'm worried that people will write
programs that perform very well if RFS is off, but that once that code
runs with RFS on, weird things could happen.

(On a side note: the RFS flow hash stuff seems to be rather buggy.
Some Solarflare engineers know about this, but a fix seems to be
rather slow in the works.  I think that some of the bugs are in core
code, though.)

--Andy

>
>>>
>>>> RFS is the other way around : You want the flow to follow your thread.
>>>>
>>>> RPS wont be a problem if you have sensible RPS settings.
>>>>
>>>>>
>>>>> 2. Change the interface a bit to report the socket's preferred CPU
>>>>> (where it would go without RFS, for example) and then let the
>>>>> application use setsockopt to tell the socket to stay put (i.e. turn
>>>>> off RFS and RPS for that flow).
>>>>>
>>>>> 3. Report the preferred CPU as in (2) but let the application ask for
>>>>> something different.
>>>>>
>>>>> For example, I have flows for which I know which CPU I want.  A nice
>>>>> API to put the flow there would be quite useful.
>>>>>
>>>>>
>>>>> Also, it may be worth changing the naming to indicate that these are
>>>>> about the rx cpu (they are, right?).  For some applications (sparse,
>>>>> low-latency flows, for example), it can be useful to keep the tx
>>>>> completion handling on a different CPU.
>>>>
>>>> SO_INCOMING_CPU is rx, like incoming ;)
>>>>
>>>>
>>
>> Duh :)
>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>> --
>> Andy Lutomirski
>> AMA Capital Management, LLC



-- 
Andy Lutomirski
AMA Capital Management, LLC
