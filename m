From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v6 02/11] bpf,landlock: Define an eBPF program
 type for Landlock
Date: Tue, 18 Apr 2017 14:58:35 -0700
Message-ID: <CAGXu5jJQaxTOGgKCcApOiAX+ZnSgGQG6nU30hD0WeyQRcZ=zDg@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328234650.19695-3-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> Add a new type of eBPF program used by Landlock rules.
>
> This new BPF program type will be registered with the Landlock LSM
> initialization.
>
> Add an initial Landlock Kconfig.
>
> Changes since v5:
> * rename file hooks.c to init.c
> * fix spelling
>
> Changes since v4:
> * merge a minimal (not enabled) LSM code and Kconfig in this commit
>
> Changes since v3:
> * split commit
> * revamp the landlock_context:
>   * add arch, syscall_nr and syscall_cmd (ioctl, fcntl=E2=80=A6) to be ab=
le to
>     cross-check action with the event type
>   * replace args array with dedicated fields to ease the addition of new
>     fields
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> ---
> [...]
> +static inline bool bpf_landlock_is_valid_subtype(
> +               union bpf_prog_subtype *prog_subtype)
> +{
> +       if (WARN_ON(!prog_subtype))
> +               return false;
> +
> +       switch (prog_subtype->landlock_rule.event) {
> +       case LANDLOCK_SUBTYPE_EVENT_FS:
> +               break;
> +       case LANDLOCK_SUBTYPE_EVENT_UNSPEC:
> +       default:
> +               return false;
> +       }
> +
> +       if (!prog_subtype->landlock_rule.version ||
> +                       prog_subtype->landlock_rule.version > LANDLOCK_VE=
RSION)
> +               return false;
> +       if (!prog_subtype->landlock_rule.event ||
> +                       prog_subtype->landlock_rule.event > _LANDLOCK_SUB=
TYPE_EVENT_LAST)
> +               return false;
> +       if (prog_subtype->landlock_rule.ability & ~_LANDLOCK_SUBTYPE_ABIL=
ITY_MASK)
> +               return false;
> +       if (prog_subtype->landlock_rule.option & ~_LANDLOCK_SUBTYPE_OPTIO=
N_MASK)
> +               return false;
> +
> +       /* check ability flags */
> +       if (prog_subtype->landlock_rule.ability & LANDLOCK_SUBTYPE_ABILIT=
Y_WRITE &&
> +                       !capable(CAP_SYS_ADMIN))
> +               return false;
> +       if (prog_subtype->landlock_rule.ability & LANDLOCK_SUBTYPE_ABILIT=
Y_DEBUG &&
> +                       !capable(CAP_SYS_ADMIN))
> +               return false;
> +
> +       return true;
> +}

I would add more comments for the rule and ability tests just to help
people read this.

> +
> +static inline const struct bpf_func_proto *bpf_landlock_func_proto(
> +               enum bpf_func_id func_id, union bpf_prog_subtype *prog_su=
btype)
> +{
> +       bool event_fs =3D (prog_subtype->landlock_rule.event =3D=3D
> +                       LANDLOCK_SUBTYPE_EVENT_FS);
> +       bool ability_write =3D !!(prog_subtype->landlock_rule.ability &
> +                       LANDLOCK_SUBTYPE_ABILITY_WRITE);
> +       bool ability_debug =3D !!(prog_subtype->landlock_rule.ability &
> +                       LANDLOCK_SUBTYPE_ABILITY_DEBUG);
> +
> +       switch (func_id) {
> +       case BPF_FUNC_map_lookup_elem:
> +               return &bpf_map_lookup_elem_proto;
> +
> +       /* ability_write */
> +       case BPF_FUNC_map_delete_elem:
> +               if (ability_write)
> +                       return &bpf_map_delete_elem_proto;
> +               return NULL;
> +       case BPF_FUNC_map_update_elem:
> +               if (ability_write)
> +                       return &bpf_map_update_elem_proto;
> +               return NULL;
> +
> +       /* ability_debug */
> +       case BPF_FUNC_get_current_comm:
> +               if (ability_debug)
> +                       return &bpf_get_current_comm_proto;
> +               return NULL;
> +       case BPF_FUNC_get_current_pid_tgid:
> +               if (ability_debug)
> +                       return &bpf_get_current_pid_tgid_proto;
> +               return NULL;
> +       case BPF_FUNC_get_current_uid_gid:
> +               if (ability_debug)
> +                       return &bpf_get_current_uid_gid_proto;
> +               return NULL;
> +       case BPF_FUNC_trace_printk:
> +               if (ability_debug)
> +                       return bpf_get_trace_printk_proto();
> +               return NULL;
> +
> +       default:
> +               return NULL;
> +       }
> +}

I find this switch statement mixed with the "if (ability...)" kind of
hard to read and a bit fragile. I think it'd be better written as:

switch (func_id) {
case BPF_FUNC_map_lookup_elem:
   return ...
}

if (ability_write) {
    switch (func_id) {
        ...
    }
}

if (ability_debug) {
    switch (func_id) {
        ...
    }
}

return NULL;

Then it's self-documenting and it's harder to add a case without the
desired ability check...

> +static const struct bpf_verifier_ops bpf_landlock_ops =3D {
> +       .get_func_proto =3D bpf_landlock_func_proto,
> +       .is_valid_access =3D bpf_landlock_is_valid_access,
> +       .is_valid_subtype =3D bpf_landlock_is_valid_subtype,
> +};
> +
> +static struct bpf_prog_type_list bpf_landlock_type __ro_after_init =3D {
> +       .ops =3D &bpf_landlock_ops,
> +       .type =3D BPF_PROG_TYPE_LANDLOCK,
> +};

Yay const and ro_after_init! :)

-Kees

--=20
Kees Cook
Pixel Security
