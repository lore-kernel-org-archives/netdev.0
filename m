From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: New module infrastructure for net_proto_family
Date: Tue, 29 Apr 2003 16:39:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030429162447.10da83c8@unixmail.qualcomm.com>
References: <5.1.0.14.2.20030429103638.10bf0a00@unixmail.qualcomm.com>
 <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com>
 <20030424230202.GB2931@conectiva.com.br>
 <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
 <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
 <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com>
 <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com>
 <5.1.0.14.2.20030429103638.10bf0a00@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030429215557.GA30222@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 02:55 PM 4/29/2003, Arnaldo Carvalho de Melo wrote:
>Em Tue, Apr 29, 2003 at 12:21:49PM -0700, Max Krasnyansky escreveu:
>
>> That can probably be done. But what happened to "protocol writers don't have
>> to worry about this issues" ideas though ;-) ?
>
>They don't, unless they want to have its own infrastructure for loading modules
>for each specific protocol, look at all the net families that don't do that
>(i.e. all, except pppox and bluetooth, and perhaps ipv4 in the future, but as
>you said, this is not accepted by DaveM).
Hold on. That was my argument in favor of sk_set_owner() thing. 
I thought the goal was to make it easier in all cases.

>And look at the pppox implementation, it didn't needed any changes to the
>struct sock protinfo/private slab cache, and removed code in the protocol
>module.
But it introduced overhead in sk allocation/deallocation (read me rsp in pppox thread). 

>> The other thing that I don't like is that to create one socket we'd have to
>> call whole bunch of functions to take care of the module refcounting.  So I
>> want to bring these questions again: 
>
>> - Why do we have to bump module refcount for 'struct sock' with _default_ callbacks ?
>
>Because we don't assume they won't use its own callbacks.
And what I'm saying is that if we make this assumption we can save some overhead during
socket allocation/deallocation because we don't have to track those sks.

>> My answer is that we don't have to. I'd even say that we shouldn't. Module is not 
>> referenced from struct sock in that case.
>
>> - Why are we not allowing net_family unregistration until all family sockets
>> are gone ?  From what I see it's only because current code does
>> 'module_put(net_families[family]->owner)'.  I'm saying that we don't care
>> whether net_family is registered or not if we know who owns the socket (i.e.
>> sock->owner).
>
>but then we move the overhead to _all_ struct sock, overhead (memory) that is
>present at all times, not just at sock creation/destruction time.
Like I said we can easily make space for ->owner in the struct sk (kill one of the 
pprev, prev, bind_prev, etc fields). IMO overhead of calling more function for socket 
allocation/dealocation is greater.

>> So my point is yes we can make families to implement their own infrastructure
>> for module refcounting. But the solution is going to be more complicated than
>> just having sock->owner and sk->owner fields and allowing for ownership
>> transfers.
>
>Have you seen the pppox implementation? It even simplified some things at the
>protocol level at the expense of adding just one new exported function at the
>net family level and some cost at the struct sock creation/destruction time.
>
>And this by making use of the existing infrastructure to achieve its goals: to
>have per protocol modules. And, again, the pppoe protocol module was
>simplified.
I'll comment on that on in pppox thread.

Max
