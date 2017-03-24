From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 8/8] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 23 Mar 2017 17:58:47 -0700
Message-ID: <CAKgT0UcHJVycQ3+h09L2Ph=TVncqHPJ6dZpicUgBo7TaFTN7yw@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
 <20170323213802.12615.58216.stgit@localhost.localdomain> <CALCETrUD_+JcoAd7Z5+E+fNgeLOy=6-DYOoaRDWDViYd=dWQ=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Samudrala, Sridhar" <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrUD_+JcoAd7Z5+E+fNgeLOy=6-DYOoaRDWDViYd=dWQ=A@mail.gmail.com>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 3:43 PM, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Thu, Mar 23, 2017 at 2:38 PM, Alexander Duyck
> <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> From: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>>
>> This socket option returns the NAPI ID associated with the queue on which
>> the last frame is received. This information can be used by the apps to
>> split the incoming flows among the threads based on the Rx queue on which
>> they are received.
>>
>> If the NAPI ID actually represents a sender_cpu then the value is ignored
>> and 0 is returned.
>
> This may be more of a naming / documentation issue than a
> functionality issue, but to me this reads as:
>
> "This socket option returns an internal implementation detail that, if
> you are sufficiently clueful about the current performance heuristics
> used by the Linux networking stack, just might give you a hint as to
> which epoll set to put the socket in."  I've done some digging into
> Linux networking stuff, but not nearly enough to have the slighest
> clue what you're supposed to do with the NAPI ID.

Really the NAPI ID is an arbitrary number that will be unique per
device queue, though multiple Rx queues can share a NAPI ID if they
are meant to be processed in the same call to poll.

If we wanted we could probably rename it to something like Device Poll
Identifier or Device Queue Identifier, DPID or DQID, if that would
work for you.  Essentially it is just a unique u32 value that should
not identify any other queue in the system while this device queue is
active.  Really the number itself is mostly arbitrary, the main thing
is that it doesn't change and uniquely identifies the queue in the
system.

> It would be nice to make this a bit more concrete and a bit less tied
> in Linux innards.  Perhaps a socket option could instead return a hint
> saying "for best results, put this socket in an epoll set that's on
> cpu N"?  After all, you're unlikely to do anything productive with
> busy polling at all, even on a totally different kernel
> implementation, if you have more than one epoll set per CPU.  I can
> see cases where you could plausibly poll with fewer than one set per
> CPU, I suppose.

Really we kind of already have an option that does what you are
implying called SO_INCOMING_CPU.  The problem is it requires pinning
the interrupts to the CPUs in order to keep the values consistent, and
even then busy polling can mess that up if the busy poll thread is
running on a different CPU.  With the NAPI ID we have to do a bit of
work on the application end, but we can uniquely identify each
incoming queue and interrupt migration and busy polling don't have any
effect on it.  So for example we could stack all the interrupts on CPU
0, and have our main thread located there doing the sorting of
incoming requests and handing them out to epoll listener threads on
other CPUs.  When those epoll listener threads start doing busy
polling the NAPI ID won't change even though the packet is being
processed on a different CPU.

> Again, though, from the description, it's totally unclear what a user
> is supposed to do.

What you end up having to do is essentially create a hash of sorts so
that you can go from NAPI IDs to threads.  In an ideal setup what you
end up with multiple threads, each one running one epoll, and each
epoll polling on one specific queue.

Hope that helps to clarify it.

- Alex
