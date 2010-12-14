From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 02/22] netconsole: Introduce locking over the netpoll fields
Date: Wed, 15 Dec 2010 00:15:23 +0100
Message-ID: <AANLkTi=reqRMrv4k5EZKdj7pmsomApw9=Kwh9nxfKCuJ@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
	<20101214212904.17022.16604.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>,
	adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101214212904.17022.16604.stgit-tzAwxxnF6Tt6FDdRrpk8kO4/NqBCd+6Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2010/12/14 Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>:
> The netconsole driver currently doesn't do any locking over its
> configuration fields. =A0This can cause problems if we were to ever h=
ave
> concurrent writing to fields while somebody is enabling the service.
>
> For simplicity, this patch extends targets_list_lock to cover all
> configuration fields within the targets. =A0Macros are also added her=
e to
> wrap accessors so that we check whether the target has been enabled w=
ith
> locking handled.
>
> Signed-off-by: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Acked-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
> ---
> =A0drivers/net/netconsole.c | =A0114 ++++++++++++++++++++++++++------=
--------------
> =A01 files changed, 64 insertions(+), 50 deletions(-)
>
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index c87a49e..6e16888 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -327,6 +327,7 @@ static ssize_t store_enabled(struct netconsole_ta=
rget *nt,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *b=
uf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t count)
> =A0{
> + =A0 =A0 =A0 unsigned long flags;
> =A0 =A0 =A0 =A0int err;
> =A0 =A0 =A0 =A0long enabled;
>
> @@ -335,6 +336,10 @@ static ssize_t store_enabled(struct netconsole_t=
arget *nt,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return enabled;
>
> =A0 =A0 =A0 =A0if (enabled) { =A0/* 1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&target_list_lock, fl=
ags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nt->enabled)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto busy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&target_list_loc=
k, flags);
>

This looks wrong. Unless there is another lock or mutex covering this
function, at this point (after spin_unlock_irqrestore()) another
thread might set nt->enabled =3D 1.

Best Regards,
Micha=B3 Miros=B3aw
