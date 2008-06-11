From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 11 Jun 2008 18:13:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806111056460.7328@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
 <20080610.153252.252676827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1703619123-1213171554=:7328"
Cc: mingo@elte.hu, mcmanus@ducksong.com, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760998AbYFKPN2@vger.kernel.org>
In-Reply-To: <20080610.153252.252676827.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0806111650160.16829@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1703619123-1213171554=:7328
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806111115531.7328@wrl-59.cs.helsinki.fi>

On Tue, 10 Jun 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 4 Jun 2008 02:22:16 +0300 (EEST)
> 
> > [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
> > 
> > It seems that replacement of DA code also moved parts outside
> > of appropriate locking. The Ingo's problem seems to come from
> > the fact that two flows could now race in
> > (inet_csk_)reqsk_queue_add corrupting the queue. ...This can
> > leave dangling socks around which won't resolve themselves
> > without stimuli from outside (e.g., external RST would help
> > I think).
> > 
> > Then some details I'm not too sure of:
> > I guess we want to put listen_sk->sk_state checking under the
> > lock as well. I've not evaluated if ->sk_data_ready too
> > requires locking but assumed it does.
> > 
> > I'm by no means familiar with all locking variants, requirements,
> > etc.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> I took a close look at this, it seems this patch adds
> an ABBA deadlock.  But I might be wrong.
> 
> Normally the locking order is:
> 
> 	listen_sk --> some_child_sk
> 
> And this can be seen by the code paths that flow down
> to tcp_child_process() in net/ipv4/tcp_minisocks.c (via
> tcp_v4_do_rcv() for example).
> 
> However here in this patch we will lock in the:
> 
> 	child_sk --> listen_sk
> 
> order.
>
> Unless... these defer accepted sockets live outside of the
> normal socket collection found by tcp_v{4,6}_hnd_req().

All these collection/queues make the analysis a bit complex :-), but
I think I finally got a hold of it anyway and my analysis agrees with 
yours. To me it seems that when DAed TCP sk moves to established, there's 
no longer a connection from listen_sk to child_sk, we keep them alive by 
incrementing those refcounts and the child sk is responsible about the 
binding between them (until the DA gets resolution). But the child_sk 
locking during the creation is also a suspect, but only after 
tcp_rcv_established() part can run for the child sock.

Am I right that after tcp_v4_syn_recv_sock() it is possible to get 
tcp_rcv_established() to execute for the created child? It's called 
by this path:
  tcp_v4_hnd_req ->
    tcp_check_req -> 
      tcp_v4_syn_recv_sock (inet_csk(sk)->icsk_af_ops->syn_recv_sock)
...and the listen_sk part acquires that child's lock only after that in 
tcp_v4_hnd_req(). ...Allowing it to deadlock during that short window!

...But from that point onward nothing in listen_sk needs to lock the 
child. Then this connection from listen_sk to child_sk comes back once 
we've reinserted the DAed child_sk back to the queue (in that racy part I 
was trying to fix) but at that point of time we won't ever need to lock in 
child_sk -> listen_sk order again because we've already passed that 
point.

...But like you, I don't understand all of it that well... Btw, your 
sk_callback_lock notes explained some mystery part for me as I came
across with it too while looking around... :-)

> If that is the case, that ought to make this locking order OK
> but I fear that lockdep will likely complain because it has
> no way to see this distinction.

I definately agree that the locks are taken in different order no matter 
what (I actually referring to that already in the first mail about the 
deadlock) so probably lockdep is not going to be too friendly :-), whether 
it could cause a real deadlock, I was not that sure at that point of time.

> If we cannot find a simple and easy way to deal with this locking
> problem, I am reverting the defer-accept changes entirely.

To avoid all problem, I was already thinking of another approach (though 
my time constraints hardly allows finishing it any time soon):

Because DA code resides quite late on the TCP path it would be quite easy
to do some preparatory work, drop child sk's lock and re-acquire both 
locks in the usual order (listen->child) but that would require handling 
correctly reset & other things that could intervene (luckily that pesky 
userspace isn't there yet to mess around so not that many things can 
happen :-)). But ipv6 seems to do some additional processing after 
tcp_rcv_established() which I'd expect to choke if child sk's lock was 
dropped there for a moment, while ipv4 part seems quite doable. I don't 
even know what exactly are the requirements for that ipv6 part (see the 
stuff after ipv6_pktoptions label in tcp_v6_do_rcv). ...I tried to do
this but came across those two things mentioned above.

IMHO, changing locking this late in the release cycle would be quite
risky anyway... And we would also be fiddling with TCP state machine.

> It's not the end of the world if this feature has to be deferred to 
> 2.6.27

Agreed. Especially in the light of the another issue that has been 
raised.

> and this bug has been known for several weeks already.

...That's partially because Ingo didn't even test my fix on the receiver 
which got stuck but used 2.6.25 and got some other bug which looked alike 
but couldn't be the same because these DA problems weren't in 2.6.25. What 
could I've done for that :-).

-- 
 i.
---696208474-1703619123-1213171554=:7328--
