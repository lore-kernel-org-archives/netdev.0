From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Reference counting struct inet_peer
Date: Tue, 24 Jan 2017 09:38:37 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1701240853370.1779@ja.home.ssi.bg>
References: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>
To: David Windsor <dwindsor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52490 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750705AbdAXHi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 02:38:56 -0500
In-Reply-To: <CAEXv5_j1cz1EUPgmAKO5OHxKcoHVLuPPVRs316CWyMpw8UtpRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 23 Jan 2017, David Windsor wrote:

> Hi,
> 
> I'm working on a patchset that adds overflow protection to kernel
> reference counters, as part of the KSPP effort.  We're introducing a
> new type, tentatively called refcount_t, that will ultimately replace
> atomic_t as the type used for kernel reference counters.  refcount_t
> has a constrained interface relative to atomic_t and stores reference
> counts as unsigned integers.
> 
> While performing an audit of kernel reference counters, we've come
> upon a few corner cases that we're unable to cleanly migrate to
> refcount_t.  One of these is the reference counting scheme for struct
> inet_peer.

...

> We're also seeing the same thing (freeing shared objects when their
> refcount becomes -1) in ip_vs.h:
> 
> http://lxr.free-electrons.com/source/include/net/ip_vs.h#L1424
> 
> static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
> {
>     if (atomic_dec_return(&dest->refcnt) < 0)
>         kfree(dest);
> }

	I think, this is easy to fix. The problem is that
dest_trash currently holds deleted dests (unlinked from RCU lists)
with refcnt=0. If we change the dest_trash to hold dest
with refcnt=1, the above atomic_dec_return can be changed to
atomic_dec_and_test. Change should be small: ip_vs_dest_put
should be removed from __ip_vs_del_dest(), ip_vs_dest_hold()
from ip_vs_trash_get_dest() and refcnt check in
ip_vs_dest_trash_expire() should be updated. Let me know if
this holds your work, I can provide such patch to fix it.

Regards
