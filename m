From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 04/11] SUNRPC: parametrize svc creation calls with
 portmapper flag
Date: Mon, 19 Sep 2011 11:07:29 -0400
Message-ID: <20110919110729.33a876ca@tlielax.poochiereds.net>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
	<20110913181351.3961.70207.stgit@localhost6.localdomain6>
	<20110919100811.0eaa39fe@tlielax.poochiereds.net>
	<4E7756F3.4080601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E7756F3.4080601-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Sep 2011 18:51:31 +0400
Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> 19.09.2011 18:08, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > On Tue, 13 Sep 2011 22:13:51 +0400
> > Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
> >
> >> This new flag ("setup_rpcbind) will be used to detect, that new se=
rvice will
> >> send portmapper register calls. For such services we will create r=
pcbind
> >> clients and remove all stale portmap registrations.
> >> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for s=
uch services
> >> in case of this field wasn't initialized earlier. This will allow =
to destroy
> >> rpcbind clients when no other users of them left.
> >>
> >> Signed-off-by: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >>
> >> ---
> >>   include/linux/sunrpc/svc.h |    2 ++
> >>   net/sunrpc/svc.c           |   21 ++++++++++++++-------
> >>   2 files changed, 16 insertions(+), 7 deletions(-)
> >>
> >> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc=
=2Eh
> >> index 223588a..528952a 100644
> >> --- a/include/linux/sunrpc/svc.h
> >> +++ b/include/linux/sunrpc/svc.h
> >> @@ -402,11 +402,13 @@ struct svc_procedure {
> >>    * Function prototypes.
> >>    */
> >>   struct svc_serv *svc_create(struct svc_program *, unsigned int,
> >> +			    int setup_rpcbind,
> > 				^^^
> > 			Instead of adding this parameter, why not
> > 			base this on the vs_hidden flag in the
> > 			svc_version? IOW, have a function that looks at
> > 			all the svc_versions for a particular
> > 			svc_program, and returns "true" if any of them
> > 			have vs_hidden unset? The mechanism you're
> > 			proposing here has the potential to be out of
> > 			sync with the vs_hidden flag.
> >
>=20
> Could you, please, clarify me this vs_hidden flag?
> I understand, that it's used to avoid portmap registration.
> But as I see, it's set only for nfs_callback_version1. But this svc_v=
ersion is a=20
> part of nfs4_callback_program with nfs_callback_version4, which is no=
t hidden.
> Does this flag is missed here? If not, how we can return "true" from =
your=20
> proposed function if any of them have vs_hidden unset?
>=20
> Also sockets for this program are created with SVC_SOCK_ANONYMOUS fla=
g and we=20
> will not register any of this program versions with portmapper.
> Thus, from my pow, this vs_hidden flag affects only svc_unregister. A=
nd only=20
> nfs_callback_version1. This looks really strange.
>=20
> I.e. if we use this flag only for passing through this versions durin=
g=20
> svc_(un)register, and we actually also want to pass through=20
> nfs_callback_version4 as well (but just missed this vs_hidden flag fo=
r it), then=20
> with current patch-set we can move this flag from (vs_hidden) svc_ver=
sion to=20
> svc_program and check it during svc_create instead of my home-brew=20
> "setup_rpcbind" variable.
>=20

Agreed. The current situation is a mess, which is why I suggested a
cleanup and overhaul before you do this...

The vs_hidden flag is intended to show that a particular program
version should not be registered with (or unregistered from) the
portmapper. Unfortunately, nothing looks at vs_hidden during
registration time, only when unregistering (as you mention).

It's quite possible that several svc_versions declared in the kernel do
not have this set correctly. One thing that would be good is to audit
each of those.

We currently rely on SVC_SOCK_ANONYMOUS for registration, but that
wasn't its original intent. It's was just convenient to use it there
too.

SVC_SOCK_ANONYMOUS was (as best I can tell) originally intended for use
on temporary sockets that we establish on receive. So for
instance...when a client connects to nfsd, we need to create a new
socket for nfsd, but obviously we don't want to register that socket
with the portmapper (since nfsd should already be registered there).
SVC_SOCK_ANONYMOUS ensures that that socket is not registered.

The whole scheme could probably use a fundamental re-think. I'm not
sure I have a great idea to propose in lieu of it, but I think adding
yet another flag here is probably not the best way to go.

> > 			Also, if you're adding an argument to a
> > 			function like this, you you really ought to
> > 			change the callers in the same patch. Otherwise
> > 			you'll cause a build break if someone tries to
> > 			bisect and ends up between the patch that
> > 			changes the function and the one that changes
> > 			the callers.
> >
> >>   			void (*shutdown)(struct svc_serv *));
> >>   struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
> >>   					struct svc_pool *pool);
> >>   void		   svc_exit_thread(struct svc_rqst *);
> >>   struct svc_serv *  svc_create_pooled(struct svc_program *, unsig=
ned int,
> >> +			int setup_rpcbind,
> >>   			void (*shutdown)(struct svc_serv *),
> >>   			svc_thread_fn, struct module *);
> >>   int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *=
, int);
> >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> index f31e5cc..03231d5 100644
> >> --- a/net/sunrpc/svc.c
> >> +++ b/net/sunrpc/svc.c
> >> @@ -378,7 +378,7 @@ static void svc_rpcb_cleanup(struct svc_serv *=
serv)
> >>    */
> >>   static struct svc_serv *
> >>   __svc_create(struct svc_program *prog, unsigned int bufsize, int=
 npools,
> >> -	     void (*shutdown)(struct svc_serv *serv))
> >> +	     int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
> >>   {
> >>   	struct svc_serv	*serv;
> >>   	unsigned int vers;
> >> @@ -437,29 +437,36 @@ __svc_create(struct svc_program *prog, unsig=
ned int bufsize, int npools,
> >>   		spin_lock_init(&pool->sp_lock);
> >>   	}
> >>
> >> -	/* Remove any stale portmap registrations */
> >> -	svc_unregister(serv);
> >> +	if (setup_rpcbind) {
> >> +	       	if (svc_rpcb_setup(serv)<  0) {
> >> +			kfree(serv->sv_pools);
> >> +			kfree(serv);
> >> +			return NULL;
> >> +		}
> >> +		if (!serv->sv_shutdown)
> >> +			serv->sv_shutdown =3D svc_rpcb_cleanup;
> >> +	}
> >>
> >>   	return serv;
> >>   }
> >>
> >>   struct svc_serv *
> >>   svc_create(struct svc_program *prog, unsigned int bufsize,
> >> -	   void (*shutdown)(struct svc_serv *serv))
> >> +	   int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
> >>   {
> >> -	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
> >> +	return __svc_create(prog, bufsize, /*npools*/1, setup_rpcbind, s=
hutdown);
> >>   }
> >>   EXPORT_SYMBOL_GPL(svc_create);
> >>
> >>   struct svc_serv *
> >>   svc_create_pooled(struct svc_program *prog, unsigned int bufsize=
,
> >> -		  void (*shutdown)(struct svc_serv *serv),
> >> +		  int setup_rpcbind, void (*shutdown)(struct svc_serv *serv),
> >>   		  svc_thread_fn func, struct module *mod)
> >>   {
> >>   	struct svc_serv *serv;
> >>   	unsigned int npools =3D svc_pool_map_get();
> >>
> >> -	serv =3D __svc_create(prog, bufsize, npools, shutdown);
> >> +	serv =3D __svc_create(prog, bufsize, npools, setup_rpcbind, shut=
down);
> >>
> >>   	if (serv !=3D NULL) {
> >>   		serv->sv_function =3D func;
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
> >> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
>=20
>=20


--=20
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
