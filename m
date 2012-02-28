From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Tue, 28 Feb 2012 11:18:26 -0600
Message-ID: <CABqD9hYt5WUjB+72F+2Pr7XuOtk0J=4E8Eoghmyw9hgFQj02gQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<20120227170922.GA10608@redhat.com>
	<CABqD9hbtFDU_vgBOajG2jJxQoHubcwYWJuHPLjgZkZyjGkQ2uQ@mail.gmail.com>
	<20120228151333.GA3664@redhat.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <kernel-hardening-return-998-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20120228151333.GA3664@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 9:13 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 02/27, Will Drewry wrote:
>>
>> On Mon, Feb 27, 2012 at 11:09 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>
>> >> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>> >> +{
>> >> + =A0 =A0 struct seccomp_filter *filter;
>> >> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_f=
ilter);
>> >> + =A0 =A0 long ret;
>> >> +
>> >> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> >
>> > OK, this limits the memory PR_SET_SECCOMP can use.
>> >
>> > But,
>> >
>> >> + =A0 =A0 /*
>> >> + =A0 =A0 =A0* If there is an existing filter, make it the prev and d=
on't drop its
>> >> + =A0 =A0 =A0* task reference.
>> >> + =A0 =A0 =A0*/
>> >> + =A0 =A0 filter->prev =3D current->seccomp.filter;
>> >> + =A0 =A0 current->seccomp.filter =3D filter;
>> >> + =A0 =A0 return 0;
>> >
>> > this doesn't limit the number of filters, looks like a DoS.
>> >
>> > What if the application simply does prctl(PR_SET_SECCOMP, dummy_filter=
)
>> > in an endless loop?
>>
>> It consumes a massive amount of kernel memory and, maybe, the OOM
>> killer gives it a boot :)
>
> may be ;) but most probably oom-killer kills another innocent task,
> this memory is not accounted.
>
>> I wasn't sure what the normal convention was for avoiding memory
>> consumption by user processes. Should I just add a sysctl
>
> Perhaps we can add a sysctl later, but personally I think that we
> can start with some "arbitrary" #define BPF_MAXFILTERS.

Sounds good - I'll wire something like this up in the next round.

>> and a
>> per-task counter for the max number of filters?
>
> Do we really need the counter? attach_filter is not the fast path,
> perhaps seccomp_attach_filter() could simply iterate the chain and
> count the number?
>
> In any case, if this hurts perfomance-wise then seccomp_run_filters()
> has even more problems.
>
>> I'm fine doing whatever makes sense here.
>
> I am fine either way too.
>
> Oleg.
>
