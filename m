From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for
  protocol modules
Date: Tue, 29 Apr 2003 13:05:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
References: <20030428.222728.48508327.davem@redhat.com>
 <20030429061227.GJ25361@conectiva.com.br>
 <20030428.222728.48508327.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mostrows@speakeasy.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030429065419.GN25361@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 11:54 PM 4/28/2003, Arnaldo Carvalho de Melo wrote:
>Em Mon, Apr 28, 2003 at 10:27:28PM -0700, David S. Miller escreveu:
>>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>>    Date: Tue, 29 Apr 2003 03:12:27 -0300
>> 
>>       Max, take a look and see if this same approach can be used in
>>    bluetooth, I bet it can, its just a matter of not using struct
>>    net_proto_family for bt_proto, just like pppox already was doing
>>    before my changes :-)
>> 
>> Something similar can be done for ipv4/ipv6 by adding a struct module
>> *owner member to struct inet_protosw etc. etc.
>
>yes
> 
>> Although the idea is conceptually sound, you miss one crucial thing.
>> Such struct sock's reference _TWO_ modules, the "PPPOE" module
>> and the "PPPOX" module.
This is not a problem. PPPOX (or ipv4/ipv6) module is not going to 
go away simply because PPPOE (or TCP/UDP) uses symbols from it.
There is no need to bump refcounters here. 
I think it's safe to say that protocols within the family always use 
symbols from main family module (they have to at list register/unregister).
So this is naturally taken care of.

>But what is the problem? at pppox_sk_alloc time I bump the PPPOE module refcnt,
>making it safe, then it calls sk_alloc where it bumps the PPPOX module, making
>it safe as well, so I'm taking care of both PPPOE and PPPOX.
Bumping refcount for PPPOX is an overhead without any benefits. Read above.

>>       struct module   *owner;
>
>This one is the net_families[net_family]->owner
>
>>       struct module   *sub_owner;
>
>this one is the pppox_protos[protocol]->owner
>
>I thought about it, but I don't see why the current scheme doesn't handle
>it, care to elaborate a bit more? I don't doubt that I may be missing some
>subtlety :-)
Ok. I'm going to ask this here again (to make sure that it's answered :))

- Why do we have to bump module refcount for 'struct sock' with _default_ callbacks ?
My answer is that we don't have to. I'd even say that we shouldn't. Module is not 
referenced from 'struct sock' in that case.

- Why are we not allowing net_family unregistration until all family sockets are gone ?
 From what I see it's only because current code does 'module_put(net_families[family]->owner)'.
But we don't care whether net_family is registered or not if we know who owns
the socket (i.e. sock->owner).

So far nobody gave me a clear answer to those questions. If we don't have to meet those
two restriction I don't see the point in creating all this net_family_get()/xxx_family_get(), 
etc, infrastructure. Patches and BK stuff that I've seen so far added more code (and a bit 
more overhead) than my original patch with sock->owner/sk->owner/sk_set_owner().
Yet they provide no additional flexibility or functionality.

I hate to repeat myself and please forgive me for that. But how is the current 
infrastructure better than following ?

----
sock_create()
{
        ...
        if (!try_module_get(npf->owner))
                goto fail;
        sock->owner = npf->owner;

        if (family_sock_create() < 0) {
                sock_release(sock);
                goto fail;
        }
        ...
}

 From this point on we don't care if net_proto_family is still registered or not, we know
who owns the socket.

sock_accept()
{
        ...
        __module_get(sock->owner);
        newsock->owner = sock->owner;
        ...
}

sock_release()
{
        ...
        module_put(sock->owner);
        ...
}

family_sock_create() (i.e. bt_sock_create(), etc)
{        
        ...
#ifdef SPECIAL_FAMILY_THAT_HANDLES_PROTOCOLS_IN_SEPARATE_MODULES
        if (!try_module_get(proto_module))
                goto fail;

        prev_owner = sock->owner;
        sock->owner = proto_module;
        module_put(prev_owner); 
#else
        /* Other families do not have to do anything */
#endif
        ...
}

That's it for 'struct socket'.  And I mean that is _it_. Family can be unregistered 
and stuff, we don't care, and why should we.

Now 'struct sock'. It can exist independently from 'struct socket' and therefor
is a separate issue.
We only care about callbacks (sk->data_ready(), etc) and private sk slab caches. Some 
protocols simply use default callback which belong to non modular part of the kernel. 
Those don't have to do anything. They will just work.
Other protocols replace callbacks and therefor have to make sure that module is still 
loaded while sk exists. For those modules we need the following

void sk_set_owner(struct module *owner)
{
        /* Module must already hold reference when it calls this function. */
        __module_get(owner);
        sk->owner = owner;
}
        
sk_free()
{
        ...
        module_put(sk->owner);
        ...
}

xxx_proto_set_sk_callbacks()
{
        ...
        sk_set_owner(THIS_MODULE);
        sk->destroy = proto_destroy;
        ...
}

That's it. There is no need to modify sk_alloc() or anything else. So it's not going
to introduce any overhead during socket creation from protocols that aren't modules or 
use default callback. And it gives us a flexibility of being able to pass ownership of 
the socket to another module or release module without having to access global family 
array.
For example if protocol wants to be unloaded but socket is still being used by net code
it could do something like
        write_lock(&sk->callback_lock);
        sk->data_ready = default_data_ready;
        ... other non default callbacks ...
        module_put(sk->owner);
        sk_set_owner(NULL);
        write_unlock(&sk->callback_lock);
---

Thanks
Max
