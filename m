From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Fri, 03 Feb 2017 23:30:36 +1300
Message-ID: <87y3xnd0s3.fsf@xmission.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
        <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
        <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
        <588A35F8.6050909@fb.com>
        <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
        <588A40D7.9070603@fb.com>
        <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
        <588A4D3C.9070601@fb.com> <87r33fevva.fsf@xmission.com>
        <20170203060554.GA80764@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:52147 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752243AbdBCKfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 05:35:06 -0500
In-Reply-To: <20170203060554.GA80764@ast-mbp.thefacebook.com> (Alexei
        Starovoitov's message of "Thu, 2 Feb 2017 22:05:57 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:

> On Fri, Feb 03, 2017 at 05:33:45PM +1300, Eric W. Biederman wrote:
>> 
>> The point is that we can make the inode number stable across migration
>> and the user space API for namespaces has been designed with that
>> possibility in mind.
>> 
>> What you have proposed is the equivalent of reporting a file name, and
>> instead of reporting /dir1/file1 /dir2/file1 just reporting file1 for
>> both cases.
>> 
>> That is problematic.
>> 
>> It doesn't matter that eBPF and CRIU do not mix.  When we implement
>> migration of the namespace file descriptors and can move them from
>> one system to another preserving the device number and inode number
>> so that criu of other parts of userspace can function better there will
>> be a problem.  There is not one unique inode number per namespace and
>> the proposed interface in your eBPF programs is broken.
>> 
>> I don't know when inode numbers are going to be the bottleneck we decide
>> to make migratable to make CRIU work better but things have been
>> designed and maintained very carefully so that we can do that.
>> 
>> Inode numbers are in the namespace of the filesystem they reside in.
>
> I saw that iproute2 is doing:
>   if ((st.st_dev == netst.st_dev) &&
>       (st.st_ino == netst.st_ino)) {
> but proc_alloc_inum() is using global ida,
> so I figured that iproute2 extra st_dev check must have been obsolete.
> So the long term plan is to make /proc to be namespace-aware?

The long term plan is to make /proc more namespace aware.  It is pretty
strongly namespace aware in several senses.  Of course when those things
are well executed you don't see them in userspace so they are easy to
over look.

> That's fair. In such case exposing inode only will
> lead to wrong assumptions.

Exactly.

>> >> But you told Eric that his nack doesn't matter, and maybe it would be
>> >> nice to ask him to clarify instead.
>> >
>> > Fair enough. Eric, thoughts?
>> 
>> In very short terms exporting just the inode number would require
>> implementing a namespace of namespaces, and that is NOT happening.
>> We are not going to design our kernel interfaces so badly that we need
>> to do that.
>> 
>> At a bare minimum you need to export the device number of the filesystem
>> as well as the inode number.
>
> Agree. Will do.
>
>> My expectation would be that now you are starting to look at concepts
>> that are namespaced the way you would proceed would be to associate a
>> full set of namespaces with your ebpf program.  Those namespaces would
>> come from the submitter of your ebpf program.  Namespaced values
>> would be in the terms of your associated namespaces.
>> 
>> That keeps things working the way userspace would expect.
>> 
>> The easy way to build such an association is to not allow your
>> contextless ebpf programs from being submitted to kernel in anything
>> other than the initial set of namespaces.
>> 
>> But please assume all global identifiers are namespaced.  If they aren't
>> that needs to be fixed because not having them namespaced will break
>> process migration at some point.
>> 
>> In short the fix here is to export both the inode number the device
>> number.  That is what it takes to uniquely identify a file.  It would be
>
> Agree. Will respin.
>
>> good if you went farther and limited your contextless ebpf programs to
>> only being installed by programs in the initial set of namespaces.
>
> you mean to limit to init_net only? This might break existing users.

And for proc/pid_namespace things like the device and inum the initial
pid namespace.

I expect you can limit yourself to fields that are namespace specific
before adding such a requirement in which case that will avoid breaking
existing users.

>> Does that make things clearer?
>
> yep. thanks for the feedback.

Welcome.

Eric
