From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: New module infrastructure for net_proto_family
Date: Tue, 29 Apr 2003 18:55:57 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429215557.GA30222@conectiva.com.br>
References: <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com> <20030424230202.GB2931@conectiva.com.br> <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com> <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com> <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com> <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com> <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com> <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com> <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com> <5.1.0.14.2.20030429103638.10bf0a00@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20030429103638.10bf0a00@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Apr 29, 2003 at 12:21:49PM -0700, Max Krasnyansky escreveu:
> At 06:43 PM 4/28/2003, Arnaldo Carvalho de Melo wrote:
> >Em Mon, Apr 28, 2003 at 02:10:11PM -0700, Max Krasnyansky escreveu:

> >> Hmm, no comments on my last email
> >> (http://marc.theaimsgroup.com/?l=linux-netdev&m=105123134301565&w=2) Are
> >> you trying to ignore me too ? ;-)

> >Nope, I was working on the higher layer first, to then come to the net
> >families that are already modular and have per-protocol modules, and I'm
> >starting to look into the only, AFAIK, network family that has this in
> >place: bluetooth :-)

> >Having said that I haven't fully studied this I see two scenarios (brainstorming):

> >1. the net family that wants per protocol "sub" modules "duplicates" the
> >infrastructure having PROTO_sk_alloc and PROTO_destruct (the sk_free
> >sk->destruct hook call), PROTO_sk_alloc uses its net_families equivalent
> >(bt_proto in bluetooth) to find the owner (the "sub" module, i.e. per
> >protocol module) and PROTO_net_family_gets it, then calls sk_alloc proper,
> >and when the last reference to the sock is released the sk->destruct is
> >called (PROTO_destruct) does the PROTO_net_family_put. Ditto for the socket
> >case, where PROTO_create, before calling the ->create of the "sub" module
> >does the PROTO_net_family_get, and at release time its PROTO_release does
> >the same thing that sock_release does. Something like this may well need
> >extra info to be kept at the private area of the proto family in struct sock
> >protinfo or private slab cache.

> That can probably be done. But what happened to "protocol writers don't have
> to worry about this issues" ideas though ;-) ?

They don't, unless they want to have its own infrastructure for loading modules
for each specific protocol, look at all the net families that don't do that
(i.e. all, except pppox and bluetooth, and perhaps ipv4 in the future, but as
you said, this is not accepted by DaveM).

And look at the pppox implementation, it didn't needed any changes to the
struct sock protinfo/private slab cache, and removed code in the protocol
module.

> The other thing that I don't like is that to create one socket we'd have to
> call whole bunch of functions to take care of the module refcounting.  So I
> want to bring these questions again: 

> - Why do we have to bump module refcount for 'struct sock' with _default_ callbacks ?

Because we don't assume they won't use its own callbacks.

> My answer is that we don't have to. I'd even say that we shouldn't. Module is not 
> referenced from struct sock in that case.

> - Why are we not allowing net_family unregistration until all family sockets
> are gone ?  From what I see it's only because current code does
> 'module_put(net_families[family]->owner)'.  I'm saying that we don't care
> whether net_family is registered or not if we know who owns the socket (i.e.
> sock->owner).

but then we move the overhead to _all_ struct sock, overhead (memory) that is
present at all times, not just at sock creation/destruction time.
 
> So my point is yes we can make families to implement their own infrastructure
> for module refcounting. But the solution is going to be more complicated than
> just having sock->owner and sk->owner fields and allowing for ownership
> transfers.

Have you seen the pppox implementation? It even simplified some things at the
protocol level at the expense of adding just one new exported function at the
net family level and some cost at the struct sock creation/destruction time.

And this by making use of the existing infrastructure to achieve its goals: to
have per protocol modules. And, again, the pppoe protocol module was
simplified.
 
> >That is, we have a higher layer for net families, with locking for the whole
> >family done like it is on the tree now and a lower layer at the specific net
> >family, both having the same behaviour at its layers.

> >This option seems to be easy to implement with the current bluetooth
> >infrastructure (i.e. it has a net_families equivalent, it does the switching
> >at bt_create time, etc).

> Well, we already use sk->destruct call back in Bluetooth protocols (each
> proto has its own call back that does different things). I think we should
> not use existing sk call backs for module refcounting.

Look at what I did in pppox, you will still have similar functionality.

- Arnaldo
