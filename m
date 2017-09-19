From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: Audit Kernel Container IDs
Date: Mon, 18 Sep 2017 21:45:19 -0500
Message-ID: <87wp4v76f4.fsf@xmission.com>
References: <20170913171328.GP3405@madcap2.tricolour.ca>
        <87d16tb2y5.fsf@xmission.com>
        <20170914180704.GU3405@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Audit <linux-audit@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Aristeu Rozanski <arozansk@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@parisplace.org>, jlayton@redhat.com,
        Andy Lutomirski <luto@kernel.org>, mszeredi@redhat.com,
        Paul Moore <pmoore@redhat.com>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Steve Grubb <sgrubb@redhat.com>, trondmy@primarydata.com,
        Al Viro <viro@zeniv.linux.org.uk>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170914180704.GU3405@madcap2.tricolour.ca> (Richard Guy
        Briggs's message of "Thu, 14 Sep 2017 14:07:04 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Guy Briggs <rgb@redhat.com> writes:

> On 2017-09-14 12:33, Eric W. Biederman wrote:
>> Richard Guy Briggs <rgb@redhat.com> writes:
>> 
>> > The trigger is a pseudo filesystem (proc, since PID tree already exists)
>> > write of a u64 representing the container ID to a file representing a
>> > process that will become the first process in a new container.
>> > This might place restrictions on mount namespaces required to define a
>> > container, or at least careful checking of namespaces in the kernel to
>> > verify permissions of the orchestrator so it can't change its own
>> > container ID.
>> 
>> Why a u64?
>
> u32 will roll too quickly.  UUID is large enough that it adds
> significantly to audit record bandwidth.  I'd prefer u64, but can look
> at the difference of accommodating a UUID...

I was imagining a string might be better.  As for the purposes of audit
it is just a byte string you regurgitate.

>> Why a proc filesystem write and not a magic audit message?
>
> A magic audit message requires CAP_AUDIT_WRITE, which we'd like to use
> sparingly.  Given that orchestrators will already require it to send
> the mandatory AUDIT_VIRT_*, this doesn't seem like an unreasonable burden.
>
> I was originally leaning towards an audit message trigger or a syscall.
>
>> I don't like the fact that the proc filesystem entry is likely going to
>> be readable and abusable by non-audit contexts?
>
> This proposal wasn't going to start with that link being readable, but
> its filesystem structure and link names would be, perhaps giving away
> too much already.
>
> I think we will need to find a way for the orchestrator or one of its
> authorized agents to read this information while blocking reads from
> unauthorized agents, otherwise this would be of very limited use.

Something that is set only for future audit messages seems reasonable.
Once you start reading this from something other than audit messages I
get neverous, that people will use this beyond audit for things it is
not intended for.

>> Why the ability to change the containerid?  What is the use case you are
>> thinking of there?
>
> This was covered in the end of the conversation with Paul Moore (that
> maybe you got tired reading?)

I have not had time to review everything.  As I was busy preparing for my
wedding and am now in the middle of my honeymoon.

> I'd originally proposed having it write
> once, but Paul figured there was no good reason to restrict it and leave
> that decision up to the orchestrator.  The use case would be adding
> other processes to a container, but it could be argued all additional
> processes should be spawned by the first process in a container.

I see two cases here:
a) Nested containers
b) Inject processes via something like nsenter into a container.

In case a) you have to figure out what to do with nested containers
and that does seem to be a legitimate case for a double write.  Arguably
with the restriction that you must specify a more nested label.

In case b) which you seem to be referring to it would be a process
created by the container manager outside the container that has no
container label.  At which point there is not a need for a double write.

So my recommendation is to not support double writes until you support
nested containers.

Eric
