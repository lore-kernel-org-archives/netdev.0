From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Sat, 5 Jul 2014 14:59:07 -0700
Message-ID: <CAMEtUuwjGykxr2rg-pSqmfZwHt4JRceJj96ENX9tjawU=y8QXQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-4-git-send-email-ast@plumgrid.com>
	<CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
	<CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
	<CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
	<CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
	<CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
	<CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
	<CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com>
	<CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ@mail.gmail.com>
	<CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
	<CAMEtUuyX-tybpMEW=f-00qgq9h3AcHovLNW0_bak3oT4Oj3FuA@mail.gmail.com>
	<CALCETrWpA5M74pKJLFJ0t-2hi2TXMi_BV6DbJMmdDOJyOoHOyg@mail.gmail.com>
	<CAMEtUuzHrzyUG1nie5cWzGZYTDTnqL7vPvAmPZdie_uSM_wqRA@mail.gmail.com>
	<CALCETrW5WitpzcFmkGDwR6U=qOwCkOfQMy=XOtQTuHs-942Drw@mail.gmail.com>
	<CAMEtUuzkVANM341xPTKH1bNVNuK6TQcyqsdZdkGWausLT5Qj6A@mail.gmail.com>
	<CALCETrWQnQS=jjuhQzxM9YMhGk-fJ1oNetdPuZ0v4yujBLZ+fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrWQnQS=jjuhQzxM9YMhGk-fJ1oNetdPuZ0v4yujBLZ+fA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 4, 2014 at 8:17 AM, Andy Lutomirski <luto@amacapital.net> w=
rote:
> On Wed, Jul 2, 2014 at 7:29 PM, Alexei Starovoitov <ast@plumgrid.com>=
 wrote:
>>
>> non-root API:
>>
>> ufd =3D bpf_create_map(local_map_id,=E2=80=A6 )
>> bpf_map_update/delete/lookup_elem(ufd,=E2=80=A6)
>> ufd =3D bpf_prog_load(insns)
>> close(ufd)
>>
>> root only API:
>>
>> global_id =3D bpf_get_id(ufd) // returns either map or prog global i=
d
>> bpf_map_delete(global_map_id)
>> bpf_prog_unload(global_prog_id)
>>
>> Details:
>>
>> ufd =3D bpf_create_map(local_map_id, ...);
>>
>> local_map_id - process local map_id
>> (this id is used to access maps from eBPF program loaded by this pro=
cess)
>>
>> ufd - process local file descriptor
>> (used to update/lookup maps from this process)
>>
>> global_map_id =3D bpf_get_id(ufd)
>> this is root only call to get global_ids and pass them to global eve=
nts
>> like tracing.
>>
>> global ids will only be seen by root. There is no way for root or no=
n-root
>> to influence id ranges.
>>
>> I think it will be cleaner once I finish fd conversion as a patch.
>
> OK
>
> FWIW, per-process local id maps sound almost equivalent to relocation=
s
> -- the latter could be as simple as an extra nlattr giving a list of
> pairs of (per-eBPF-program id, fd).

I thought about array of such pairs as well, but it felt cleaner to rem=
ember
the (per-eBPF-program id, fd) pair in a kernel, instead of asking user
space to keep track of them. Either way I think it's minor. I'll implem=
ent
both and see which way is cleaner.

So far I did 3-way enum split in verifier and addressed Namhyung's
and Chema's comments. Updated in the same place:
git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

I'll be traveling next week.
Once I'm done with fd-style interface, I'll post a v2.

Thanks
