From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol modules
Date: Tue, 29 Apr 2003 19:07:46 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429220746.GB30222@conectiva.com.br>
References: <20030428.222728.48508327.davem@redhat.com> <20030429061227.GJ25361@conectiva.com.br> <20030428.222728.48508327.davem@redhat.com> <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, mostrows@speakeasy.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, Apr 29, 2003 at 01:05:08PM -0700, Max Krasnyansky escreveu:
> At 11:54 PM 4/28/2003, Arnaldo Carvalho de Melo wrote:
> >Em Mon, Apr 28, 2003 at 10:27:28PM -0700, David S. Miller escreveu:
> >>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> >>    Date: Tue, 29 Apr 2003 03:12:27 -0300

> >> Max, take a look and see if this same approach can be used in bluetooth, I
> >> bet it can, its just a matter of not using struct net_proto_family for
> >> bt_proto, just like pppox already was doing before my changes :-)

> >> Something similar can be done for ipv4/ipv6 by adding a struct module
> >> *owner member to struct inet_protosw etc. etc.

> >yes

> >> Although the idea is conceptually sound, you miss one crucial thing.
> >> Such struct sock's reference _TWO_ modules, the "PPPOE" module
> >> and the "PPPOX" module.

> This is not a problem. PPPOX (or ipv4/ipv6) module is not going to 
> go away simply because PPPOE (or TCP/UDP) uses symbols from it.
> There is no need to bump refcounters here. 

> I think it's safe to say that protocols within the family always use 
> symbols from main family module (they have to at list register/unregister).
> So this is naturally taken care of.

Because at the core level we don't know (and perhaps don't want to know) what
the specific net family module nor its protocol modules are doing
 
> >But what is the problem? at pppox_sk_alloc time I bump the PPPOE module refcnt,
> >making it safe, then it calls sk_alloc where it bumps the PPPOX module, making
> >it safe as well, so I'm taking care of both PPPOE and PPPOX.

> Bumping refcount for PPPOX is an overhead without any benefits. Read above.
 
> >>       struct module   *owner;

> >This one is the net_families[net_family]->owner

> >>       struct module   *sub_owner;

> >this one is the pppox_protos[protocol]->owner

> >I thought about it, but I don't see why the current scheme doesn't handle
> >it, care to elaborate a bit more? I don't doubt that I may be missing some
> >subtlety :-)

> Ok. I'm going to ask this here again (to make sure that it's answered :))

Hey, I answered already, but it seems you disagree with my view 8)
 
> - Why do we have to bump module refcount for 'struct sock' with _default_ callbacks ?
> My answer is that we don't have to. I'd even say that we shouldn't. Module is not 
> referenced from 'struct sock' in that case.

We just don't assume nothing about the net protocol family implementation, but now
that the infrastructure is in place we can surely study further optimizations that
don't break its layering abstraction.
 
> - Why are we not allowing net_family unregistration until all family sockets
> are gone?  From what I see it's only because current code does
> 'module_put(net_families[family]->owner)'. But we don't care whether
> net_family is registered or not if we know who owns the socket (i.e.
> sock->owner).

but we introduce aditional overhead in all struct sock created, why it is so important
to have the net_family unregistration done early rather than after all the struct sock
are freed?
 
> So far nobody gave me a clear answer to those questions. If we don't have to
> meet those two restriction I don't see the point in creating all this
> net_family_get()/xxx_family_get(), etc, infrastructure. Patches and BK stuff
> that I've seen so far added more code (and a bit more overhead) than my
> original patch with sock->owner/sk->owner/sk_set_owner().  Yet they provide
> no additional flexibility or functionality.

See, its a tradeoff, we don't bloat struct sock paying a bit of overhead in
other area.
 
> I hate to repeat myself and please forgive me for that. But how is the
> current infrastructure better than following ?

See my views above. And I'd love, as you, to have more people discussing this,
but most people I think that could help with this are damn busy with other
work, so at least we have a solid infrastructure in place and can revisit this
later if there is interest in further enhancing this.

- Arnaldo
