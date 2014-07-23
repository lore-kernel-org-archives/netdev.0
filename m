From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 05/16] bpf: introduce syscall(BPF, ...)
 and BPF maps
Date: Wed, 23 Jul 2014 12:30:24 -0700
Message-ID: <CAMEtUuwZW5bzreAG5_u1xopXwP7f59HHFk4eJttj11DuZwTBEA@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-6-git-send-email-ast@plumgrid.com>
	<CAGXu5jJAOyA=UB-k4fmu84RTB_ygHAs2UqtbBfUPs2JCaxo0Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
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
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:41508 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932825AbaGWTa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 15:30:27 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so1706884wgg.24
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 12:30:26 -0700 (PDT)
In-Reply-To: <CAGXu5jJAOyA=UB-k4fmu84RTB_ygHAs2UqtbBfUPs2JCaxo0Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 11:02 AM, Kees Cook <keescook@chromium.org> wrote:
>> --- a/Documentation/networking/filter.txt
>> +++ b/Documentation/networking/filter.txt
>>
>> +eBPF maps
>> +---------
>> +'maps' is a generic storage of different types for sharing data between kernel
>> +and userspace.
>> +
>> +The maps are accessed from user space via BPF syscall, which has commands:
>> +- create a map with given id, type and attributes
>> +  map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
>> +  returns positive map id or negative error
>
> Looks like these docs need updating for the fd-based approach instead
> of the map_id approach?

ohh, yes. updated it in srcs and in commit log, but forgot in docs.

>> +SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
>> +               unsigned long, arg4, unsigned long, arg5)
>> +{
>> +       if (!capable(CAP_SYS_ADMIN))
>> +               return -EPERM;
>
> It might be valuable to have a comment here describing why this is
> currently limited to CAP_SYS_ADMIN.

makes sense.
There are several reasons it should be limited to root initially:
- to phase changes in gradually
- verifier is not detecting pointer leaks yet
- full security audit wasn't performed
- tracing and network analytics are root only anyway
Currently eBPF is safe (non-crashing), since safety is relatively easy
to enforce by static analysis. For somebody with compiler background
it's natural to think about bounds, alignments, uninitialized access, etc.
So I'm confident that I didn't miss anything big in 'safety' aspect.
'Non-root security' is harder. I'll add pointer leak detection first
and will ask for more suggestions.

>> +       switch (cmd) {
>> +       case BPF_MAP_CREATE:
>> +               return map_create((enum bpf_map_type) arg2,
>> +                                 (struct nlattr __user *) arg3, (int) arg4);
>
> I'd recommend requiring arg5 == 0 here, just for future flexibility.

Though I expect all extensions to go through nlattr attributes,
it's indeed cleaner to enforce arg5==0 here and for all other cmds.
