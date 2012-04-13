From: Andrew Lutomirski <luto-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH v18 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Thu, 12 Apr 2012 21:25:27 -0700
Message-ID: <CAObL_7ER32AesD6bHk591ss0hTFmp0bjVOKV9oEdhiFwCEVOBA@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org> <alpine.LRH.2.02.1204131414580.22039@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, mcgrathr-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, djm-ilwOsaqNJrtAfugRpC6u6w@public.gmane.org,
	scarybeasts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indan-1J6HnF7K7zE@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	markus-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, coreyb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
To: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LRH.2.02.1204131414580.22039-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 9:16 PM, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org> wrote=
:
> On Thu, 12 Apr 2012, Will Drewry wrote:
>> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
>> index d85b793..0b06685 100644
>> --- a/security/selinux/hooks.c
>> +++ b/security/selinux/hooks.c
>> @@ -2016,6 +2016,13 @@ static int selinux_bprm_set_creds(struct linu=
x_binprm *bprm)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_tsec->sid =3D old_tsec->exec_sid;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Reset exec SID on execve. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_tsec->exec_sid =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Minimize confusion: if no_new_privs a=
nd a transition is
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* explicitly requested, then fail the e=
xec.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Check for a default transition on thi=
s program. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D security_transition_sid(old_tsec-=
>sid, isec->sid,
>> @@ -2029,7 +2036,8 @@ static int selinux_bprm_set_creds(struct linux=
_binprm *bprm)
>> =A0 =A0 =A0 ad.selinux_audit_data =3D &sad;
>> =A0 =A0 =A0 ad.u.path =3D bprm->file->f_path;
>>
>> - =A0 =A0 if (bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)
>> + =A0 =A0 if ((bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) ||
>> + =A0 =A0 =A0 =A0 (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_tsec->sid =3D old_tsec->sid;
>>
>> =A0 =A0 =A0 if (new_tsec->sid =3D=3D old_tsec->sid) {
>> --
>
> What about dynamic transitions in SELinux ?
>

What's a dynamic transition?

--Andy
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
