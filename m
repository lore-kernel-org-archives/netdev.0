From: yaniv saar <yaniv.mellanox@gmail.com>
Subject: Re: [PATCH RFC] net: lls epoll support
Date: Tue, 25 Jun 2013 17:26:02 +0300
Message-ID: <CALuTh9E5CvV1sfjMJRs7mWwfTm2HpaFFMJWEP10sbSpA8qBMsg@mail.gmail.com>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
	<51C1993C.9030204@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C1993C.9030204@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 2:42 PM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
> This is a wild hack, just as a POC to show the power or LLS with epoll.
>
> We assume that we only ever need to poll on one device queue,
> so the first FD that reports POLL_LL gets saved aside so we can poll on.
>
> While this assumption is wrong in so many ways, it's very easy to satisfy
> with a micro-benchmark.
>
> [this patch needs the poll patch to be applied first]
> with sockperf doing epoll on 1000 sockets I see an avg latency of 6us
>

hi eliezer,

please consider the following solution for epoll that is based on
polling dev+queue.
instead of looping over the socket as in LLS, maintain in eventpool
struct a list of device+queues (qdlist).
the dqlist must be unique w.r.t. device+queue, (no two identical
device+queues items in qdlist).
each device+queues item (qditem) holds:
* device (id)
* queue (id)
* list of epi (epilist) that created this qditem
- I think it won't be possible to extend epitem (breaks cache aligned
to 128)... instead you can have a simple ll_usec list.
* ll_usec, the maximum time to poll from all the referring epi items.
finally, polling should iterate over the qdlist once, and then check for events.

----
as far as coding this sketch involves:
1) adjust eventpoll struct.
2) initialize on creation (epoll_create)
3) update the list on modification (epoll_ctl)
3.1) ep_insert->add this epi/ll_usec in relevant qditem (or create new
one), and update qditem->ll_usec
3.2) ep_remove->remove this epi/ll_usec from relevant qditem (MUST be
existing -- sort of ref counting), and update qditem->ll_usec
3.3) ep_modify->...
4) on polling event (epoll_wait)
ep_poll->if qdlist is not empty, then find the maximum ll_usec (could
be done while maintaining...)
... and just before going into wait ...
if max ll_usec!=0
    poll once on all device+queues in the qdlist.
    continue to the next iteration (check events).
5) to support this flow we also need to implement API for
5.1) given a file/fd/epi, if is a sock then get the device+queue.
5.2) poll over a given device+queue (dq_poll_ll) once.
