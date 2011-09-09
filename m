From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Fri, 09 Sep 2011 15:25:08 -0400
Message-ID: <1315596308.17611.46.camel@lade.trondhjem.org>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
	 <20110909120844.13697.48102.stgit@localhost6.localdomain6>
	 <20110909100745.7e2e8bf9@corrin.poochiereds.net>
	 <4E6A41D4.6090001@parallels.com>
	 <1315593874.17611.19.camel@lade.trondhjem.org>
	 <20110909150104.5a83c60d@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110909150104.5a83c60d-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-09-09 at 15:01 -0400, Jeff Layton wrote:=20
> On Fri, 09 Sep 2011 14:44:34 -0400
> Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org> wrote:
>=20
> > On Fri, 2011-09-09 at 20:41 +0400, Stanislav Kinsbursky wrote:=20
> > > 09.09.2011 18:07, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > On Fri, 09 Sep 2011 16:08:44 +0400
> > > > Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
> > > >
> > > >> Create rcbind clients or increase rpcbind users counter during=
 RPC service
> > > >> creation and decrease this counter (and possibly destroy those=
 clients) on RPC
> > > >> service destruction.
> > > >>
> > > >> Signed-off-by: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> > > >>
> > > >> ---
> > > >>   include/linux/sunrpc/clnt.h |    2 ++
> > > >>   net/sunrpc/rpcb_clnt.c      |    2 +-
> > > >>   net/sunrpc/svc.c            |   13 +++++++++++--
> > > >>   3 files changed, 14 insertions(+), 3 deletions(-)
> > > >>
> > > >> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrp=
c/clnt.h
> > > >> index db7bcaf..65a8115 100644
> > > >> --- a/include/linux/sunrpc/clnt.h
> > > >> +++ b/include/linux/sunrpc/clnt.h
> > > >> @@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_cln=
t *);
> > > >>   void		rpc_release_client(struct rpc_clnt *);
> > > >>   void		rpc_task_release_client(struct rpc_task *);
> > > >>
> > > >> +int		rpcb_create_local(void);
> > > >>   int		rpcb_register(u32, u32, int, unsigned short);
> > > >>   int		rpcb_v4_register(const u32 program, const u32 version,
> > > >>   				 const struct sockaddr *address,
> > > >>   				 const char *netid);
> > > >> +void		rpcb_put_local(void);
> > > >>   void		rpcb_getport_async(struct rpc_task *);
> > > >>
> > > >>   void		rpc_call_start(struct rpc_task *);
> > > >> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> > > >> index b4cc0f1..437ec60 100644
> > > >> --- a/net/sunrpc/rpcb_clnt.c
> > > >> +++ b/net/sunrpc/rpcb_clnt.c
> > > >> @@ -318,7 +318,7 @@ out:
> > > >>    * Returns zero on success, otherwise a negative errno value
> > > >>    * is returned.
> > > >>    */
> > > >> -static int rpcb_create_local(void)
> > > >> +int rpcb_create_local(void)
> > > >>   {
> > > >>   	static DEFINE_MUTEX(rpcb_create_local_mutex);
> > > >>   	int result =3D 0;
> > > >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > >> index 6a69a11..9095c0e 100644
> > > >> --- a/net/sunrpc/svc.c
> > > >> +++ b/net/sunrpc/svc.c
> > > >> @@ -367,8 +367,11 @@ __svc_create(struct svc_program *prog, un=
signed int bufsize, int npools,
> > > >>   	unsigned int xdrsize;
> > > >>   	unsigned int i;
> > > >>
> > > >> -	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
> > > >> +	if (rpcb_create_local()<  0)
> > > >>   		return NULL;
> > > >> +
> > > >> +	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
> > > >> +		goto out_err;
> > > >>   	serv->sv_name      =3D prog->pg_name;
> > > >>   	serv->sv_program   =3D prog;
> > > >>   	serv->sv_nrthreads =3D 1;
> > > >> @@ -403,7 +406,7 @@ __svc_create(struct svc_program *prog, uns=
igned int bufsize, int npools,
> > > >>   			GFP_KERNEL);
> > > >>   	if (!serv->sv_pools) {
> > > >>   		kfree(serv);
> > > >> -		return NULL;
> > > >> +		goto out_err;
> > > >>   	}
> > > >>
> > > >>   	for (i =3D 0; i<  serv->sv_nrpools; i++) {
> > > >> @@ -423,6 +426,10 @@ __svc_create(struct svc_program *prog, un=
signed int bufsize, int npools,
> > > >>   	svc_unregister(serv);
> > > >>
> > > >>   	return serv;
> > > >> +
> > > >> +out_err:
> > > >> +	rpcb_put_local();
> > > >> +	return NULL;
> > > >>   }
> > > >>
> > > >>   struct svc_serv *
> > > >> @@ -491,6 +498,8 @@ svc_destroy(struct svc_serv *serv)
> > > >>   	svc_unregister(serv);
> > > >>   	kfree(serv->sv_pools);
> > > >>   	kfree(serv);
> > > >> +
> > > >> +	rpcb_put_local();
> > > >>   }
> > > >>   EXPORT_SYMBOL_GPL(svc_destroy);
> > > >>
> > > >>
> > > >
> > > > I don't get it -- what's the advantage of creating rpcbind clie=
nts in
> > > > __svc_create vs. the old way of creating them just before we pl=
an to
> > > > use them?
> > > >
> > >=20
> > > The main problem here is not in creation, but in destroying those=
 clients.
> > > Now rpcbind clients are created during rpcb_register(). I.e. once=
 per every family, program version and so on.
> > > But can be unregistered for all protocol families by one call. So=
 it's impossible to put reference counting for those clients in the pla=
ce, where they are created now.
> >=20
> > Could we perhaps set up a 'struct pernet_operations' to create a
> > destructor for them?
> >=20
>=20
> An even easier idea might be to just not take a reference to the
> rpcbind client for svc_programs that have vs_hidden set on every
> version.

Isn't the problem that Stanislav is trying to solve that we need to be
able to register and unregister RPC services to the correct rpcbind
server, depending on which net namespace we are in?

My understanding is that the current code will register everything to
whatever rpcbind server is running in the init net namespace because
that's what rpcb_create_local() uses.

My suggestion is to use a struct pernet_operations to detect when a net
namespace is being created or destroyed, so that the rpcbind client cod=
e
knows when to create or destroy a connection to the server that is
running in that namespace.

Cheers
  Trond
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
