From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH RFC] net: lls epoll support
Date: Tue, 25 Jun 2013 18:34:36 +0300
Message-ID: <51C9B88C.1080401@linux.intel.com>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com> <51C1993C.9030204@linux.intel.com> <CALuTh9E5CvV1sfjMJRs7mWwfTm2HpaFFMJWEP10sbSpA8qBMsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: yaniv saar <yaniv.mellanox@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALuTh9E5CvV1sfjMJRs7mWwfTm2HpaFFMJWEP10sbSpA8qBMsg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/06/2013 17:26, yaniv saar wrote:
> On Wed, Jun 19, 2013 at 2:42 PM, Eliezer Tamir
> <eliezer.tamir@linux.intel.com> wrote:
>>
>> [this patch needs the poll patch to be applied first]
>> with sockperf doing epoll on 1000 sockets I see an avg latency of 6us
>>
>
> hi eliezer,
>
> please consider the following solution for epoll that is based on
> polling dev+queue.
> instead of looping over the socket as in LLS, maintain in eventpool
> struct a list of device+queues (qdlist).

Thanks for looking into this.
I'm currently working on a solution that has a lot similar to what you 
are proposing.

We don't need a new id mechanism, we already have the napi_id.
The nice thing about the napi_id is that the only locking it needs
is an rcu_read_lock when dereferencing.

we don't need to remember the ll_usec value of each socket because
the patch for select/poll (currently waiting for review) added
a separate sysctl value for poll.

I would like to find a way for the user to specify how long to busy
wait, directly from the system call, but I was not able to find
a simple way of adding this without a change to the system call
prototype.

we do however need to track when a socket's napi_id changes.
But for that we can hook into sk_mark_ll().

so here is a list of proposed changes:

1. add a linked list of unique napi_id's to struct eventpoll.
each id will have a collision list of sockets that have the same id.
-a hash is gratuitous, we expect the unique list to have 0 to 2
  elements in most cases.

2. when a new socket is added, if its id is new it gets added to the 
unique list, otherwise to the collision list of that id.

3. when a socket is removed, if it's on the unique list, replace it
with the first on its former collision list.

4. add callback mechanism to sk_mark_ll() which will be activated when
  the mark changes, update the lists.
(a socket may be polled by more than one epoll so be careful)

5. add  and remove to/from the lists in ep_insert and ep_remove
  respectively. check if we need to do something for ep_modify().

6. add an ep_poll helper that will round robin polling on the
files in the unique list.

7. init everything from epoll_create.

locking:

napi_id's are great since they don't need locking except for an
rcu_read_lock when polling on one.

the lists need a spinlock for adding/removing, maybe they
can use ep->lock.

callback registration/removal needs to use the same mechanism that
ep_add / ep_remove use to protect themselves from the rest of epoll.
