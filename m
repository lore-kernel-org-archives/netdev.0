From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for
  protocol modules
Date: Tue, 29 Apr 2003 17:43:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030429164010.10ddb380@unixmail.qualcomm.com>
References: <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
 <20030428.222728.48508327.davem@redhat.com>
 <20030429061227.GJ25361@conectiva.com.br>
 <20030428.222728.48508327.davem@redhat.com>
 <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@redhat.com>, mostrows@speakeasy.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030429220746.GB30222@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 03:07 PM 4/29/2003, Arnaldo Carvalho de Melo wrote:
>Em Tue, Apr 29, 2003 at 01:05:08PM -0700, Max Krasnyansky escreveu:
>> >> Although the idea is conceptually sound, you miss one crucial thing.
>> >> Such struct sock's reference _TWO_ modules, the "PPPOE" module
>> >> and the "PPPOX" module.
>
>> This is not a problem. PPPOX (or ipv4/ipv6) module is not going to 
>> go away simply because PPPOE (or TCP/UDP) uses symbols from it.
>> There is no need to bump refcounters here. 
>
>> I think it's safe to say that protocols within the family always use 
>> symbols from main family module (they have to at list register/unregister).
>> So this is naturally taken care of.
>
>Because at the core level we don't know (and perhaps don't want to know) what
>the specific net family module nor its protocol modules are doing
We know that protocol has to at least register with the family. Which is enough
to keep family module loaded.

>> Ok. I'm going to ask this here again (to make sure that it's answered :))
>Hey, I answered already, but it seems you disagree with my view 8)
Of course I do. I wouldn't be arguing here if I didn't :).

>> - Why do we have to bump module refcount for 'struct sock' with _default_ callbacks ?
>> My answer is that we don't have to. I'd even say that we shouldn't. Module is not 
>> referenced from 'struct sock' in that case.
>
>We just don't assume nothing about the net protocol family implementation, but now
>that the infrastructure is in place we can surely study further optimizations that
>don't break its layering abstraction.
We already know which families change callbacks and which don't. I looked at that already.

>> - Why are we not allowing net_family unregistration until all family sockets
>> are gone?  From what I see it's only because current code does
>> 'module_put(net_families[family]->owner)'. But we don't care whether
>> net_family is registered or not if we know who owns the socket (i.e.
>> sock->owner).
>
>but we introduce aditional overhead in all struct sock created why it is so important
>to have the net_family unregistration done early rather than after all the struct sock
>are freed?
I'm not saying it's important. I'm saying we don't care, if we know who owns the socket.
And if we don't care we don't need net_family_get() and friends.

>> So far nobody gave me a clear answer to those questions. If we don't have to
>> meet those two restriction I don't see the point in creating all this
>> net_family_get()/xxx_family_get(), etc, infrastructure. Patches and BK stuff
>> that I've seen so far added more code (and a bit more overhead) than my
>> original patch with sock->owner/sk->owner/sk_set_owner().  Yet they provide
>> no additional flexibility or functionality.
>
>See, its a tradeoff, we don't bloat struct sock paying a bit of overhead in other area.
I wouldn't call one additional pointer a bloat (btw I mentioned that we have sk->prev and 
sk->pprev, we should be able to easily kill one of them).

>> I hate to repeat myself and please forgive me for that. But how is the
>> current infrastructure better than following ?
>
>See my views above. And I'd love, as you, to have more people discussing this,
>but most people I think that could help with this are damn busy with other
>work, so at least we have a solid infrastructure in place and can revisit this
>later if there is interest in further enhancing this.
That's the thing, I wouldn't call current infrastructure solid :)

Ok. Speaking about bloat. pppox mod refcounting. 
You added additional level if indirection to every 'struct socket' and 'struct sock'
allocation/dealocation.
For example to free pppoe sk we now have to call
        sk_free(sk)
                pppox_sk_free(sk)
                        pppox_protos[PPPOE]->sk_free(sk)
                module_put(pppox_protos[PPPOE]->owner)
instead of
        sk_free(sk)
                pppoe_sk_free(sk)
        module_put(sk->owner)

Same thing for pppox_release.
You also had to introduce new function pppox_sk_alloc() which is not needed otherwise.

Basically this entire patch 
        http://linux.bkbits.net:8080/linux-2.5/diffs/drivers/net/pppox.c@1.11?nav=index.html|ChangeSet@-2d|cset@1.1128.1.19

would have been

pppox.c
pppox_create()
{
        ...
+       if (!try_module_get(pppox_protos[protocol]->owner))
+               goto out; 
+
+       sock->owner = pppox_protos[protocol]->owner;
        ...
}

pppoe.c
pppoe_create()
{
        ...
+       sk->destruct = pppoe_sk_free;
+       sk_set_owner(THIS_MODULE);
        ...
}

IMO it's pretty clear which one has more bloat ;-)

Max

                


        
