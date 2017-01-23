From: David Windsor <dwindsor@gmail.com>
Subject: Reference counting struct inet_peer
Date: Mon, 23 Jan 2017 07:42:51 -0500
Message-ID: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:36227 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdAWMmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 07:42:52 -0500
Received: by mail-ua0-f194.google.com with SMTP id f2so13225133uaf.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 04:42:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm working on a patchset that adds overflow protection to kernel
reference counters, as part of the KSPP effort.  We're introducing a
new type, tentatively called refcount_t, that will ultimately replace
atomic_t as the type used for kernel reference counters.  refcount_t
has a constrained interface relative to atomic_t and stores reference
counts as unsigned integers.

While performing an audit of kernel reference counters, we've come
upon a few corner cases that we're unable to cleanly migrate to
refcount_t.  One of these is the reference counting scheme for struct
inet_peer.

struct inet_peer objects get freed when their reference count becomes
-1, not 0 as is the usual case.  Is there a reason why this is so?
The common use case I'm seeing is this:

struct inet_peer *p = inet_getpeer_v[4|6]();
...
inet_putpeer(p);


inet_getpeer_v4() and inet_getpeer_v6() are wrappers around
inet_getpeer().  From inet_getpeer():

struct inet_peer *p;
...
p = lookup_rcu(daddr, base);
...
p = lookup(daddr, stack, base);
if (p != peer_avl_empty) {
    atomic_inc(&p->refcnt);
    write_sequnlock_bh(&base->lock);
    return p;
}
...
p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
if (p) {
    ...
    atomic_set(&p->refcnt, 1);
    ...
}
return p;

This all looks straightforward: p->refcnt is incremented by one when
it is found in the peer node tree, and it is set to one when it is
newly created.

However, in lookup_rcu(), this same reference count is checked against
-1.  From lookup_rcu():

struct inet_peer *u = rcu_dereference(base->root);
...
/* Before taking a reference, check if this entry was
* deleted (refcnt=-1)
*/
if (!atomic_add_unless(&u->refcnt, 1, -1))
    u = NULL;
return u;

Rather than delve further into net's internal garbage collectors, or
into RCU internals, I figured I'd ask here if there's a reason for the
check against -1 in rcu_lookup().

We're also seeing the same thing (freeing shared objects when their
refcount becomes -1) in ip_vs.h:

http://lxr.free-electrons.com/source/include/net/ip_vs.h#L1424

static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
{
    if (atomic_dec_return(&dest->refcnt) < 0)
        kfree(dest);
}

Note that this example also appears in a garbage collector internal to net/.

Thanks,
David Windsor
