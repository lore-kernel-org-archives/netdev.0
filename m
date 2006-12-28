From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 28 Dec 2006 12:50:44 +0300
Message-ID: <20061228095044.GA26314@2ka.mipt.ru>
References: <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru> <20061122121516.GA7229@2ka.mipt.ru> <4564CE00.9030904@redhat.com> <20061123122225.GD20294@2ka.mipt.ru> <456605EA.5060601@redhat.com> <20061124105856.GE13600@2ka.mipt.ru> <456B2D2B.9080502@redhat.com> <20061128101327.GE15083@2ka.mipt.ru> <4592DB7E.4090100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44131 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832AbWL1Jwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Dec 2006 04:52:31 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4592DB7E.4090100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 27, 2006 at 12:45:50PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> > Why do we want to inject _ready_ event, when it is possible to mark
> > event as ready and wakeup thread parked in syscall?
>=20
> Going back to this old one:
>=20
> How do you want to mark an event ready if you don't want to introduce
> yet another layer of data structures?  The event notification happens
> through entries in the ring buffer.  Userlevel code should never add
> anything to the ring buffer directly, this would mean huge
> synchronization problems.  Yes, one could add additional data structu=
res
> accompanying the ring buffer which can specify userlevel-generated
> events.  But this is a) clumsy and b) a pain to use when the same rin=
g
> buffer is used in multiple threads (you'd have to have another shared
> memory segment).
>=20
> It's much cleaner if the userlevel code can get the kernel to inject =
a
> userlevel-generated event.  This is the equivalent of userlevel code
> generating a signal with kill().

Existing possibility to mark event as ready works following way:
event is queued into storage queue (socket, inode or some other queue),
when readiness condition becomes true, event is queued into ready queue
(although it is still in the storage queueu). It happens completely
asynchronosu to _any_ kind of userspace processing.
When userspace calls apropriate syscall, event is being copied into rin=
g
buffer.

Thus userspace readiness will just mark event as ready, i.e. it queues
event into ready queue, so later usersapce will callsyscall to actually
get the event.

When one thread is parked in the syscall and there are _no_ events
which should be marked as ready (for example only sockets are there, an=
d
it is not a good idea to wakeup the whole socket processing state machi=
ne),=20
then there is no possibility to receive such event (although it is
possible to interrupt and break syscall).

So, according to injecting ready events, it can be done - just an
addition of special flag which will force kevent core to move event int=
o
ready queue immediately. In this case userspace can event prepare a
needed event (like signal event) and deliver it to process, so it will
think (only from kevent point of view) that real signal has been arrive=
d.

I will also add special type of events - userspace events - which will
not have empty callbacks, which will be intended to use for user-define=
d
way (i.e. for inter thread communications).

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
>=20



--=20
	Evgeniy Polyakov
