From: Josef Bacik <jbacik@fb.com>
Subject: Re: TCP stops sending packets over loopback on 4.10-rc3?
Date: Wed, 25 Jan 2017 09:26:48 -0500
Message-ID: <1485354408.5902.3@smtp.office365.com>
References: <1485256853.4014.0@smtp.office365.com>
        <1485266868.16328.292.camel@edumazet-glaptop3.roam.corp.google.com>
        <1485353664.5902.2@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>,
        Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34032 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750998AbdAYO1L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 09:27:11 -0500
In-Reply-To: <1485353664.5902.2@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 9:14 AM, Josef Bacik <jbacik@fb.com> wrote:
> On Tue, Jan 24, 2017 at 9:07 AM, Eric Dumazet 
> <eric.dumazet@gmail.com> wrote:
>> On Tue, 2017-01-24 at 06:20 -0500, Josef Bacik wrote:
>>>  Hello,
>>> 
>>>  I've been trying to test some NBD changes I had made recently and I
>>>  started having packet timeouts.  I traced this down to tcp just
>>>  stopping sending packets after a lot of writing.  All NBD does is 
>>> call
>>>  kernel_sendmsg() with a request struct and some pages when it does
>>>  writes.  I did a bunch of tracing and I've narrowed it down to 
>>> running
>>>  out of sk_wmem_queued space.  In tcp_sendmsg() here
>>> 
>>>  new_segment:
>>>                          /* Allocate new segment. If the interface 
>>> is SG,
>>>                           * allocate skb fitting to single page.
>>>                           */
>>>                          if (!sk_stream_memory_free(sk))
>>>                                  goto wait_for_sndbuf;
>>> 
>>>  we hit this pretty regularly, and eventually just get stuck in
>>>  sk_stream_wait_memory until the timeout ends and we error out
>>>  everything.  Now sk_stream_memory_free checks the sk_wmem_queued 
>>> and
>>>  calls into the sk_prot->stream_memory_free(), so I broke this out 
>>> like
>>>  the following
>>> 
>>> 
>>>      if (sk->sk_wmem_queued >= sk->sk_sndbuf) {
>>>          trace_printk("sk_wmem_queued %d, sk_sndbuf %d\n",
>>>  sk->sk_wmem_queued, sk->sk_sndbuf);
>>>          goto wait_for_sndbuf;
>>>       }
>>>       if (sk->sk_prot->stream_memory_free &&
>>>  !sk->sk_prot->stream_memory_free(sk)) {
>>>          trace_printk("sk_stream_memory_free\n");
>>>          goto wait_for_sndbuf;
>>>       }
>>> 
>>>  And I got this in my tracing
>>> 
>>>     kworker/u16:5-112   [001] ....  1375.637564: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [001] ....  1375.639657: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [003] ....  1375.641128: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [003] ....  1375.643441: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [001] ....  1375.807614: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [001] ....  1377.538744: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [001] ....  1377.543418: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>      kworker/2:4H-1535  [002] ....  1377.544685: tcp_sendmsg:
>>>  sk_wmem_queued 4204872, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [000] ....  1379.378352: tcp_sendmsg:
>>>  sk_wmem_queued 4205796, sk_sndbuf 4194304
>>>     kworker/u16:5-112   [003] ....  1380.985721: tcp_sendmsg:
>>>  sk_wmem_queued 4212416, sk_sndbuf 4194304
>>> 
>>>  This is as far as I've gotten and I'll keep digging into it, but I 
>>> was
>>>  wondering if this looks familiar to anybody?  Also one thing I've
>>>  noticed is sk_stream_wait_memory() will wait on sk_sleep(sk), but
>>>  basically nothing wakes this up.  For example it seems the main 
>>> way we
>>>  reduce sk_wmem_queued is through sk_wmem_free_skb(), which doesn't
>>>  appear to wake anything up in any of its callers, so anybody who 
>>> does
>>>  end up sleeping will basically never wake up.  That seems like it
>>>  should be more broken than it is, so I'm curious to know how 
>>> things are
>>>  actually woken up in this case.  Thanks,
>> 
>> 
>> git grep -n SOCK_QUEUE_SHRUNK
>> 
>> -> tcp_check_space()
> 
> But tcp_check_space() doesn't actually reduce sk_wmem_queued from 
> what I can see.  The only places that appear to reduce it are 
> tcp_trim_head, which is only called in the retransmit path, and 
> sk_wmem_free_skb, which seems to be right, but I added a 
> trace_printk() in it to see if it was firing during my test and it 
> never fires.  So we _appear_ to only ever be incrementing this 
> counter, but never decrementing it.  I'm doing a bunch of tracing 
> trying to figure out what is going on here but so far nothing is 
> popping which is starting to make me think ftrace is broken.  Thanks,

Nope ftrace isn't broken, I'm just dumb, the space is being reclaimed 
by sk_wmem_free_skb().  So I guess I need to figure out why I stop 
getting ACK's from the other side of the loopback.  Thanks,

Josef
