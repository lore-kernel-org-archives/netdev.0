From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 12:49:10 -0800
Message-ID: <CAGXu5jKvoxVLmLqV0DK9+hB38kPh0xTTHF=_sheRWvDoWusUyw@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<20120226202828.GE3990@outflux.net>
	<CABqD9hbKU=EVagCfo25AZsNoq=hmzkeOxK6mE=q8m=Be-ZFb9w@mail.gmail.com>
	<1330361396.2542.11.camel@localhost>
	<CAGXu5jKJ7pYeULM=CvifpQ8jUoyH6Ska2Znx9tGjhz0tn5kZmQ@mail.gmail.com>
	<1330370733.2542.18.camel@localhost>
	<CAGXu5jKyLHLF+HuU=SLHJLg8AaOPJXoqq1=hOBy5oOvffA-xiQ@mail.gmail.com>
	<1330374879.2542.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, Kees Cook <kees@ubuntu.com>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1330374879.2542.24.camel@localhost>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 12:34 PM, Eric Paris <eparis@redhat.com> wrote:
> On Mon, 2012-02-27 at 12:00 -0800, Kees Cook wrote:
>> On Mon, Feb 27, 2012 at 11:25 AM, Eric Paris <eparis@redhat.com> wro=
te:
>> > On Mon, 2012-02-27 at 10:55 -0800, Kees Cook wrote:
>> >> On Mon, Feb 27, 2012 at 8:49 AM, Eric Paris <eparis@redhat.com> w=
rote:
>> >
>> >> You mean as used in audit_log_exit() ? It looks like that depends=
 on a
>> >> lot of state cached in __audit_syscall_entry() and finally trigge=
red
>> >> in __audit_syscall_exit() (and ..._free()). I don't think this is
>> >> really want seccomp wants to be involved in.
>> >>
>> >> By CONFIG_AUDITSC, you mean CONFIG_AUDITSYSCALL? Without that set=
,
>> >> audit_seccomp is a no-op.
>> >>
>> >> The reason compat needs to be reported (or rather, arch) is becau=
se
>> >> just reporting syscall is ambiguous. It either needs arch or comp=
at to
>> >> distinguish it.
>> >
>> > Yes, that is what I mean and you are right. =A0You shouldn't push =
the
>> > syscall in this record either. =A0If !audit_dummy_context() you ar=
e
>> > already going to get arch, syscall, and a0-a4 in the associated au=
dit
>> > record. =A0Please do not duplicate that info.
>>
>> Ah, in that case, please ignore the patch I just sent. Heh.
>>
>> > It might make sense to have a separate audit_seccomp() path when
>> > audit_dummy_context() which includes arch, syscall, and a0-a4.
>>
>> Ah! I think I understand what you mean now. If audit_dummy_context()=
,
>> then the syscall, arch, and a0-a4 were not already collected. Gotcha=
=2E
>>
>> How do you envision it looking? I still see it as two distinct event=
s
>> (the syscall itself, and the rejection). Would you want those detail=
s
>> added to the context structure to be reported at ..._exit() time? It
>> seems like context->type couldn't be used to see if those fields wer=
e
>> valid.
>>
>> Something like:
>>
>> void __audit_seccomp(unsigned long syscall, long signr)
>> {
>> =A0 =A0 =A0 =A0 struct audit_buffer *ab;
>>
>> =A0 =A0 =A0 =A0 if (!audit_dummy_context()) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct audit_context *context =3D cu=
rrent->audit_context;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 context->syscall_signr =3D signr;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 context->syscall_ip =3D KSTK_EIP(cur=
rent);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 ab =3D audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_=
ABEND);
>> =A0 =A0 =A0 =A0 audit_log_abend(ab, "seccomp", signr);
>> =A0 =A0 =A0 =A0 audit_log_format(ab, " syscall=3D%ld", syscall);
>> =A0 =A0 =A0 =A0 audit_log_format(ab, " ip=3D0x%lx", KSTK_EIP(current=
));
>> =A0 =A0 =A0 =A0 audit_log_end(ab);
>> }
>>
>> And then report syscall_ip and syscall_signr if syscall_signr !=3D 0=
 in
>> the _exit()? I think everything else from audit_log_abend() will end
>> up in the _exit() report.
>>
>> > It is my fault (85e7bac3) that we have syscall at all, but I'm on =
a new
>> > crusade to remove audit record duplication. =A0So I'd happily see =
a patch
>> > in this series that removes that instead of adds to it.
>>
>> Well, I think the abend reporting is nice; I'd hate to see that
>> totally removed. The seccomp case is a bit different, I agree. I cou=
ld
>> see it either way.
>
> Once again I send you down a bad path. =A0Your original patch was the
> best. =A0We should consider including a0-aX in a future version. =A0I=
 was
> mistaken in foolishly believing that audit_syscall_entry() was done
> before secure_computing(). =A0But if you look, that isn't the case.
> Please pretend I never said anything as you had it right the first ti=
me.

Heh, okay. But now I know more about audit, so that's good. :)

-Kees

--=20
Kees Cook
ChromeOS Security
