From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Fri, 21 Jan 2005 11:54:52 +0100
Message-ID: <20050121105452.GA12988@xi.wantstofly.org>
References: <527jmu8nbw.fsf@topspin.com> <5cac192f0501030907c755135@mail.gmail.com> <20050103171227.GD7370@esmail.cup.hp.com> <1104812294.1085.53.camel@jzny.localdomain> <20050119144711.3fdd3d93.davem@davemloft.net> <20050119151853.259de49a@dxpl.pdx.osdl.net> <20050119164640.6c67bdfa.davem@davemloft.net> <52r7kgu5n5.fsf@topspin.com> <20050119230526.393a5184.davem@davemloft.net> <20050120085611.33f9485e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Roland Dreier <roland@topspin.com>, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050120085611.33f9485e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2005 at 08:56:11AM -0800, Stephen Hemminger wrote:

> You might want to enforce that LLTX devices like tunnels need to
> have no transmit queue (tx_queue_len == 0)?

I didn't look at the original LLTX patch, so I'm speaking out of
ignorance, but since we're on this subject anyway: I noticed that
the ip_gre tunneling driver contains this comment:

<quote>
   1. The most important issue is detecting local dead loops.
   They would cause complete host lockup in transmit, which
   would be "resolved" by stack overflow or, if queueing is enabled,
   with infinite looping in net_bh.

   We cannot track such dead loops during route installation,
   it is infeasible task. The most general solutions would be
   to keep skb->encapsulation counter (sort of local ttl),
   and silently drop packet when it expires. It is the best
   solution, but it supposes maintaing new variable in ALL
   skb, even if no tunneling is used.

   Current solution: t->recursion lock breaks dead loops. It looks
   like dev->tbusy flag, but I preferred new variable, because
   the semantics is different. One day, when hard_start_xmit
   will be multithreaded we will have to use skb->encapsulation.
</quote>

If multiple CPUs can call into the tunneling drivers without taking
any locks, we'd need some extra locking in there, or just do what
Alexey describes and keep track of recursion in the skb.

The recursion detection in dev_queue_xmit would perhaps also want to
use such a per-skb mechanism instead of using dev->xmit_lock_owner.

(You really _do_ want the protection that this mechanism offers.)


--L
