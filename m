From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Tue, 13 Sep 2011 17:39:59 +0400
Message-ID: <4E6F5D2F.4050100@parallels.com>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>	<20110909120844.13697.48102.stgit@localhost6.localdomain6>	<20110909100745.7e2e8bf9@corrin.poochiereds.net>	<4E6A41D4.6090001@parallels.com>	<1315593874.17611.19.camel@lade.trondhjem.org>	<20110909150104.5a83c60d@tlielax.poochiereds.net>	<1315596308.17611.46.camel@lade.trondhjem.org> <20110913085139.00f112e2@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110913085139.00f112e2@corrin.poochiereds.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

13.09.2011 16:51, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> My assumption in reading this set (maybe wrong) was that this was a
> preliminary set for now that just plops in function calls in the plac=
es
> that do this sort of thing now. I figured that eventually he'd conver=
t
> rpcb_create_local, et. al. to do the same thing but within the correc=
t
> namespace for the calling task.
>

You have a right assumption. This is exactly what I'm going to do next.

>
> I think the simplest solution would be to basically call these
> functions closer to where the rpcbind calls happen today, and just
> don't do them when the svc_program has vs_hidden set or if the xprt i=
s
> being created with SVC_SOCK_ANONYMOUS set.
>

This solution is not the simplest one since we call svc_register() for =
every svc=20
socket if it's not anonymous. But svc_unregister() is called only once =
for all=20
inet families and protocols.

Also I've noticed, that we call svc_unregister in __svc_create(). I.e. =
we call=20
it for nfs callbacks as well (in spite of that we don't need this). Thu=
s, for=20
now, nfs callbacks service creation depends on rpcbind clients presence=
=2E

So, for my pow, we need something like startup() callback, passed to=20
svc_create(_pooled)() to clean up this mess.
This callback will be defined only for lockd and nfsd and will create r=
pcbind=20
clients and remove any stale portmap registrations.

--=20
Best regards,
Stanislav Kinsbursky
