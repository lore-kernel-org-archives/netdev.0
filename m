From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 01:50:54 -0700
Message-ID: <1315471854.2301.13.camel@schen9-mobl>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <CA+icZUUFm0injjqR16=xz06bjm4+pCLNhtizxofE_hTxE+e==w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>, alex.shi@intel.com
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17198 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab1IHXcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 19:32:50 -0400
In-Reply-To: <CA+icZUUFm0injjqR16=xz06bjm4+pCLNhtizxofE_hTxE+e==w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-08 at 12:05 +0200, Sedat Dilek wrote:
> On Tue, Sep 6, 2011 at 9:59 PM, Tim Chen <tim.c.chen@linux.intel.com>=
 wrote:
> > On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
> >> Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9cr=
it :
> >>
> >> > Yes, I think locking the sendmsg for the entire duration of
> >> > unix_stream_sendmsg makes a lot of sense.  It simplifies the log=
ic a lot
> >> > more.  I'll try to cook something up in the next couple of days.
> >>
> >> Thats not really possible, we cant hold a spinlock and call
> >> sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.
> >>
> >> You would need to prepare the full skb list, then :
> >> - stick the ref on the last skb of the list.
> >>
> >> Transfert the whole skb list in other->sk_receive_queue in one go,
> >> instead of one after another.
> >>
> >> Unfortunately, this would break streaming (big send(), and another
> >> thread doing the receive)
> >>
> >> Listen, I am wondering why hackbench even triggers SCM code. This =
is
> >> really odd. We should not have a _single_ pid/cred ref/unref at al=
l.
> >>
> >
> > Hackbench triggers the code because it has a bunch of threads sendi=
ng
> > msgs on UNIX socket.
> >>
> >
>=20
> # lsof | grep socket | wc -l
> 198
>=20
> Aprrox 200 sockets in usage here, can you post your hackbench line, p=
lease?
> I would compare hackbench results with and without new improvements i=
n SCM code.
>=20
> - Sedat -
>=20

The hackbench line I used was

=2E/hackbench 50 thread 2000

You will need to use the threaded case for testing to see the issue.  I
was running on a 4 socket, 40 cores total Westmere-EX machine.  The
improvement may depend on your machine size, probably with more
improvement on larger multi-socket machine as smaller ones don't have a=
s
big a problem.

Tim
