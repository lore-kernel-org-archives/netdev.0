From: =?ISO-8859-1?Q?S=E9bastien_Dugu=E9?= <sebastien.dugue@bull.net>
Subject: Re: Kernel patches enabling better POSIX AIO (Was Re: [3/4]
	kevent: AIO, aio_sendfile)
Date: Mon, 04 Sep 2006 16:28:55 +0200
Message-ID: <1157380136.3895.44.camel@frecb000686>
References: <44C77C23.7000803@redhat.com> <44C796C3.9030404@us.ibm.com>
	 <1153982954.3887.9.camel@frecb000686> <44C8DB80.6030007@us.ibm.com>
	 <44C9029A.4090705@oracle.com>
	 <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com>
	 <44C90987.1040200@redhat.com>
	 <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com>
	 <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com>
	 <20060812182928.GA1989@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>,
	=?iso-8859-1?Q?S=E9bastien_Dugu=E9_=3Csebastien=2Edugue=40bull=2Enet?=.=?iso-8859-1?Q?=3E?=@qubit.in.ibm.com,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org,
	Benjamin LaHaise <bcrl@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:6623 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP
	id S1751394AbWIDO3L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 10:29:11 -0400
To: suparna@in.ibm.com
In-Reply-To: <20060812182928.GA1989@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hi,

  just came back from vacation, sorry for the delay.

On Sat, 2006-08-12 at 23:59 +0530, Suparna Bhattacharya wrote:
> BTW, if anyone would like to be dropped off this growing cc list, ple=
ase
> let us know.
>=20
> On Fri, Aug 11, 2006 at 12:45:55PM -0700, Ulrich Drepper wrote:
> > S=E9bastien Dugu=E9 wrote:
> > > 		     aio completion notification
> >=20
> > I looked over this now but I don't think I understand everything.  =
Or I
> > don't see how it all is integrated.  And no, I'm not looking at the
> > proposed glibc code since would mean being tainted.
>=20
> Oh, I didn't realise that.=20
> I'll make an attempt to clarify parts that I understand based on what=
 I
> have gleaned from my reading of the code and intent, but hopefully Se=
bastien,
> Ben, Zach et al will be able to pitch in for a more accurate and comp=
lete
> picture.
>=20
> >=20
> >=20
> > > Details:
> > > -------
> > >=20
> > >   A struct sigevent *aio_sigeventp is added to struct iocb in
> > > include/linux/aio_abi.h
> > >=20
> > >   An enum {IO_NOTIFY_SIGNAL =3D 0, IO_NOTIFY_THREAD_ID =3D 1} is =
added in
> > > include/linux/aio.h:
> > >=20
> > > 	- IO_NOTIFY_SIGNAL means that the signal is to be sent to the
> > > 	  requesting thread=20
> > >=20
> > > 	- IO_NOTIFY_THREAD_ID means that the signal is to be sent to a
> > > 	  specifi thread.
> >=20
> > This has been proved to be sufficient in the timer code which basic=
ally
> > has the same problem.  But why do you need separate constants?  We =
have
> > the various SIGEV_* constants, among them SIGEV_THREAD_ID.  Just us=
e
> > these constants for the values of ki_notify.
> >=20
>=20
> I am wondering about that too. IIRC, the IO_NOTIFY_* constants are no=
t
> part of the ABI, but only internal to the kernel implementation. I th=
ink
> Zach had suggested inferring THREAD_ID notification if the pid specif=
ied
> is not zero. But, I don't see why ->sigev_notify couldn't used direct=
ly
> (just like the POSIX timers code does) thus doing away with the=20
> new constants altogether. Sebestian/Laurent, do you recall?

  As I see it, those IO_NOTIFY_* constants are uneeded and we could use
->sigev_notify directly. I will change this so that we use the same
mechanism as the POSIX timers code.

>=20
> >=20
> > >   The following fields are added to struct kiocb in include/linux=
/aio.h:
> > >=20
> > > 	- pid_t ki_pid: target of the signal
> > >=20
> > > 	- __u16 ki_signo: signal number
> > >=20
> > > 	- __u16 ki_notify: kind of notification, IO_NOTIFY_SIGNAL or
> > > 			   IO_NOTIFY_THREAD_ID
> > >=20
> > > 	- uid_t ki_uid, ki_euid: filled with the submitter credentials
> >=20
> > These two fields aren't needed for the POSIX interfaces.  Where doe=
s the
> > requirement come from?  I don't say they should be removed, they mi=
ght
> > be useful, but if the costs are non-negligible then they could go a=
way.
>=20
> I'm guessing they are being used for validation of permissions at the=
 time
> of sending the signal, but maybe saving the task pointer in the iocb =
instead
> of the pid would suffice ?

  IIRC, Ben added these for that exact reason. Is this really needed?
Ben?

>=20
> >=20
> >=20
> > > 	- check whether the submitting thread wants to be notified direc=
tly
> > > 	  (sigevent->sigev_notify_thread_id is 0) or wants the signal to=
 be sent
