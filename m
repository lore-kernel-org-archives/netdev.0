From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: Kernel patches enabling better POSIX AIO (Was Re: [3/4] kevent: AIO, aio_sendfile)
Date: Sat, 12 Aug 2006 23:59:28 +0530
Message-ID: <20060812182928.GA1989@in.ibm.com>
References: <44C77C23.7000803@redhat.com> <44C796C3.9030404@us.ibm.com> <1153982954.3887.9.camel@frecb000686> <44C8DB80.6030007@us.ibm.com> <44C9029A.4090705@oracle.com> <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com> <44C90987.1040200@redhat.com> <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com> <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com>
Reply-To: suparna@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?S=E9bastien_Dugu=E9_=3Csebastien=2Edugue=40bull=2Enet?=.=?iso-8859-1?Q?=3E?=@qubit.in.ibm.com,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:25324 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030241AbWHLS3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 14:29:00 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44DCDE73.9030901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BTW, if anyone would like to be dropped off this growing cc list, pleas=
e
let us know.

On Fri, Aug 11, 2006 at 12:45:55PM -0700, Ulrich Drepper wrote:
> S=C3=A9bastien Dugu=C3=A9 wrote:
> > 		     aio completion notification
>=20
> I looked over this now but I don't think I understand everything.  Or=
 I
> don't see how it all is integrated.  And no, I'm not looking at the
> proposed glibc code since would mean being tainted.

Oh, I didn't realise that.=20
I'll make an attempt to clarify parts that I understand based on what I
have gleaned from my reading of the code and intent, but hopefully Seba=
stien,
Ben, Zach et al will be able to pitch in for a more accurate and comple=
te
picture.

>=20
>=20
> > Details:
> > -------
> >=20
> >   A struct sigevent *aio_sigeventp is added to struct iocb in
> > include/linux/aio_abi.h
> >=20
> >   An enum {IO_NOTIFY_SIGNAL =3D 0, IO_NOTIFY_THREAD_ID =3D 1} is ad=
ded in
> > include/linux/aio.h:
> >=20
> > 	- IO_NOTIFY_SIGNAL means that the signal is to be sent to the
> > 	  requesting thread=20
> >=20
> > 	- IO_NOTIFY_THREAD_ID means that the signal is to be sent to a
> > 	  specifi thread.
>=20
> This has been proved to be sufficient in the timer code which basical=
ly
> has the same problem.  But why do you need separate constants?  We ha=
ve
> the various SIGEV_* constants, among them SIGEV_THREAD_ID.  Just use
> these constants for the values of ki_notify.
>=20

I am wondering about that too. IIRC, the IO_NOTIFY_* constants are not
part of the ABI, but only internal to the kernel implementation. I thin=
k
Zach had suggested inferring THREAD_ID notification if the pid specifie=
d
is not zero. But, I don't see why ->sigev_notify couldn't used directly
(just like the POSIX timers code does) thus doing away with the=20
new constants altogether. Sebestian/Laurent, do you recall?

>=20
> >   The following fields are added to struct kiocb in include/linux/a=
io.h:
> >=20
> > 	- pid_t ki_pid: target of the signal
> >=20
> > 	- __u16 ki_signo: signal number
> >=20
> > 	- __u16 ki_notify: kind of notification, IO_NOTIFY_SIGNAL or
> > 			   IO_NOTIFY_THREAD_ID
> >=20
> > 	- uid_t ki_uid, ki_euid: filled with the submitter credentials
>=20
> These two fields aren't needed for the POSIX interfaces.  Where does =
the
> requirement come from?  I don't say they should be removed, they migh=
t
> be useful, but if the costs are non-negligible then they could go awa=
y.

I'm guessing they are being used for validation of permissions at the t=
ime
of sending the signal, but maybe saving the task pointer in the iocb in=
stead
of the pid would suffice ?

>=20
>=20
> > 	- check whether the submitting thread wants to be notified directl=
y
> > 	  (sigevent->sigev_notify_thread_id is 0) or wants the signal to b=
e sent
> > 	  to another thread.
> > 	  In the latter case a check is made to assert that the target thr=
ead
> > 	  is in the same thread group
>=20
> Is this really how it's implemented?  This is not how it should be.
> Either a signal is sent to a specific thread in the same process (thi=
s
> is what SIGEV_THREAD_ID is for) or the signal is sent to a calling
> process.  Sending a signal to the process means that from the kernel'=
s
> POV any thread which doesn't have the signal blocked can receive it.
> The final decision is made by the kernel.  There is no mechanism to s=
end
> the signal to another process.

