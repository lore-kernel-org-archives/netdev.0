From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 18/29] sysctl: Normalize the root_table data structure.
Date: Sun, 29 Jan 2012 19:36:06 +0200
Message-ID: <CAPLs8y9-nA7gZymMkFzOdB6zh0h2hS+dhWu42ciOaHzJ++Z+gg@mail.gmail.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org> <1327639925-12920-18-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Damien Millescamps <damien.millescamps@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1327639925-12920-18-git-send-email-ebiederm@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2012 at 6:51 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Every other directory has a .child member and we look at the .child
> for our entries. =C2=A0Do the same for the root_table.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =C2=A0fs/proc/proc_sysctl.c | =C2=A0 15 +++++++++++----
> =C2=A01 files changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index 7e96a26..88d1b06 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -25,7 +25,14 @@ void proc_sys_poll_notify(struct ctl_table_poll *p=
oll)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wake_up_interruptible(&poll->wait);
> =C2=A0}
>
> -static struct ctl_table root_table[1];
> +static struct ctl_table root_table[] =3D {
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .procname =3D "",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .mode =3D S_IRUGO|=
S_IXUGO,

Why not: .mode =3D S_IFDIR|S_IRUGO|S_IXUGO ?

You change it later and add IFDIR in patch 22/29 because of this
change (from 22/29):
-	if (!table->child) {
+	if (!S_ISDIR(table->mode)) {

but if might as well be done here.


> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .child =3D &root_t=
able[1],
> + =C2=A0 =C2=A0 =C2=A0 },
> + =C2=A0 =C2=A0 =C2=A0 { }
> +};
> =C2=A0static struct ctl_table_root sysctl_table_root;
> =C2=A0static struct ctl_table_header root_table_header =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{{.count =3D 1,
> @@ -319,7 +326,7 @@ static struct dentry *proc_sys_lookup(struct inod=
e *dir, struct dentry *dentry,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}

Somewhere above we have
  struct ctl_table *table =3D PROC_I(inode)->sysctl_entry;
and sysctl_entry can take two values:
   - NULL: fs/proc/inode.c:proc_alloc_inode()
   - a non-NULL table in: proc_sys_make_inode()

The only inode that can be passed to proc_sys_lookup that can have
table=3DNULL is the root inode.
In that case head will be &root_table_header.


So head->ctl_table[1] =3D=3D root_table_header.ctl_table[1] =3D=3D root=
_table[1].


>
> - =C2=A0 =C2=A0 =C2=A0 table =3D table ? table->child : head->ctl_tab=
le;
> + =C2=A0 =C2=A0 =C2=A0 table =3D table ? table->child : &head->ctl_ta=
ble[1];

I think this could be improved to something like this:
/* table =3D=3D NULL only for the procfs root directory */
table =3D table ? table->child : &root_table[1];


It's not that important, as this code will go away in a few patches.

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p =3D find_in_table(table, name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!p) {
> @@ -510,7 +517,7 @@ static int proc_sys_readdir(struct file *filp, vo=
id *dirent, filldir_t filldir)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 table =3D table ? table->child : head->ctl_tab=
le;
> + =C2=A0 =C2=A0 =C2=A0 table =3D table ? table->child : &head->ctl_ta=
ble[1];

Similar.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Avoid a switch here: arm builds fail wi=
th missing __cmpdi2 */
> @@ -966,7 +973,7 @@ struct ctl_table_header *__register_sysctl_table(
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&sysctl_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0header->set =3D lookup_header_set(root, na=
mespaces);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0header->attached_by =3D header->ctl_table;
> - =C2=A0 =C2=A0 =C2=A0 header->attached_to =3D root_table;
> + =C2=A0 =C2=A0 =C2=A0 header->attached_to =3D &root_table[1];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0header->parent =3D &root_table_header;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0set =3D header->set;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0root =3D header->root;
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
