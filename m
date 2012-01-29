From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 21/29] sysctl: Add a root pointer to ctl_table_set
Date: Sun, 29 Jan 2012 19:19:29 +0200
Message-ID: <CAPLs8y-+kg9TvjwjQgOU0_2Fqr+2dAhE0fO3cB7e_wpH1jHeBA@mail.gmail.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org> <1327639925-12920-21-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Damien Millescamps <damien.millescamps@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1327639925-12920-21-git-send-email-ebiederm@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2012 at 6:51 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Add a ctl_table_root pointer to ctl_table set so it is easy to

"ctl_table set" -> "ctl_table_set"

> go from a ctl_table_set to a ctl_table_root.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =C2=A0fs/proc/proc_sysctl.c =C2=A0| =C2=A0 =C2=A03 +++
> =C2=A0include/linux/sysctl.h | =C2=A0 =C2=A03 +++
> =C2=A0net/sysctl_net.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A05 ++---
> =C2=A03 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index d9c3ae6..65c13dd 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -45,6 +45,7 @@ static struct ctl_table_header root_table_header =3D=
 {
> =C2=A0static struct ctl_table_root sysctl_table_root =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.root_list =3D LIST_HEAD_INIT(sysctl_table=
_root.root_list),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.default_set.list =3D LIST_HEAD_INIT(root_=
table_header.ctl_entry),
> + =C2=A0 =C2=A0 =C2=A0 .default_set.root =3D &sysctl_table_root,
> =C2=A0};
>
> =C2=A0static DEFINE_SPINLOCK(sysctl_lock);
> @@ -1348,9 +1349,11 @@ void unregister_sysctl_table(struct ctl_table_=
header * header)
> =C2=A0EXPORT_SYMBOL(unregister_sysctl_table);
>
> =C2=A0void setup_sysctl_set(struct ctl_table_set *p,
> + =C2=A0 =C2=A0 =C2=A0 struct ctl_table_root *root,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*is_seen)(struct ctl_table_set *))
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&p->list);
> + =C2=A0 =C2=A0 =C2=A0 p->root =3D root;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->is_seen =3D is_seen;
> =C2=A0}
>
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index e40b8f6..e73ba33 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -1047,6 +1047,7 @@ struct ctl_table_header
>
> =C2=A0struct ctl_table_set {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head list;
> + =C2=A0 =C2=A0 =C2=A0 struct ctl_table_root *root;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*is_seen)(struct ctl_table_set *);
> =C2=A0};
>
> @@ -1069,6 +1070,7 @@ struct ctl_path {
> =C2=A0void proc_sys_poll_notify(struct ctl_table_poll *poll);
>
> =C2=A0extern void setup_sysctl_set(struct ctl_table_set *p,
> + =C2=A0 =C2=A0 =C2=A0 struct ctl_table_root *root,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*is_seen)(struct ctl_table_set *));
> =C2=A0extern void retire_sysctl_set(struct ctl_table_set *set);
>
> @@ -1103,6 +1105,7 @@ static inline void unregister_sysctl_table(stru=
ct ctl_table_header * table)
> =C2=A0}
>
> =C2=A0static inline void setup_sysctl_set(struct ctl_table_set *p,
> + =C2=A0 =C2=A0 =C2=A0 struct ctl_table_root *root,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*is_seen)(struct ctl_table_set *))
> =C2=A0{
> =C2=A0}
> diff --git a/net/sysctl_net.c b/net/sysctl_net.c
> index 07c6b87..e998c64 100644
> --- a/net/sysctl_net.c
> +++ b/net/sysctl_net.c
> @@ -74,8 +74,7 @@ static struct ctl_table_root net_sysctl_ro_root =3D=
 {
>
> =C2=A0static int __net_init sysctl_net_init(struct net *net)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 setup_sysctl_set(&net->sysctls,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0is_seen);
> + =C2=A0 =C2=A0 =C2=A0 setup_sysctl_set(&net->sysctls, &net_sysctl_ro=
ot, is_seen);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> @@ -95,7 +94,7 @@ static __init int net_sysctl_init(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D register_pernet_subsys(&sysctl_per=
net_ops);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> - =C2=A0 =C2=A0 =C2=A0 setup_sysctl_set(&net_sysctl_ro_root.default_s=
et, NULL);
> + =C2=A0 =C2=A0 =C2=A0 setup_sysctl_set(&net_sysctl_ro_root.default_s=
et, &net_sysctl_ro_root, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0register_sysctl_root(&net_sysctl_ro_root);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0register_sysctl_root(&net_sysctl_root);
> =C2=A0out:
> --
> 1.7.2.5
>



--=20
=C2=A0.
=2E.: Lucian
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
