From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Mon, 10 Aug 2015 06:51:07 -0400
Message-ID: <CAOrge3pSQ7eck14biTncjOyGD-DKY0DvRr7JKpS3BowoSDry-Q@mail.gmail.com>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
 <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com>
 <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
 <55C3B8C8.9030507@redhat.com> <CAOrge3oRWUfdMjDgH8PSY_5Y8=KKv2Cr9T3ZLXvuNx6_eq7g0Q@mail.gmail.com>
 <55C4D803.3090108@redhat.com> <878u9njaon.fsf@stressinduktion.org>
 <CAOrge3qxOb_XrspuvYjV0pDDxUUoqGE3690KUQGoxZMxuD-NRQ@mail.gmail.com>
 <CAOrge3q16PRh3TEBaGUeYDhLzWhCCytn+sopTzBr_23cj1gmaw@mail.gmail.com> <878u9jijuc.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878u9jijuc.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here comes several options:

1. reject local next hop w/ EINVAL
2. delete route when local next hop removed
3. transition between RT_SCOPE_HOST amd RT_SCOPE_LINK
4. document it

which one should we choose ?

1 will definitely cause compatibility problem
2 is the easiest solution
3 need a bit of code, not sure if worth it

On Mon, Aug 10, 2015 at 5:16 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,
>
> Zang MingJie <zealot0630@gmail.com> writes:
>> Days ago I mistakenly set the gateway address on my box, then add the
>> default router, after I deleted the address my box can't access
>> Internet and all things looks fine. It takes me several hours to
>> figure out it is an kernel bug.
>
> I don't consider this a kernel bug.
>
>>>On Sat, Aug 8, 2015, 1:00 AM Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>>>If we could rewind time, we could make local nexthops -EINVAL.
>>
>> I don't think this is the proper solution. As almost all network OS
>> considers the routing table recursive, and it's next hop can be any
>> unicast ip address.
>
> You are talking about ios, junos, no?
>
> Linux does not have any kind of recursive routing table. It only helps
> by doing a first-hop lookup during insertion time, that's merely it. If
> you want to compare Linux to a "network OS" you would have to install
> quagga/bird/xorp/... on a box to get the same behavior.
>
> Also notice that we don't talk about adding/removing addresses to
> interfaces but what the routing code considers are the routes which get
> created because of those address changes (like the subnet route added in
> IPv4 if you install an address with subnet on an interface). Thus we
> shouldn't make address changes special, we would have to reevaluate the
> complete FIB/routing-table (I guess everyone is talking about something
> different here) at the time we only change a route. And this is a no-go.
>
> I don't see a problem with adding a "recursive routing table" to the
> stack if people need that. I just don't see the need for that.
>
>> When the next hop is unreachable the entry won't be installed.
>
> In a recursive routing table, the entry could be installed but it will
> only get into effect when the nexthop turns reachable.
>
>> I suggest adding a new sysconf entry, when not set, behavior as the
>> same as now, when set recalculate the fib when necessary
>
> A new sysctl would work, but I don't consider it necessary. I don't
> think we need the additional code for that. Kernel does not run routing
> protocols and those are normally the only ones which need to do that.
>
>> BTW is there any way to check the fib table?
>
> I don't understand the question. Do you mean
>
> ip route get xx.yy.zz.aa ?
>
> Bye,
> Hannes
