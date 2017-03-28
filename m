From: Alban Crequy <alban@kinvolk.io>
Subject: Re: [PATCH v1] tracing/kprobes: expose maxactive for kretprobe in kprobe_events
Date: Tue, 28 Mar 2017 18:08:16 +0200
Message-ID: <CADZs7q44Wzn1qQB__gNXWeG=Du3v-tQ4nb+EiTKEANb3CA4GvA@mail.gmail.com>
References: <1490709142-8856-1-git-send-email-alban@kinvolk.io> <20170329002335.1d1fcc491765b632f470f99b@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        =?UTF-8?Q?Iago_L=C3=B3pez_Galeiras?= <iago@kinvolk.io>,
        Michael Schubert <michael@kinvolk.io>,
        "Dorau, Lukasz" <lukasz.dorau@intel.com>
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f170.google.com ([74.125.82.170]:34223 "EHLO
        mail-ot0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdC1QI3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 12:08:29 -0400
Received: by mail-ot0-f170.google.com with SMTP id a5so55139729oth.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 09:08:23 -0700 (PDT)
In-Reply-To: <20170329002335.1d1fcc491765b632f470f99b@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review,

On Tue, Mar 28, 2017 at 5:23 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
> On Tue, 28 Mar 2017 15:52:22 +0200
> Alban Crequy <alban.crequy@gmail.com> wrote:
>
>> When a kretprobe is installed on a kernel function, there is a maximum
>> limit of how many calls in parallel it can catch (aka "maxactive"). A
>> kernel module could call register_kretprobe() and initialize maxactive
>> (see example in samples/kprobes/kretprobe_example.c).
>>
>> But that is not exposed to userspace and it is currently not possible to
>> choose maxactive when writing to /sys/kernel/debug/tracing/kprobe_events
>
> I see, I found same issue last week...
>
>>
>> The default maxactive can be as low as 1 on single-core with a
>> non-preemptive kernel. This is too low and we need to increase it not
>> only for recursive functions, but for functions that sleep or resched.
>>
>> This patch updates the format of the command that can be written to
>> kprobe_events so that maxactive can be optionally specified.
>
> Good! this is completely same what I'm planning to add.
>
>>
>> I need this for a bpf program attached to the kretprobe of
>> inet_csk_accept, which can sleep for a long time.
>
> I'm also preparing another patch for using kmalloc(GFP_ATOMIC) in
> kretprobe_pre_handler(), since this manual way is sometimes hard to
> estimate how many instances needed. Anyway, since that may involve
> unwilling memory allocation, this patch also needed.

Where is that kretprobe_pre_handler()? I don't see any allocations in
pre_handler_kretprobe().

>> BugLink: https://github.com/iovisor/bcc/issues/1072
>
> Could you also add Lukasz to Cc list, since he had reported an issue
> related this one.
>
> https://www.spinics.net/lists/linux-trace/msg00448.html
>
> Please see my comments below.
>
>> Signed-off-by: Alban Crequy <alban@kinvolk.io>
>> ---
>>  Documentation/trace/kprobetrace.txt |  4 +++-
>>  kernel/trace/trace_kprobe.c         | 34 +++++++++++++++++++++++++++++-----
>>  2 files changed, 32 insertions(+), 6 deletions(-)
>>
>> diff --git a/Documentation/trace/kprobetrace.txt b/Documentation/trace/kprobetrace.txt
>> index 41ef9d8..655ca7e 100644
>> --- a/Documentation/trace/kprobetrace.txt
>> +++ b/Documentation/trace/kprobetrace.txt
>> @@ -23,7 +23,7 @@ current_tracer. Instead of that, add probe points via
>>  Synopsis of kprobe_events
>>  -------------------------
>>    p[:[GRP/]EVENT] [MOD:]SYM[+offs]|MEMADDR [FETCHARGS]       : Set a probe
>> -  r[:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]          : Set a return probe
>> +  r[MAXACTIVE][:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]       : Set a return probe
>>    -:[GRP/]EVENT                                              : Clear a probe
>>
>>   GRP         : Group name. If omitted, use "kprobes" for it.
>> @@ -32,6 +32,8 @@ Synopsis of kprobe_events
>>   MOD         : Module name which has given SYM.
>>   SYM[+offs]  : Symbol+offset where the probe is inserted.
>>   MEMADDR     : Address where the probe is inserted.
>> + MAXACTIVE   : Maximum number of instances of the specified function that
>> +               can be probed simultaneously, or 0 for the default.(*)
>
> Here, yoy don't need (*), since [MAXACTIVE] is not a FETCHARGS.

Why not? (*) refers to "(*) only for return probe." and the maxactive
only makes sense for the kretprobe.

>>   FETCHARGS   : Arguments. Each probe can have up to 128 args.
>>    %REG               : Fetch register REG
>> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
>> index 5f688cc..807e01c 100644
>> --- a/kernel/trace/trace_kprobe.c
>> +++ b/kernel/trace/trace_kprobe.c
>> @@ -282,6 +282,7 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
>>                                            void *addr,
>>                                            const char *symbol,
>>                                            unsigned long offs,
>> +                                          int maxactive,
>>                                            int nargs, bool is_return)
>>  {
>>       struct trace_kprobe *tk;
>> @@ -309,6 +310,8 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
>>       else
>>               tk->rp.kp.pre_handler = kprobe_dispatcher;
>>
>> +     tk->rp.maxactive = maxactive;
>> +
>>       if (!event || !is_good_name(event)) {
>>               ret = -EINVAL;
>>               goto error;
>> @@ -598,8 +601,10 @@ static int create_trace_kprobe(int argc, char **argv)
>>  {
>>       /*
>>        * Argument syntax:
>> -      *  - Add kprobe: p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
>> -      *  - Add kretprobe: r[:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
>> +      *  - Add kprobe:
>> +      *      p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
>> +      *  - Add kretprobe:
>> +      *      r[MAXACTIVE][:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
>>        * Fetch args:
>>        *  $retval     : fetch return value
>>        *  $stack      : fetch stack address
>> @@ -619,6 +624,7 @@ static int create_trace_kprobe(int argc, char **argv)
>>       int i, ret = 0;
>>       bool is_return = false, is_delete = false;
>>       char *symbol = NULL, *event = NULL, *group = NULL;
>> +     int maxactive = 0;
>>       char *arg;
>>       unsigned long offset = 0;
>>       void *addr = NULL;
>> @@ -637,8 +643,26 @@ static int create_trace_kprobe(int argc, char **argv)
>>               return -EINVAL;
>>       }
>>
>> -     if (argv[0][1] == ':') {
>> +     if (is_return && isdigit(argv[0][1]) && strchr(&argv[0][1], ':')) {
>
> This only supports r[MAXACTIVE:[GRP/]EVENT]. e.g "r100" without event name.
>
> Thank you,

Ok, I will fix this.

By the way, the current code does not error out when there are extra characters:
"pfuzz inet_csk_accept" is currently a valid command.
I didn't change that.

>> +             event = strchr(&argv[0][1], ':') + 1;
>> +             event[-1] = '\0';
>> +             ret = kstrtouint(&argv[0][1], 0, &maxactive);
>> +             if (ret) {
>> +                     pr_info("Failed to parse maxactive.\n");
>> +                     return ret;
>> +             }
>> +             /* kretprobes instances are iterated over via a list. The
>> +              * maximum should stay reasonable.
>> +              */
>> +             if (maxactive > 1024) {
>> +                     pr_info("Maxactive is too big.\n");
>> +                     return -EINVAL;
>> +             }
>> +     } else if (argv[0][1] == ':') {
>>               event = &argv[0][2];
>> +     }
>> +
>> +     if (event) {
>>               if (strchr(event, '/')) {
>>                       group = event;
>>                       event = strchr(group, '/') + 1;
>> @@ -718,8 +742,8 @@ static int create_trace_kprobe(int argc, char **argv)
>>                                is_return ? 'r' : 'p', addr);
>>               event = buf;
>>       }
>> -     tk = alloc_trace_kprobe(group, event, addr, symbol, offset, argc,
>> -                            is_return);
>> +     tk = alloc_trace_kprobe(group, event, addr, symbol, offset, maxactive,
>> +                            argc, is_return);
>>       if (IS_ERR(tk)) {
>>               pr_info("Failed to allocate trace_probe.(%d)\n",
>>                       (int)PTR_ERR(tk));
>> --
>> 2.7.4
>>
>
>
> --
> Masami Hiramatsu <mhiramat@kernel.org>
