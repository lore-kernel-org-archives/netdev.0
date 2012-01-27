From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Regression on behavior of EPOLLET | EPOLLIN for AF_UNIX
 sockets in 3.2
Date: Fri, 27 Jan 2012 19:55:06 +0100
Message-ID: <1327690506.3159.7.camel@edumazet-laptop>
References: <CAKDKvuzH14AZjDG3WSdrf5VtmiUgG0Y+EaC83qqSd0VFKzyitg@mail.gmail.com>
	 <1327686822.3159.3.camel@edumazet-laptop> <4F22EA24.3030901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Mathewson <nickm@freehaven.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Moiseytsev <himeraster@gmail.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F22EA24.3030901@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 27 janvier 2012 =C3=A0 22:17 +0400, Glauber Costa a =C3=A9c=
rit :
> On 01/27/2012 09:53 PM, Eric Dumazet wrote:
> > Le vendredi 27 janvier 2012 =C3=A0 12:05 -0500, Nick Mathewson a =C3=
=A9crit :
> >> [1.] One line summary of the problem:
> >>
> >
> > Hi
> >
> > Probably coming from commit 0884d7aa24e15e72b3c07f7da910a13bb7df359=
2
> > (AF_UNIX: Fix poll blocking problem when reading from a stream sock=
et)
> >
> > When we requeue skb because not completely eaten, we call again
> >
> > sk->sk_data_ready(sk, skb->len);
> >
> For the record, I just confirmed this to be the case.

A fix would be to change unix_poll() and not call sk_data_ready() when
skb is requeued.

if (!skb_queue_empty(&sk->sk_receive_queue))
	mask |=3D POLLIN | POLLRDNORM;

Might be tricky if we want to keep unix_poll() lockless, but quite
possible.

Or... not dequeue skb from sk_received_queue unless fully consumed.
