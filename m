From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/2] SUNRPC: register RPC stats /proc entries in passed
 network namespace context
Date: Mon, 30 Jan 2012 13:29:57 -0500
Message-ID: <CAP=VYLoTsFvqez72mLEctmrcHbf0VcfREbHF32zsnh35=RUsHQ@mail.gmail.com>
References: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
	<20111206124240.15702.61866.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111206124240.15702.61866.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2011 at 8:42 AM, Stanislav Kinsbursky
<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> This patch makes it possible to create NFS program entry ("/proc/net/=
rpc/nfs")
> in passed network namespace context instead of hard-coded "init_net".

Hi Trond,

Is this patch going to be dropped and re-submitted?   It has obvious
typos that have been causing reported build failures[1] in linux-next
for a week now.   In addition to that, it has several whitespace errors
(long lines, no space after comma, etc.) that I bet checkpatch.pl
would have found, if it was used.

Commit 4494c750240bab1bb83bd8f4d5a268663c37c9b3 in next-20120130.

Thanks,
Paul.

[1] http://www.spinics.net/lists/linux-next/msg18488.html

>
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>
> ---
> =A0fs/nfs/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 +++---
> =A0include/linux/sunrpc/stats.h | =A0 =A08 ++++----
> =A0net/sunrpc/stats.c =A0 =A0 =A0 =A0 =A0 | =A0 15 ++++++++-------
> =A03 files changed, 15 insertions(+), 14 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 98b2508..5cad6c5 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1623,14 +1623,14 @@ static int __init init_nfs_fs(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out0;
>
> =A0#ifdef CONFIG_PROC_FS
> - =A0 =A0 =A0 rpc_proc_register(&nfs_rpcstat);
> + =A0 =A0 =A0 rpc_proc_register(&init_net, &nfs_rpcstat);
> =A0#endif
> =A0 =A0 =A0 =A0if ((err =3D register_nfs_fs()) !=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0return 0;
> =A0out:
> =A0#ifdef CONFIG_PROC_FS
> - =A0 =A0 =A0 rpc_proc_unregister("nfs");
> + =A0 =A0 =A0 rpc_proc_unregister(&init_net, "nfs");
> =A0#endif
> =A0 =A0 =A0 =A0nfs_destroy_directcache();
> =A0out0:
> @@ -1669,7 +1669,7 @@ static void __exit exit_nfs_fs(void)
> =A0 =A0 =A0 =A0nfs_dns_resolver_destroy();
> =A0 =A0 =A0 =A0nfs_idmap_quit();
> =A0#ifdef CONFIG_PROC_FS
> - =A0 =A0 =A0 rpc_proc_unregister("nfs");
> + =A0 =A0 =A0 rpc_proc_unregister(&init_net, "nfs");
> =A0#endif
> =A0 =A0 =A0 =A0nfs_cleanup_cb_ident_idr();
> =A0 =A0 =A0 =A0unregister_nfs_fs();
> diff --git a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stat=
s.h
> index 680471d..f625b57 100644
> --- a/include/linux/sunrpc/stats.h
> +++ b/include/linux/sunrpc/stats.h
> @@ -58,8 +58,8 @@ void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rpc_modcoun=
t(struct inode *, int);
> =A0#endif
>
> =A0#ifdef CONFIG_PROC_FS
> -struct proc_dir_entry * =A0 =A0 =A0 =A0rpc_proc_register(struct rpc_=
stat *);
> -void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rpc_proc_unregister(const c=
har *);
> +struct proc_dir_entry * =A0 =A0 =A0 =A0rpc_proc_register(struct net =
*,struct rpc_stat *);
> +void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rpc_proc_unregister(struct =
net *,const char *);
> =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rpc_proc_zero(struct rpc_=
program *);
> =A0struct proc_dir_entry * =A0 =A0 =A0 =A0svc_proc_register(struct sv=
c_stat *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0const struct file_operations *);
> @@ -69,8 +69,8 @@ void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0svc_seq_sho=
w(struct seq_file *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 const struct svc_stat *);
> =A0#else
>
> -static inline struct proc_dir_entry *rpc_proc_register(struct rpc_st=
at *s) { return NULL; }
> -static inline void rpc_proc_unregister(const char *p) {}
> +static inline struct proc_dir_entry *rpc_proc_register(struct net *,=
 struct rpc_stat *s) { return NULL; }
> +static inline void rpc_proc_unregisterstruct net *, (const char *p) =
{}
> =A0static inline void rpc_proc_zero(struct rpc_program *p) {}
>
> =A0static inline struct proc_dir_entry *svc_proc_register(struct svc_=
stat *s,
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index 80df89d..f0f6e7c 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -213,28 +213,29 @@ EXPORT_SYMBOL_GPL(rpc_print_iostats);
> =A0* Register/unregister RPC proc files
> =A0*/
> =A0static inline struct proc_dir_entry *
> -do_register(const char *name, void *data, const struct file_operatio=
ns *fops)
> +do_register(struct net *net, const char *name, void *data,
> + =A0 =A0 =A0 =A0 =A0 const struct file_operations *fops)
> =A0{
> =A0 =A0 =A0 =A0struct sunrpc_net *sn;
>
> =A0 =A0 =A0 =A0dprintk("RPC: =A0 =A0 =A0 registering /proc/net/rpc/%s=
\n", name);
> - =A0 =A0 =A0 sn =3D net_generic(&init_net, sunrpc_net_id);
> + =A0 =A0 =A0 sn =3D net_generic(net, sunrpc_net_id);
> =A0 =A0 =A0 =A0return proc_create_data(name, 0, sn->proc_net_rpc, fop=
s, data);
> =A0}
>
> =A0struct proc_dir_entry *
> -rpc_proc_register(struct rpc_stat *statp)
> +rpc_proc_register(struct net *net, struct rpc_stat *statp)
> =A0{
> - =A0 =A0 =A0 return do_register(statp->program->name, statp, &rpc_pr=
oc_fops);
> + =A0 =A0 =A0 return do_register(net, statp->program->name, statp, &r=
pc_proc_fops);
> =A0}
> =A0EXPORT_SYMBOL_GPL(rpc_proc_register);
>
> =A0void
> -rpc_proc_unregister(const char *name)
> +rpc_proc_unregister(struct net *net, const char *name)
> =A0{
> =A0 =A0 =A0 =A0struct sunrpc_net *sn;
>
> - =A0 =A0 =A0 sn =3D net_generic(&init_net, sunrpc_net_id);
> + =A0 =A0 =A0 sn =3D net_generic(net, sunrpc_net_id);
> =A0 =A0 =A0 =A0remove_proc_entry(name, sn->proc_net_rpc);
> =A0}
> =A0EXPORT_SYMBOL_GPL(rpc_proc_unregister);
> @@ -242,7 +243,7 @@ EXPORT_SYMBOL_GPL(rpc_proc_unregister);
> =A0struct proc_dir_entry *
> =A0svc_proc_register(struct svc_stat *statp, const struct file_operat=
ions *fops)
> =A0{
> - =A0 =A0 =A0 return do_register(statp->program->pg_name, statp, fops=
);
> + =A0 =A0 =A0 return do_register(&init_net, statp->program->pg_name, =
statp, fops);
> =A0}
> =A0EXPORT_SYMBOL_GPL(svc_proc_register);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