> > > 	  to another thread.
> > > 	  In the latter case a check is made to assert that the target t=
hread
> > > 	  is in the same thread group
> >=20
> > Is this really how it's implemented?  This is not how it should be.
> > Either a signal is sent to a specific thread in the same process (t=
his
> > is what SIGEV_THREAD_ID is for) or the signal is sent to a calling
> > process.  Sending a signal to the process means that from the kerne=
l's
> > POV any thread which doesn't have the signal blocked can receive it=
=2E
> > The final decision is made by the kernel.  There is no mechanism to=
 send
> > the signal to another process.
>=20
> The code seems to be set up to call specific_send_sig_info() in the c=
ase
> of *_THREAD_ID , and __group_send_sig_info() otherwise. So I think th=
e
> intended behaviour is as you describe it should be (__group_send_sig_=
info
> does the equivalent of sending a signal to the process and so any thr=
ead
> which doesn't have signals blocked can receive it, while specific_sen=
d_sig_info
> sends it to a particular thread).=20
>=20
> But, I should really leave it to Sebestian to confirm that.

  That's right, but I think that part needs to be reworked to follow
the same logic as the POSIX timers.


> > > 			    listio support
> > >=20
> >=20
> > I really don't understand the kernel interface for this feature.
>=20
> I'm sorry this is confusing. This probably means that we need to
> separate the external interface description more clearly and complete=
ly
> from the internals.
>=20
> >=20
> >=20
> > > Details:
> > > -------
> > >=20
> > >   An IOCB_CMD_GROUP is added to the IOCB_CMD enum in include/linu=
x/aio_abi.h
> > >=20
> > >   A struct lio_event is added in include/linux/aio.h
> > >=20
> > >   A struct lio_event *ki_lio is added to struct iocb in include/l=
inux/aio.h
> >=20
> > So you have a pointer in the structure for the individual requests.=
  I
> > assume you use the atomic counter to trigger the final delivery.  I
> > further assume that if lio_wait is set the calling thread is suspen=
ded
> > until all requests are handled and that the final notification in t=
his
> > case means that thread gets woken.
> >=20
> > This is all fine.
> >=20
> > But how do you pass the requests to the kernel?  If you have a new
> > lio_listio-like syscall it'll be easy.  But I haven't seen anything=
 like
> > this mentioned.
> >=20
> > The alternative is to pass the requests one-by-one in which case I =
don't
> > see how you create the reference to the lio_listio control block.  =
This
> > approach seems to be slower.
>=20
> The way it works (and better ideas are welcome) is that, since the io=
_submit()
> syscall already accepts an array of iocbs[], no new syscall was intro=
duced.
> To implement lio_listio, one has to set up such an array, with the fi=
rst iocb
> in the array having the special (new) grouping opcode of IOCB_CMD_GRO=
UP which
> specifies the sigev notification to be associated with group completi=
on
> (a NULL value of the sigev notification pointer would imply equivalen=
t of
> LIO_WAIT). The following iocbs in the array should correspond to the =
set of
> listio aiocbs. Whenever it encounters an IOCB_CMD_GROUP iocb opcode, =
the
> kernel would interpret all subsequent iocbs[] submitted in the same
> io_submit() call to be associated with the same lio control block.=20
>=20
> Does that clarify ?
>=20
> Would an example help ?
>=20
> >=20
> > If all requests are passed at once, do you have the equivalent of
> > LIO_NOP entries?

  So far, LIO_NOP entries are pruned by the support library=20
(libposix-aio) and never sent to the kernel.
> >=20
>=20
> Good question - we do have an IOCB_CMD_NOOP defined, and I seem to ev=
en
> recall a patch that implemented it, but am wondering if it ever got m=
erged.
> Ben/Zach ?
>=20
> >=20
> > How can we support the extension where we wait for a number of requ=
ests
> > which need not be all of them.  I.e., I submit N requests and want =
to be
> > notified when at least M (M <=3D N) notified.  I am not yet clear a=
bout
> > the actual semantics we should implement (e.g., do we send another
> > notification after the first one?) but it's something which IMO sho=
uld
> > be taken into account in the design.
> >=20
>=20
> My thought here was that it should be possible to include M as a para=
meter
> to the IOCB_CMD_GROUP opcode iocb, and thus incorporated in the lio c=
ontrol
> block ... then whatever semantics are agreed upon can be implemented.
>=20
> >=20
> > Finally, and this is very important, does you code send out the
> > individual requests notification and then in the end the lio_listio
> > completion?  I think Suparna wrote this is the case but I want to m=
ake sure.
>=20
> Sebestian, could you confirm ?

  If (and only if) the user did setup a sigevent for one or more
individual requests then those requests completion will trigger a
notification and in the end the list completion notification is sent.=20
Otherwise, only the list completion notification is sent.


--=20
-----------------------------------------------------

  S=E9bastien Dugu=E9                BULL/FREC:B1-247
  phone: (+33) 476 29 77 70      Bullcom: 229-7770

  mailto:sebastien.dugue@bull.net

  Linux POSIX AIO: http://www.bullopensource.org/posix
                   http://sourceforge.net/projects/paiol

-----------------------------------------------------

