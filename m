From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RPC: killing RPC tasks races fixed
Date: Thu, 17 Mar 2011 12:44:14 -0400
Message-ID: <1300380254.28305.1.camel@lade.trondhjem.org>
References: <20110317121638.15035.39410.stgit@localhost6.localdomain6>
	 <1300366904.9654.13.camel@lade.trondhjem.org>
	 <4D822C3C.9090100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"skinsbursky-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <skinsbursky-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D822C3C.9090100-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 18:43 +0300, Stanislav Kinsbursky wrote:
> 17.03.2011 16:01, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > On Thu, 2011-03-17 at 15:16 +0300, Stanislav Kinsbursky wrote:
> >> task->tk_waitqueue must be checked for NULL before trying to wake =
up task in
> >> rpc_killall_tasks() because it can be NULL.
> >>
> >> Here is an example:
> >>
> >> CPU 0               	CPU 1				CPU 2
> >> --------------------	---------------------	-----------------------=
---
> >> nfs4_run_open_task
> >> rpc_run_task
> >> rpc_execute
> >> rpc_set_active
> >> rpc_make_runnable
> >> (waiting)
> >> 			rpc_async_schedule
> >> 			nfs4_open_prepare
> >> 			nfs_wait_on_sequence
> >> 						nfs_umount_begin
> >> 						rpc_killall_tasks
> >> 						rpc_wake_up_task
> >> 						rpc_wake_up_queued_task
> >> 						spin_lock(tk_waitqueue =3D=3D NULL)
> >> 						BUG()
> >> 			rpc_sleep_on
> >> 			spin_lock(&q->lock)
> >> 			__rpc_sleep_on
> >> 			task->tk_waitqueue =3D q
> >>
> >> Signed-off-by: Stanislav Kinsbursky<skinsbursky-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> >>
> >> ---
> >>   net/sunrpc/clnt.c |    4 +++-
> >>   1 files changed, 3 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >> index 57d344c..24039fe 100644
> >> --- a/net/sunrpc/clnt.c
> >> +++ b/net/sunrpc/clnt.c
> >> @@ -436,7 +436,9 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
> >>   		if (!(rovr->tk_flags&  RPC_TASK_KILLED)) {
> >>   			rovr->tk_flags |=3D RPC_TASK_KILLED;
> >>   			rpc_exit(rovr, -EIO);
> >> -			rpc_wake_up_queued_task(rovr->tk_waitqueue, rovr);
> >> +			if (rovr->tk_waitqueue)
> >> +				rpc_wake_up_queued_task(rovr->tk_waitqueue,
> >> +							rovr);
> >
> > Testing for RPC_IS_QUEUED(rovr) would be better, since that would
> > optimise away the call to rpc_wake_up_queued_task() altogether for =
those
> > tasks that aren't queued.
> >
>=20
> Yes, I agree with testing RPC_IS_QUEUED(rovr) since such approach loo=
ks
> clearer and in 2.6.38 tk_waitqueue is initialized prior to set
> RPC_TASK_QUEUED bit.
> But I found this problem in 2.6.32 rhel kernel where this set sequenc=
e is inversed.
> Will send fixed version soon.

Are you sure? Why would the 2.6.32 rhel kernel differ from the mainline
2.6.32 kernel in this respect?

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
