From: Eric Dumazet <edumazet@google.com>
Subject: Re: [net-next PATCH v2 8/8] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 23 Mar 2017 22:07:21 -0700
Message-ID: <CANn89iKt8D0O87jt0zMLU+hMX2i9ZQO2ybHvsF_BKJO86mOdNg@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
 <20170323213802.12615.58216.stgit@localhost.localdomain> <CALCETrUD_+JcoAd7Z5+E+fNgeLOy=6-DYOoaRDWDViYd=dWQ=A@mail.gmail.com>
 <CAKgT0UcHJVycQ3+h09L2Ph=TVncqHPJ6dZpicUgBo7TaFTN7yw@mail.gmail.com> <CALCETrU+SfDAj4dzjtRCkRULa+NDcceM8ZYWg=dDMXkv5-Z3-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrU+SfDAj4dzjtRCkRULa+NDcceM8ZYWg=dDMXkv5-Z3-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 9:47 PM, Andy Lutomirski <luto@kernel.org> wrote:

> So don't we want queue id, not NAPI id?  Or am I still missing something?
>
> But I'm also a but confused as to the overall performance effect.
> Suppose I have an rx queue that has its interrupt bound to cpu 0.  For
> whatever reason (random chance if I'm hashing, for example), I end up
> with the epoll caller on cpu 1.  Suppose further that cpus 0 and 1 are
> on different NUMA nodes.
>
> Now, let's suppose that I get lucky and *all* the packets are pulled
> off the queue by epoll busy polling.  Life is great [1].  But suppose
> that, due to a tiny hiccup or simply user code spending some cycles
> processing those packets, an rx interrupt fires.  Now cpu 0 starts
> pulling packets off the queue via NAPI, right?  So both NUMA nodes are
> fighting over all the cachelines involved in servicing the queue *and*
> the packets just got dequeued on the wrong NUMA node.
>
> ISTM this would work better if the epoll busy polling could handle the
> case where one epoll set polls sockets on different queues as long as
> those queues are all owned by the same CPU.  Then user code could use
> SO_INCOMING_CPU to sort out the sockets.
>

Of course you can do that already.

SO_REUSEPORT + appropriate eBPF filter can select the best socket to
receive your packets, based
on various smp/numa affinities ( BPF_FUNC_get_smp_processor_id or
BPF_FUNC_get_numa_node_id )

This new instruction is simply _allowing_ other schems, based on
queues ID, in the case each NIC queue
can be managed by a group of cores (presumably on same NUMA node)


> Am I missing something?
>
> [1] Maybe.  How smart is direct cache access?  If it's smart enough,
> it'll pre-populate node 0's LLC, which means that life isn't so great
> after all.