The code seems to be set up to call specific_send_sig_info() in the cas=
e
of *_THREAD_ID , and __group_send_sig_info() otherwise. So I think the
intended behaviour is as you describe it should be (__group_send_sig_in=
fo
does the equivalent of sending a signal to the process and so any threa=
d
which doesn't have signals blocked can receive it, while specific_send_=
sig_info
sends it to a particular thread).=20

But, I should really leave it to Sebestian to confirm that.

>=20
> So, for the purpose of the POSIX AIO code the ki_pid value is only
> needed when the SIGEV_THREAD_ID bit is set.
>=20
> It could be an extension and I don't mind it being introduced.  But
> again, it's not necessary and if it adds costs then it could be left
> out.  It is something which could easily be introduced later if the n=
eed
> arises.
>=20
>=20
> > 			    listio support
> >=20
>=20
> I really don't understand the kernel interface for this feature.

I'm sorry this is confusing. This probably means that we need to
separate the external interface description more clearly and completely
from the internals.

>=20
>=20
> > Details:
> > -------
> >=20
> >   An IOCB_CMD_GROUP is added to the IOCB_CMD enum in include/linux/=
aio_abi.h
> >=20
> >   A struct lio_event is added in include/linux/aio.h
> >=20
> >   A struct lio_event *ki_lio is added to struct iocb in include/lin=
ux/aio.h
>=20
> So you have a pointer in the structure for the individual requests.  =
I
> assume you use the atomic counter to trigger the final delivery.  I
> further assume that if lio_wait is set the calling thread is suspende=
d
> until all requests are handled and that the final notification in thi=
s
> case means that thread gets woken.
>=20
> This is all fine.
>=20
> But how do you pass the requests to the kernel?  If you have a new
> lio_listio-like syscall it'll be easy.  But I haven't seen anything l=
ike
> this mentioned.
>=20
> The alternative is to pass the requests one-by-one in which case I do=
n't
> see how you create the reference to the lio_listio control block.  Th=
is
> approach seems to be slower.

The way it works (and better ideas are welcome) is that, since the io_s=
ubmit()
syscall already accepts an array of iocbs[], no new syscall was introdu=
ced.
To implement lio_listio, one has to set up such an array, with the firs=
t iocb
in the array having the special (new) grouping opcode of IOCB_CMD_GROUP=
 which
specifies the sigev notification to be associated with group completion
(a NULL value of the sigev notification pointer would imply equivalent =
of
LIO_WAIT). The following iocbs in the array should correspond to the se=
t of
listio aiocbs. Whenever it encounters an IOCB_CMD_GROUP iocb opcode, th=
e
kernel would interpret all subsequent iocbs[] submitted in the same
io_submit() call to be associated with the same lio control block.=20

Does that clarify ?

Would an example help ?

>=20
> If all requests are passed at once, do you have the equivalent of
> LIO_NOP entries?
>=20

Good question - we do have an IOCB_CMD_NOOP defined, and I seem to even
recall a patch that implemented it, but am wondering if it ever got mer=
ged.
Ben/Zach ?

>=20
> How can we support the extension where we wait for a number of reques=
ts
> which need not be all of them.  I.e., I submit N requests and want to=
 be
> notified when at least M (M <=3D N) notified.  I am not yet clear abo=
ut
> the actual semantics we should implement (e.g., do we send another
> notification after the first one?) but it's something which IMO shoul=
d
> be taken into account in the design.
>=20

My thought here was that it should be possible to include M as a parame=
ter
to the IOCB_CMD_GROUP opcode iocb, and thus incorporated in the lio con=
trol
block ... then whatever semantics are agreed upon can be implemented.

>=20
> Finally, and this is very important, does you code send out the
> individual requests notification and then in the end the lio_listio
> completion?  I think Suparna wrote this is the case but I want to mak=
e sure.

Sebestian, could you confirm ?

>=20
>=20
> Overall, this looks much better than the old code.  If the answers to=
 my
> questions show that the behavior is compatible with the POSIX AIO cod=
e
> I'm certainly very much in favor of adding the kernel code.

Thanks a lot for looking through this !
Let us know what you think about the listio interface ... hopefully the
other issues are mostly simple to resolve.

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

