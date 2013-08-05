From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v6 1/8] vxlan: Restructure vxlan socket apis.
Date: Mon, 5 Aug 2013 11:10:21 -0700
Message-ID: <20130805111021.62430fc5@nehalam.linuxnetplumber.net>
References: <1375382680-3137-1-git-send-email-pshelar@nicira.com>
	<20130804144215.640c9336@nehalam.linuxnetplumber.net>
	<CALnjE+oZkX6FkVaaJeYz2C9SgY0hcRi6xKjxsSh+5Q=PoH7qFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33885 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267Ab3HESKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:10:25 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so3593782pab.24
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 11:10:24 -0700 (PDT)
In-Reply-To: <CALnjE+oZkX6FkVaaJeYz2C9SgY0hcRi6xKjxsSh+5Q=PoH7qFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Aug 2013 08:49:36 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Sun, Aug 4, 2013 at 2:42 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Thu,  1 Aug 2013 11:44:40 -0700
> > Pravin B Shelar <pshelar@nicira.com> wrote:
> >
> >> @@ -1642,59 +1651,56 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
> >>                        &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
> >>               sk_release_kernel(sk);
> >>               kfree(vs);
> >> -             return ERR_PTR(rc);
> >> +             return;
> >>       }
> >> +     atomic_set(&vs->refcnt, 0);
> >>
> >>       /* Disable multicast loopback */
> >>       inet_sk(sk)->mc_loop = 0;
> >> +     spin_lock(&vn->sock_lock);
> >> +     hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
> >> +     spin_unlock(&vn->sock_lock);
> >
> > Overall I am fine with this set, except for this.
> > The change causes a socket to be put into the hash list with a ref count
> > of 0 and then you increment the ref count. If some other thread
> > finds the socket and then decrements the ref count, it would go
> > below zero and might leak, crash or delete it prematurely.
> >
> > This concerns me.
> 
> There is no code path which decrements ref-cnt after lookup. Therefore
> above case is not possible.
> But I agree this does not look good, so I will change it so not to
> have refcnt zero vs on hash-table.

I was concerned about:

CPU 0:
   vxlan_socket_create
     Make a vs structure with refcnt == 0
     Add it to hlist

     <preempt or other long IRQ>
                                         CPU 1: Another vxlan being setup (batch script?)
                                                vxlan_init
                                                     vxlan_find_port finds that vs
                                                     atomic_inc(refcnt) now 1
                                          <close or error>
                                                vxlan_uninit
                                                  vxlan_sock_release
                                                     atomic_dec_and_test (now 0)
                                                       delete from hlist
                                                       queue work for deletion

     now decides to continue with vs
     Either vs is already freed, or it exists
     in limbo

                                                       
