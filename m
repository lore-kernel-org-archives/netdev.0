From: John <da_audiophile@yahoo.com>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Mon, 17 Feb 2014 12:35:51 -0800 (PST)
Message-ID: <1392669351.46253.YahooMailNeo@web140005.mail.bf1.yahoo.com>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>	 <20140215203015.GA4528@pd.tnic>	 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <20140215232508.GB4508@pd.tnic> <1392571653.44773.4.camel@leira.trondhjem.org>
Reply-To: John <da_audiophile@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"mlindner@marvell.com" <mlindner@marvell.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
	Borislav Petkov <bp@alien8.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm6.bullet.mail.bf1.yahoo.com ([98.139.212.165]:37235 "EHLO
	nm6.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753280AbaBQUfw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 15:35:52 -0500
In-Reply-To: <1392571653.44773.4.camel@leira.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





----- Original Message -----
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> To: Borislav Petkov <bp@alien8.de>; Linux NFS Mailing List <linux-nfs=
@vger.kernel.org>
> Cc: John <da_audiophile@yahoo.com>; lkml <linux-kernel@vger.kernel.or=
g>; "netdev@vger.kernel.org" <netdev@vger.kernel.org>; "stephen@network=
plumber.org" <stephen@networkplumber.org>; "mlindner@marvell.com" <mlin=
dner@marvell.com>; J. Bruce Fields <bfields@fieldses.org>
> Sent: Sunday, February 16, 2014 12:27 PM
> Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
>=20
> Please ensure that you post to the linux-nfs@vger.kernel.org when
> reporting NFS and RPC related bugs.
>=20
> Does the following patch help?
>=20
> 8<-------------------------------------------------------------------
> From 0e57b109cd7b17d6e6f16c3454427372a583b18a Mon Sep 17 00:00:00 200=
1
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 16 Feb 2014 12:14:13 -0500
> Subject: [PATCH] SUNRPC: Ensure that gss_auth isn't freed before its =
upcall
> messages
>=20
> Fix a race in which the RPC client is shutting down while the
> gss daemon is processing a downcall. If the RPC client manages to
> shut down before the gss daemon is done, then the struct gss_auth
> used in gss_release_msg() may have already been freed.
>=20
> Link:=20
> http://lkml.kernel.org/r/1392494917.71728.YahooMailNeo@web140002.mail=
=2Ebf1.yahoo.com
> Reported-by: John <da_audiophile@yahoo.com>
> Reported-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> net/sunrpc/auth_gss/auth_gss.c | 13 +++++++++++--
> 1 file changed, 11 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/aut=
h_gss.c
> index 44a61e8fda6f..1ba1fd114912 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -108,6 +108,7 @@ struct gss_auth {
> static DEFINE_SPINLOCK(pipe_version_lock);
> static struct rpc_wait_queue pipe_version_rpc_waitqueue;
> static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
> +static void gss_put_auth(struct gss_auth *gss_auth);
>=20
> static void gss_free_ctx(struct gss_cl_ctx *);
> static const struct rpc_pipe_ops gss_upcall_ops_v0;
> @@ -320,6 +321,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
> =A0=A0=A0 if (gss_msg->ctx !=3D NULL)
> =A0=A0=A0 =A0=A0=A0 gss_put_ctx(gss_msg->ctx);
> =A0=A0=A0 rpc_destroy_wait_queue(&gss_msg->rpc_waitqueue);
> +=A0=A0=A0 gss_put_auth(gss_msg->auth);
> =A0=A0=A0 kfree(gss_msg);
> }
>=20
> @@ -500,6 +502,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
> =A0=A0=A0 =A0=A0=A0 if (err)
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 goto err_free_msg;
> =A0=A0=A0 };
> +=A0=A0=A0 kref_get(&gss_auth->kref);
> =A0=A0=A0 return gss_msg;
> err_free_msg:
> =A0=A0=A0 kfree(gss_msg);
> @@ -1064,6 +1067,12 @@ gss_free_callback(struct kref *kref)
> }
>=20
> static void
> +gss_put_auth(struct gss_auth *gss_auth)
> +{
> +=A0=A0=A0 kref_put(&gss_auth->kref, gss_free_callback);
> +}
> +
> +static void
> gss_destroy(struct rpc_auth *auth)
> {
> =A0=A0=A0 struct gss_auth *gss_auth =3D container_of(auth,
> @@ -1084,7 +1093,7 @@ gss_destroy(struct rpc_auth *auth)
> =A0=A0=A0 gss_auth->gss_pipe[1] =3D NULL;
> =A0=A0=A0 rpcauth_destroy_credcache(auth);
>=20
> -=A0=A0=A0 kref_put(&gss_auth->kref, gss_free_callback);
> +=A0=A0=A0 gss_put_auth(gss_auth);
> }
>=20
> /*
> @@ -1255,7 +1264,7 @@ gss_destroy_nullcred(struct rpc_cred *cred)
> =A0=A0=A0 call_rcu(&cred->cr_rcu, gss_free_cred_callback);
> =A0=A0=A0 if (ctx)
> =A0=A0=A0 =A0=A0=A0 gss_put_ctx(ctx);
> -=A0=A0=A0 kref_put(&gss_auth->kref, gss_free_callback);
> +=A0=A0=A0 gss_put_auth(gss_auth);
>=20
> }
>=20
> static void
> --=20


Tested-by: John <da_audiophile@yahoo.com>


=46ixes the problem on 3.13.3 for me (i686). Thank you.
