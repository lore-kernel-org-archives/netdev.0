From: David Miller <davem@davemloft.net>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Tue, 10 Jun 2008 15:32:52 -0700 (PDT)
Message-ID: <20080610.153252.252676827.davem@davemloft.net>
References: <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
	<20080603.150344.145518113.davem@davemloft.net>
	<Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, mcmanus@ducksong.com, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, rjw@sisk.pl,
	akpm@linux-foundation.org, johnpol@2ka.mipt.ru
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753272AbYFJWc4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:32:56 -0400
In-Reply-To: <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 4 Jun 2008 02:22:16 +0300 (EEST)

> [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
>=20
> It seems that replacement of DA code also moved parts outside
> of appropriate locking. The Ingo's problem seems to come from
> the fact that two flows could now race in
> (inet_csk_)reqsk_queue_add corrupting the queue. ...This can
> leave dangling socks around which won't resolve themselves
> without stimuli from outside (e.g., external RST would help
> I think).
>=20
> Then some details I'm not too sure of:
> I guess we want to put listen_sk->sk_state checking under the
> lock as well. I've not evaluated if ->sk_data_ready too
> requires locking but assumed it does.
>=20
> I'm by no means familiar with all locking variants, requirements,
> etc.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I took a close look at this, it seems this patch adds
an ABBA deadlock.  But I might be wrong.

Normally the locking order is:

	listen_sk --> some_child_sk

And this can be seen by the code paths that flow down
to tcp_child_process() in net/ipv4/tcp_minisocks.c (via
tcp_v4_do_rcv() for example).

However here in this patch we will lock in the:

	child_sk --> listen_sk

order.

Unless... these defer accepted sockets live outside of the
normal socket collection found by tcp_v{4,6}_hnd_req().  If
that is the case, that ought to make this locking order OK
but I fear that lockdep will likely complain because it has
no way to see this distinction.

If we cannot find a simple and easy way to deal with this locking
problem, I am reverting the defer-accept changes entirely.  It's not
the end of the world if this feature has to be deferred to 2.6.27
and this bug has been known for several weeks already.

