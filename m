From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Subject: Re: [PATCH] connector: add an event for monitoring process tracers
Date: Fri, 15 Jul 2011 20:41:59 +0300
Message-ID: <CAMW3pwbr1N6Yc7K=up3mYNq2f6+_6xA4hSgh8K1hWwHPnj_d9g@mail.gmail.com>
References: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
	<20110713150942.GA4850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:50028 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab1GORmA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 13:42:00 -0400
Received: by gwaa18 with SMTP id a18so631610gwa.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 10:41:59 -0700 (PDT)
In-Reply-To: <20110713150942.GA4850@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg,

first of all thank you for a good review, please see my comments below.

On Wed, Jul 13, 2011 at 6:09 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/12, Vladimir Zapolskiy wrote:
>>
>> Note, a detach signal is not emitted, if a tracer process terminates
>> without explicit PTRACE_DETACH request. Such cases can be covered
>> listening to PROC_EVENT_EXIT connector events.
>
> Hmm. More and more reasons to make the implicit detach sleepable...
>
> But. There is another case. The (dead) tracee can be detached via
> do_wait(). Perhaps this falls into "covered listening to EXIT" too,
> but imho makes sense to document in the changelog. Oh, and probably
> we will add the ability to detach a zombie...
>
> I don't really understand why do you need this, but I won't argue.
>
I found that implicit ptrace detach codepath is quite mutable and
vast, and I don't want to interfere in that changes without knowing
even basic pitfalls. Somehow the sending a connector signal on
explicit detach is quite sufficient at least for the most of the proc
connector usecases I can imagine, because hopefully almost(?) all
implicit detach cases are related to tracer or tracee thread
completion, and that is supposed to be reported to userspace via
do_exit()/proc_exit_connector() path.

> As for the patch,
>
>> +void proc_ptrace_connector(struct task_struct *task)
>> +{
>> + =C2=A0 =C2=A0 struct cn_msg *msg;
>> + =C2=A0 =C2=A0 struct proc_event *ev;
>> + =C2=A0 =C2=A0 struct timespec ts;
>> + =C2=A0 =C2=A0 __u8 buffer[CN_PROC_MSG_SIZE];
>> + =C2=A0 =C2=A0 struct task_struct *tracer;
>> +
>> + =C2=A0 =C2=A0 if (atomic_read(&proc_event_num_listeners) < 1)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 msg =3D (struct cn_msg *)buffer;
>> + =C2=A0 =C2=A0 ev =3D (struct proc_event *)msg->data;
>> + =C2=A0 =C2=A0 get_seq(&msg->seq, &ev->cpu);
>> + =C2=A0 =C2=A0 ktime_get_ts(&ts); /* get high res monotonic timesta=
mp */
>> + =C2=A0 =C2=A0 put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->tim=
estamp_ns);
>> + =C2=A0 =C2=A0 ev->what =3D PROC_EVENT_PTRACE;
>> + =C2=A0 =C2=A0 ev->event_data.ptrace.process_pid =C2=A0=3D task->pi=
d;
>> + =C2=A0 =C2=A0 ev->event_data.ptrace.process_tgid =3D task->tgid;
>> +
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 tracer =3D tracehook_tracer_task(task);
>> + =C2=A0 =C2=A0 if (tracer) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ev->event_data.ptrace.tr=
acer_pid =C2=A0=3D tracer->pid;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ev->event_data.ptrace.tr=
acer_tgid =3D tracer->tgid;
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ev->event_data.ptrace.tr=
acer_pid =C2=A0=3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ev->event_data.ptrace.tr=
acer_tgid =3D 0;
>> + =C2=A0 =C2=A0 }
>
> This doesn't look right. The code uses tracehook_tracer_task() to
> figure out whether this task traced or not. But this is racy.
>
> ptrace_attach:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...attach...
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* WINDOW */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0proc_ptrace_connector(task);
>
> The task can exit in between, and the caller's subthread can do
> wait4() and release it. In this case proc_ptrace_connector() will
> see tracehook_tracer_task() =3D=3D NULL and report "detach".
>
> The similar race in ptrace_detach() path. Another tracer can attach
> to this task before we proc_ptrace_connector().
>
> I think proc_ptrace_connector() needs the explicit "task_struct *trac=
er"
> argument, NULL if ptrace_detach(). Or a simple boolean, the tracer is
> current.
>
> If you think this is fine - I won't argue.
>
=46ixed in the second version of the change, thanks.

>
>
> But in any case, please rediff against
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git://git.kernel.org/pub/scm/linux/kernel/=
git/oleg/misc.git ptrace
>
> tracehook_tracer_task() was removed, and
>
>> @@ -260,6 +261,9 @@ out:
>> =C2=A0 =C2=A0 =C2=A0 if (wait_trap)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wait_event(current-=
>signal->wait_chldexit,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0!(task->group_stop & GROUP_STOP_TRAPPING));
>> + =C2=A0 =C2=A0 if (!retval)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 proc_ptrace_connector(ta=
sk);
>> +
>> =C2=A0 =C2=A0 =C2=A0 return retval;
>> =C2=A0}
>
> this chunk probably should be updated.
Rebased, thanks a lot.

Vladimir
