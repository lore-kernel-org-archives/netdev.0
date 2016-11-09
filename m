From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Tue, 8 Nov 2016 16:12:28 -0800
Message-ID: <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
References: <1478647728-30357-1-git-send-email-john.stultz@linaro.org>
 <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com> <20161109000342.GA42532@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
        John Stultz <john.stultz@linaro.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S. Miller" <davem@davemloft.net>, kafai@fb.com,
        fw@strlen.de, Harald Hoyer <harald@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        lkml <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Li Zefan <lizefan@huawei.com>,
        Jonathan Corbet <corbet@lwn.net>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        Android Kernel Team <kernel-team@android.com>,
        Rom Lemarchand <romlem@android.com>,
        Colin Cross <ccross@android.com>,
        Dmitry Shmidt <dimitrysh@google.com>,
        Todd Kjos <tkjos@google.co
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109000342.GA42532@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 8, 2016 at 4:03 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Nov 08, 2016 at 03:51:40PM -0800, Andy Lutomirski wrote:
>> On Tue, Nov 8, 2016 at 3:28 PM, John Stultz <john.stultz@linaro.org> wrote:
>> > This patch adds logic to allows a process to migrate other tasks
>> > between cgroups if they have CAP_SYS_RESOURCE.
>> >
>> > In Android (where this feature originated), the ActivityManager tracks
>> > various application states (TOP_APP, FOREGROUND, BACKGROUND, SYSTEM,
>> > etc), and then as applications change states, the SchedPolicy logic
>> > will migrate the application tasks between different cgroups used
>> > to control the different application states (for example, there is a
>> > background cpuset cgroup which can limit background tasks to stay
>> > on one low-power cpu, and the bg_non_interactive cpuctrl cgroup can
>> > then further limit those background tasks to a small percentage of
>> > that one cpu's cpu time).
>> >
>> > However, for security reasons, Android doesn't want to make the
>> > system_server (the process that runs the ActivityManager and
>> > SchedPolicy logic), run as root. So in the Android common.git
>> > kernel, they have some logic to allow cgroups to loosen their
>> > permissions so CAP_SYS_NICE tasks can migrate other tasks between
>> > cgroups.
>> >
>> > I feel the approach taken there overloads CAP_SYS_NICE a bit much
>> > for non-android environments.
>> >
>> > So this patch, as suggested by Michael Kerrisk, simply adds a
>> > check for CAP_SYS_RESOURCE.
>> >
>> > I've tested this with AOSP master, and this seems to work well
>> > as Zygote and system_server already use CAP_SYS_RESOURCE. I've
>> > also submitted patches against the android-4.4 kernel to change
>> > it to use CAP_SYS_RESOURCE, and the Android developers just merged
>> > it.
>> >
>>
>> I hate to say it, but I think I may see a problem.  Current
>> developments are afoot to make cgroups do more than resource control.
>> For example, there's Landlock and there's Daniel's ingress/egress
>> filter thing.  Current cgroup controllers can mostly just DoS their
>> controlled processes.  These new controllers (or controller-like
>> things) can exfiltrate data and change semantics.
>>
>> Does anyone have a security model in mind for these controllers and
>> the cgroups that they're attached to?  I'm reasonably confident that
>> CAP_SYS_RESOURCE is not the answer...
>
> and specifically the answer is... ?
> Also would be great if you start with specifying the question first
> and the problem you're trying to solve.
>

I don't have a good answer right now.  Here are some constraints, though:

1. An insufficiently privileged process should not be able to move a
victim into a dangerous cgroup.

2. An insufficiently privileged process should not be able to move
itself into a dangerous cgroup and then use execve to gain privilege
such that the execve'd program can be compromised.

3. An insufficiently privileged process should not be able to make an
existing cgroup dangerous in a way that could compromise a victim in
that cgroup.

4. An insufficiently privileged process should not be able to make a
cgroup dangerous in a way that bypasses protections that would
otherwise protect execve() as used by itself or some other process in
that cgroup.

Keep in mind that "dangerous" may apply to a cgroup's descendents in
addition to the cgroup being controlled.
