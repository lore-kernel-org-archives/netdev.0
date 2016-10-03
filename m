From: Kees Cook <keescook@chromium.org>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Mon, 3 Oct 2016 16:30:21 -0700
Message-ID: <CAGXu5jLnVyeAMPWwP=ovZuE+vmmqxSd4WyZ6O1inA1ie107k8Q@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-8-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20160914072415.26021-8-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net=
> wrote:
> Add eBPF functions to compare file system access with a Landlock file
> system handle:
> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>   This function allows to compare the dentry, inode, device or mount
>   point of the currently accessed file, with a reference handle.
> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)
>   This function allows an eBPF program to check if the current accessed
>   file is the same or in the hierarchy of a reference handle.
>
> The goal of file system handle is to abstract kernel objects such as a
> struct file or a struct inode. Userland can create this kind of handle
> thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
> landlock_handle containing the handle type (e.g.
> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
> also be any descriptions able to match a struct file or a struct inode
> (e.g. path or glob string).
>
> Changes since v2:
> * add MNT_INTERNAL check to only add file handle from user-visible FS
>   (e.g. no anonymous inode)
> * replace struct file* with struct path* in map_landlock_handle
> * add BPF protos
> * fix bpf_landlock_cmp_fs_prop_with_struct_file()
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>
> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD=
2G5o71yD7g@mail.gmail.com
> ---
>  include/linux/bpf.h            |  10 +++
>  include/uapi/linux/bpf.h       |  49 +++++++++++
>  kernel/bpf/arraymap.c          |  21 +++++
>  kernel/bpf/verifier.c          |   8 ++
>  security/landlock/Makefile     |   2 +-
>  security/landlock/checker_fs.c | 179 +++++++++++++++++++++++++++++++++++=
++++++
>  security/landlock/checker_fs.h |  20 +++++
>  security/landlock/lsm.c        |   6 ++
>  8 files changed, 294 insertions(+), 1 deletion(-)
>  create mode 100644 security/landlock/checker_fs.c
>  create mode 100644 security/landlock/checker_fs.h
> [...]
> diff --git a/security/landlock/checker_fs.c b/security/landlock/checker_f=
s.c
> new file mode 100644
> index 000000000000..39eb85dc7d18
> --- /dev/null
> +++ b/security/landlock/checker_fs.c
> @@ -0,0 +1,179 @@
> +/*
> + * Landlock LSM - File System Checkers
> + *
> + * Copyright (C) 2016  Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/bpf.h> /* enum bpf_map_array_op */
> +#include <linux/errno.h>
> +#include <linux/fs.h> /* path_is_under() */
> +#include <linux/path.h> /* struct path */
> +
> +#include "checker_fs.h"
> +
> +#define EQUAL_NOT_NULL(a, b) (a && a =3D=3D b)
> +
> +/*
> + * bpf_landlock_cmp_fs_prop_with_struct_file
> + *
> + * Cf. include/uapi/linux/bpf.h
> + */
> +static inline u64 bpf_landlock_cmp_fs_prop_with_struct_file(u64 r1_prope=
rty,
> +               u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
> +{
> +       u8 property =3D (u8) r1_property;
> +       struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map=
;
> +       enum bpf_map_array_op map_op =3D r3_map_op;
> +       struct file *file =3D (struct file *) (unsigned long) r4_file;
> +       struct bpf_array *array =3D container_of(map, struct bpf_array, m=
ap);
> +       struct path *p1, *p2;
> +       struct map_landlock_handle *handle;
> +       int i;
> +
> +       /* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS is an arraymap */
> +       if (unlikely(!map)) {
> +               WARN_ON(1);
> +               return -EFAULT;
> +       }

Just some minor style/readability nits...

This is more readable as:

if (WARN_ON(!map))
    return -EFAULT;

(WARN_ON already includes the unlikely() and passes through the test result=
.)

> +       if (unlikely(!file))
> +               return -ENOENT;
> +       if (unlikely((property | _LANDLOCK_FLAG_FS_MASK) !=3D _LANDLOCK_F=
LAG_FS_MASK))
> +               return -EINVAL;
> +
> +       /* for now, only handle OP_OR */
> +       switch (map_op) {
> +       case BPF_MAP_ARRAY_OP_OR:
> +               break;
> +       case BPF_MAP_ARRAY_OP_UNSPEC:
> +       case BPF_MAP_ARRAY_OP_AND:
> +       case BPF_MAP_ARRAY_OP_XOR:
> +       default:
> +               return -EINVAL;
> +       }
> +       p2 =3D &file->f_path;
> +
> +       synchronize_rcu();
> +
> +       for (i =3D 0; i < array->n_entries; i++) {
> +               bool result_dentry =3D !(property & LANDLOCK_FLAG_FS_DENT=
RY);
> +               bool result_inode =3D !(property & LANDLOCK_FLAG_FS_INODE=
);
> +               bool result_device =3D !(property & LANDLOCK_FLAG_FS_DEVI=
CE);
> +               bool result_mount =3D !(property & LANDLOCK_FLAG_FS_MOUNT=
);
> +
> +               handle =3D (struct map_landlock_handle *)
> +                               (array->value + array->elem_size * i);
> +
> +               if (handle->type !=3D BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD)=
 {
> +                       WARN_ON(1);
> +                       return -EFAULT;
> +               }

Same here... and in the other function (much of which seems to repeat
-- can some of these checks be put into common functions?)

-Kees

--=20
Kees Cook
Nexus Security
