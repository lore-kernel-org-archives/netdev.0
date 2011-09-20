From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 11:11:12 -0400
Message-ID: <20110920111112.3f07cd6e@tlielax.poochiereds.net>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
	<20110920101341.9861.51453.stgit@localhost6.localdomain6>
	<4E7899E7.9090809@parallels.com>
	<20110920102431.58ca1d96@tlielax.poochiereds.net>
	<4E78A6A1.1000800@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E78A6A1.1000800@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2011 18:43:45 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 20.09.2011 18:24, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > On Tue, 20 Sep 2011 17:49:27 +0400
> > Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
> >
> >> v5: fixed races with rpcb_users in rpcb_get_local()
> >>
> >> This helpers will be used for dynamical creation and destruction o=
f rpcbind
> >> clients.
> >> Variable rpcb_users is actually a counter of lauched RPC services.=
 If rpcbind
> >> clients has been created already, then we just increase rpcb_users=
=2E
> >>
> >> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
> >>
> >> ---
> >>    net/sunrpc/rpcb_clnt.c |   53 +++++++++++++++++++++++++++++++++=
+++++++++++++++
> >>    1 files changed, 53 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> >> index e45d2fb..5f4a406 100644
> >> --- a/net/sunrpc/rpcb_clnt.c
> >> +++ b/net/sunrpc/rpcb_clnt.c
> >> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
> >>    static struct rpc_clnt *	rpcb_local_clnt;
> >>    static struct rpc_clnt *	rpcb_local_clnt4;
> >>    +DEFINE_SPINLOCK(rpcb_clnt_lock);
> >> +unsigned int			rpcb_users;
> >> +
> >>    struct rpcbind_args {
> >>    	struct rpc_xprt *	r_xprt;
> >>    @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
> >>    	kfree(map);
> >>    }
> >>    +static int rpcb_get_local(void)
> >> +{
> >> +	int cnt;
> >> +
> >> +	spin_lock(&rpcb_clnt_lock);
> >> +	if (rpcb_users)
> >> +		rpcb_users++;
> >> +	cnt =3D rpcb_users;
> >> +	spin_unlock(&rpcb_clnt_lock);
> >> +
> >> +	return cnt;
> >> +}
> >> +
> >> +void rpcb_put_local(void)
> >> +{
> >> +	struct rpc_clnt *clnt =3D rpcb_local_clnt;
> >> +	struct rpc_clnt *clnt4 =3D rpcb_local_clnt4;
> >> +	int shutdown;
> >> +
> >> +	spin_lock(&rpcb_clnt_lock);
> >> +	if (--rpcb_users =3D=3D 0) {
> >> +		rpcb_local_clnt =3D NULL;
> >> +		rpcb_local_clnt4 =3D NULL;
> >> +	}
> >
> > In the function below, you mention that the above pointers are
> > protected by rpcb_create_local_mutex, but it looks like they get re=
set
> > here without that being held?
> >
>=20
> Assigning of them is protected by rpcb_create_local_mutex.
> Dereferencing of them is protected by rpcb_clnt_lock.
>=20

That's probably a bug, but I haven't sat down to work through the logic=
=2E

> > Might it be simpler to just protect rpcb_users with the
> > rpcb_create_local_mutex and ensure that it's held whenever you call=
 one
> > of these routines? None of these are codepaths are particularly hot=
=2E
> >
>=20
> I just inherited this lock-mutex logic.
> Actually, you right. This codepaths are used rarely.
> But are use sure, that we need to remove this "speed-up" logic if we =
take into=20
> account that it was here already?
>=20

There are many ways to do this...

In general, it's difficult to get locking right, especially when you
start mixing multiple locks on related resources. Personally, I'd go
with a simpler scheme here. There's not much value in protecting this
counter with a spinlock when the other parts need to be protected by a
mutex. If you do decide to do it with multiple locks, then please do
document in comments how the locking is expected to work.=20

An alternate scheme might be to consider doing this with krefs, but I
haven't really considered whether that idiom makes sense here.

--=20
Jeff Layton <jlayton@redhat.com>
