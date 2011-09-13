From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Tue, 13 Sep 2011 08:51:39 -0400
Message-ID: <20110913085139.00f112e2@corrin.poochiereds.net>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
	<20110909120844.13697.48102.stgit@localhost6.localdomain6>
	<20110909100745.7e2e8bf9@corrin.poochiereds.net>
	<4E6A41D4.6090001@parallels.com>
	<1315593874.17611.19.camel@lade.trondhjem.org>
	<20110909150104.5a83c60d@tlielax.poochiereds.net>
	<1315596308.17611.46.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab1IMMsg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 08:48:36 -0400
In-Reply-To: <1315596308.17611.46.camel@lade.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Sep 2011 15:25:08 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2011-09-09 at 15:01 -0400, Jeff Layton wrote:=20
> > On Fri, 09 Sep 2011 14:44:34 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> >=20
> > > On Fri, 2011-09-09 at 20:41 +0400, Stanislav Kinsbursky wrote:=20
> > > > 09.09.2011 18:07, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > > On Fri, 09 Sep 2011 16:08:44 +0400
> > > > > Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
> > > > >
> > > > >> Create rcbind clients or increase rpcbind users counter duri=
ng RPC service
> > > > >> creation and decrease this counter (and possibly destroy tho=
se clients) on RPC
> > > > >> service destruction.
> > > > >>
> > > > >> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.co=
m>
> > > > >>
> > > > >> ---
> > > > >>   include/linux/sunrpc/clnt.h |    2 ++
> > > > >>   net/sunrpc/rpcb_clnt.c      |    2 +-
> > > > >>   net/sunrpc/svc.c            |   13 +++++++++++--
> > > > >>   3 files changed, 14 insertions(+), 3 deletions(-)
> > > > >>
> > > > >> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sun=
rpc/clnt.h
> > > > >> index db7bcaf..65a8115 100644
> > > > >> --- a/include/linux/sunrpc/clnt.h
> > > > >> +++ b/include/linux/sunrpc/clnt.h
> > > > >> @@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_c=
lnt *);
> > > > >>   void		rpc_release_client(struct rpc_clnt *);
> > > > >>   void		rpc_task_release_client(struct rpc_task *);
> > > > >>
> > > > >> +int		rpcb_create_local(void);
> > > > >>   int		rpcb_register(u32, u32, int, unsigned short);
> > > > >>   int		rpcb_v4_register(const u32 program, const u32 version=
,
> > > > >>   				 const struct sockaddr *address,
> > > > >>   				 const char *netid);
> > > > >> +void		rpcb_put_local(void);
> > > > >>   void		rpcb_getport_async(struct rpc_task *);
> > > > >>
> > > > >>   void		rpc_call_start(struct rpc_task *);
> > > > >> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> > > > >> index b4cc0f1..437ec60 100644
> > > > >> --- a/net/sunrpc/rpcb_clnt.c
> > > > >> +++ b/net/sunrpc/rpcb_clnt.c
> > > > >> @@ -318,7 +318,7 @@ out:
> > > > >>    * Returns zero on success, otherwise a negative errno val=
ue
> > > > >>    * is returned.
> > > > >>    */
> > > > >> -static int rpcb_create_local(void)
> > > > >> +int rpcb_create_local(void)
> > > > >>   {
> > > > >>   	static DEFINE_MUTEX(rpcb_create_local_mutex);
> > > > >>   	int result =3D 0;
> > > > >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > > >> index 6a69a11..9095c0e 100644
> > > > >> --- a/net/sunrpc/svc.c
> > > > >> +++ b/net/sunrpc/svc.c
> > > > >> @@ -367,8 +367,11 @@ __svc_create(struct svc_program *prog, =
unsigned int bufsize, int npools,
> > > > >>   	unsigned int xdrsize;
> > > > >>   	unsigned int i;
> > > > >>
> > > > >> -	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
> > > > >> +	if (rpcb_create_local()<  0)
> > > > >>   		return NULL;
> > > > >> +
> > > > >> +	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
> > > > >> +		goto out_err;
> > > > >>   	serv->sv_name      =3D prog->pg_name;
> > > > >>   	serv->sv_program   =3D prog;
> > > > >>   	serv->sv_nrthreads =3D 1;
> > > > >> @@ -403,7 +406,7 @@ __svc_create(struct svc_program *prog, u=
nsigned int bufsize, int npools,
> > > > >>   			GFP_KERNEL);
> > > > >>   	if (!serv->sv_pools) {
> > > > >>   		kfree(serv);
> > > > >> -		return NULL;
> > > > >> +		goto out_err;
> > > > >>   	}
> > > > >>
> > > > >>   	for (i =3D 0; i<  serv->sv_nrpools; i++) {
> > > > >> @@ -423,6 +426,10 @@ __svc_create(struct svc_program *prog, =
unsigned int bufsize, int npools,
> > > > >>   	svc_unregister(serv);
> > > > >>
> > > > >>   	return serv;
> > > > >> +
> > > > >> +out_err:
> > > > >> +	rpcb_put_local();
> > > > >> +	return NULL;
> > > > >>   }
> > > > >>
> > > > >>   struct svc_serv *
> > > > >> @@ -491,6 +498,8 @@ svc_destroy(struct svc_serv *serv)
> > > > >>   	svc_unregister(serv);
> > > > >>   	kfree(serv->sv_pools);
> > > > >>   	kfree(serv);
> > > > >> +
> > > > >> +	rpcb_put_local();
> > > > >>   }
> > > > >>   EXPORT_SYMBOL_GPL(svc_destroy);
> > > > >>
> > > > >>
> > > > >
> > > > > I don't get it -- what's the advantage of creating rpcbind cl=
ients in
> > > > > __svc_create vs. the old way of creating them just before we =
plan to
> > > > > use them?
> > > > >
> > > >=20
> > > > The main problem here is not in creation, but in destroying tho=
se clients.
> > > > Now rpcbind clients are created during rpcb_register(). I.e. on=
ce per every family, program version and so on.
> > > > But can be unregistered for all protocol families by one call. =
So it's impossible to put reference counting for those clients in the p=
lace, where they are created now.
> > >=20
> > > Could we perhaps set up a 'struct pernet_operations' to create a
> > > destructor for them?
> > >=20
> >=20
> > An even easier idea might be to just not take a reference to the
> > rpcbind client for svc_programs that have vs_hidden set on every
> > version.
>=20
> Isn't the problem that Stanislav is trying to solve that we need to b=
e
> able to register and unregister RPC services to the correct rpcbind
> server, depending on which net namespace we are in?
>=20
> My understanding is that the current code will register everything to
> whatever rpcbind server is running in the init net namespace because
> that's what rpcb_create_local() uses.
>=20

My assumption in reading this set (maybe wrong) was that this was a
preliminary set for now that just plops in function calls in the places
that do this sort of thing now. I figured that eventually he'd convert
rpcb_create_local, et. al. to do the same thing but within the correct
namespace for the calling task.

> My suggestion is to use a struct pernet_operations to detect when a n=
et
> namespace is being created or destroyed, so that the rpcbind client c=
ode
> knows when to create or destroy a connection to the server that is
> running in that namespace.
>=20

I'm not sure that solves anything. I'd also ass|u|me that something
here (the xprt?) will hold a reference to its netns. If we try to do
this with pernet ops, then I think we'd end up with a chicken-and-egg
problem...

I think the simplest solution would be to basically call these
functions closer to where the rpcbind calls happen today, and just
don't do them when the svc_program has vs_hidden set or if the xprt is
being created with SVC_SOCK_ANONYMOUS set.

In fact, a rethink of the vs_hidden/SVC_SOCK_ANONYMOUS scheme would
probably be a good preliminary patch here. There's a lot of overlap
between those two flags, and somehow consolidating them would probably
be a good thing.

--=20
Jeff Layton <jlayton@redhat.com>
