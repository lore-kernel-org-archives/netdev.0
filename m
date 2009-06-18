From: Florian Westphal <fw@strlen.de>
Subject: Re: inet_csk_get_port lock imbalance?
Date: Thu, 18 Jun 2009 16:14:25 +0200
Message-ID: <20090618141425.GA31266@Chamillionaire.breakpoint.cc>
References: <4A3A476A.1060808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60263 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754210AbZFROOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:14:25 -0400
Content-Disposition: inline
In-Reply-To: <4A3A476A.1060808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> wrote:
> Hi,
> 
> we've found a weird locking discipline in inet_csk_get_port. Who is
> supposed to unlock the spin lock in the place marked in the code below?
> 
> do {
>         head = &hashinfo->bhash[inet_bhashfn(net, rover,
>                         hashinfo->bhash_size)];
>         spin_lock(&head->lock);
>         inet_bind_bucket_for_each(tb, node, &head->chain)
>                 if (ib_net(tb) == net && tb->port == rover) {
> ...
> 		}
>         break;  ////////// here
> next:
>         spin_unlock(&head->lock);
>         if (++rover > high)
>                 rover = low;
> } while (--remaining > 0);

looks weird, but seems intentional (and ok):
          } while (--remaining > 0);
-> you arrive here after break; with head->lock held.
...
                if (remaining <= 0) {
			...
->if you get here, then the loop was left with head->lock unlocked.
..
        } else {
have_snum:
...
          spin_lock(&head->lock);
-> we do not hit this code path in the "locked" case.
...
           goto tb_found;
        }
        tb = NULL;
        goto tb_not_found;
-> we go to tb_not_found, with head->lock held. it cannot be in unlocked state here.

...
tb_not_found:
        ret = 1;
        if (!tb && (tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
                                        net, head, snum)) == NULL)
                goto fail_unlock;
        if (hlist_empty(&tb->owners)) {
                if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
                        tb->fastreuse = 1;
                else
                        tb->fastreuse = 0;
        } else if (tb->fastreuse &&
                   (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
                tb->fastreuse = 0;
success:
        if (!inet_csk(sk)->icsk_bind_hash)
                inet_bind_hash(sk, tb, snum);
        WARN_ON(inet_csk(sk)->icsk_bind_hash != tb);
        ret = 0;

fail_unlock:
        spin_unlock(&head->lock);
-> here it will be unlocked

I'd appreciate it if you consider the above a blatant lie and check it again :-)

