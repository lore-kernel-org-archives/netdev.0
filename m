From: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Subject: Re: [PATCH] net/9p: Insulate the client against an invalid error code
	sent by a 9p server.
Date: Mon, 27 Jul 2009 09:59:18 -0600
Message-ID: <f6e1b7990907270859l65f84d8bm4712f6d82d9a688a@mail.gmail.com>
References: <1248707662-4060-1-git-send-email-adkulkar@umail.iu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752385AbZG0P7T@vger.kernel.org>
In-Reply-To: <1248707662-4060-1-git-send-email-adkulkar@umail.iu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding netdev to Cc.
---

A looney tunes server sending an invalid error code (which is !IS_ERR_V=
ALUE)
can result in a client oops. So fix it by adding a check and converting=
 unknown
or invalid error codes to -ESERVERFAULT.

Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
---
:100644 100644 787ccdd... c9a5bf9... M	net/9p/client.c
:100644 100644 fdebe43... 5251851... M	net/9p/error.c
 net/9p/client.c |    7 +------
 net/9p/error.c  |    2 +-
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 787ccdd..c9a5bf9 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -411,14 +411,9 @@ static int p9_check_errors(struct p9_client *c,
struct p9_req_t *req)
 		if (c->dotu)
 			err =3D -ecode;

-		if (!err) {
+		if (!err || !IS_ERR_VALUE(err))
 			err =3D p9_errstr2errno(ename, strlen(ename));

-			/* string match failed */
-			if (!err)
-				err =3D -ESERVERFAULT;
-		}
-
 		P9_DPRINTK(P9_DEBUG_9P, "<<< RERROR (%d) %s\n", -ecode, ename);

 		kfree(ename);
diff --git a/net/9p/error.c b/net/9p/error.c
index fdebe43..5251851 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -239,7 +239,7 @@ int p9_errstr2errno(char *errstr, int len)
 		errstr[len] =3D 0;
 		printk(KERN_ERR "%s: server reported unknown error %s\n",
 			__func__, errstr);
-		errno =3D 1;
+		errno =3D ESERVERFAULT;
 	}

 	return -errno;
--=20
1.6.0.4


On Mon, Jul 27, 2009 at 9:14 AM, Abhishek Kulkarni<adkulkar@umail.iu.ed=
u> wrote:
> A looney tunes server sending an invalid error code (which is !IS_ERR=
_VALUE)
> can result in a client oops. So fix it by adding a check and converti=
ng unknown
> or invalid error codes to -ESERVERFAULT.
>
> Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
> ---
> :100644 100644 787ccdd... c9a5bf9... M =A0net/9p/client.c
> :100644 100644 fdebe43... 5251851... M =A0net/9p/error.c
> =A0net/9p/client.c | =A0 =A07 +------
> =A0net/9p/error.c =A0| =A0 =A02 +-
> =A02 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/net/9p/client.c b/net/9p/client.c
> index 787ccdd..c9a5bf9 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -411,14 +411,9 @@ static int p9_check_errors(struct p9_client *c, =
struct p9_req_t *req)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (c->dotu)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ecode;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!err || !IS_ERR_VALUE(err))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D p9_errstr2errn=
o(ename, strlen(ename));
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* string match failed =
*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D=
 -ESERVERFAULT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0P9_DPRINTK(P9_DEBUG_9P, "<<< RERROR (%=
d) %s\n", -ecode, ename);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(ename);
> diff --git a/net/9p/error.c b/net/9p/error.c
> index fdebe43..5251851 100644
> --- a/net/9p/error.c
> +++ b/net/9p/error.c
> @@ -239,7 +239,7 @@ int p9_errstr2errno(char *errstr, int len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0errstr[len] =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "%s: server reported u=
nknown error %s\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, errstr);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 errno =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 errno =3D ESERVERFAULT;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return -errno;
> --
> 1.6.0.4
>
>
