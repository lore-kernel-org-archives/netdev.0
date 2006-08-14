From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: Re: Kernel patches enabling better POSIX AIO (Was Re: [3/4] kevent: AIO, aio_sendfile)
Date: Mon, 14 Aug 2006 12:32:10 +0530
Message-ID: <20060814070210.GA27005@in.ibm.com>
References: <1153982954.3887.9.camel@frecb000686> <44C8DB80.6030007@us.ibm.com> <44C9029A.4090705@oracle.com> <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com> <44C90987.1040200@redhat.com> <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com> <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com> <20060812182928.GA1989@in.ibm.com> <44DE27AB.7040507@redhat.com>
Reply-To: suparna@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastien.dugue@bull.net, Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org,
	mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33689 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751907AbWHNHB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 03:01:29 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44DE27AB.7040507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 12:10:35PM -0700, Ulrich Drepper wrote:
> Suparna Bhattacharya wrote:
> > I am wondering about that too. IIRC, the IO_NOTIFY_* constants are =
not
> > part of the ABI, but only internal to the kernel implementation. I =
think
> > Zach had suggested inferring THREAD_ID notification if the pid spec=
ified
> > is not zero. But, I don't see why ->sigev_notify couldn't used dire=
ctly
> > (just like the POSIX timers code does) thus doing away with the=20
> > new constants altogether. Sebestian/Laurent, do you recall?
>=20
> I suggest to model the implementation after the timer code which does
> exactly what we need.

Agreed.

>=20
>=20
> > I'm guessing they are being used for validation of permissions at t=
he time
> > of sending the signal, but maybe saving the task pointer in the ioc=
b instead
> > of the pid would suffice ?
>=20
> Why should any verification be necessary?  The requests are generated=
 in
> the same process which will receive the notification.  Even if the PO=
SIX
> process (aka, kernel process group) changes the IDs the notifications
> should be set.  The key is that notifications cannot be sent to anoth=
er
> POSIX process.

Is there a (remote) possibility that the thread could have died and its
pid got reused by a new thread in another process ? Or is there a mecha=
nism
that prevents such a possibility from arising (not just in NPTL library=
,
but at the kernel level) ?

I think the timer code saves a reference to the task pointer instead of
the pid, which is what I was suggesting above (instead of the euid chec=
ks),
as way to avoid the above situation.

>=20
> Adding this as a feature just makes things so much more complicated.
>=20
>=20
> > So I think the
> > intended behaviour is as you describe it should be
>=20
> Then the documentation needs to be adjusted.

*Nod*

>=20
>=20
> > The way it works (and better ideas are welcome) is that, since the =
io_submit()
> > syscall already accepts an array of iocbs[], no new syscall was int=
roduced.
> > To implement lio_listio, one has to set up such an array, with the =
first iocb
> > in the array having the special (new) grouping opcode of IOCB_CMD_G=
ROUP which
> > specifies the sigev notification to be associated with group comple=
tion
> > (a NULL value of the sigev notification pointer would imply equival=
ent of
> > LIO_WAIT).
>=20
> OK, this seems OK.  We have to construct the iocb arrays dynamically =
anyway.
>=20
>=20
> > My thought here was that it should be possible to include M as a pa=
rameter
> > to the IOCB_CMD_GROUP opcode iocb, and thus incorporated in the lio=
 control
> > block ... then whatever semantics are agreed upon can be implemente=
d.
>=20
> If you have room for the parameter this is fine.  For the beginning w=
e
> can enforce the number to be the same as the total number of requests=
=2E
>=20

Sounds good.

>=20
> > Let us know what you think about the listio interface ... hopefully=
 the
> > other issues are mostly simple to resolve.
>=20
> It should be fine and I would support adding all this assuming the
> normal file support (as opposed to direct I/O only) is added, too.

OK. I updated my patchset against 2618-rc3 just after OLS.

>=20
>=20
> But I have one last question: sockets, pipes and the like are already
> supported, right?  If this is not the case we have a problem with the
> currently proposed  lio_listio interface.

AIO for pipes should not be a problem - Chris Mason had a patch, so we =
can
just bring it up to the current levels, possibly with some additional
improvements.

I'm not sure what would be the right thing to do for the sockets case. =
While
we could put together a patch for basic aio_read/write (based on the sa=
me
model used for files), given the whole ongoing kevent effort, its not y=
et
clear to me what would make the most sense ... =20

Ben had a patch to do a fallback to kernel threads for AIO operations t=
hat
are not yet supported natively. I had some concerns about the approach,=
 but
I guess he had intended it as an interim path for cases like this.

Suggestions would be much appreciated ?  DaveM, Ingo, Andrew ?

Regards
Suparna

>=20
> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
>=20



--=20
Suparna Bhattacharya (suparna@in.ibm.com)
Linux Technology Center
IBM Software Lab, India

