From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RESEND PATCH] Allow passing tid or pid in SCM_CREDENTIALS without CAP_SYS_ADMIN
Date: Wed, 30 Aug 2017 12:41:21 -0500
Message-ID: <87inh5ymv2.fsf@xmission.com>
References: <1503965540-30393-1-git-send-email-prakash.sangappa@oracle.com>
        <20170829.160232.1901318933754673000.davem@davemloft.net>
        <c9ea9bec-6b0e-70d6-3f74-9b483358edd2@oracle.com>
        <87ziahzzhx.fsf@xmission.com>
        <d23ec1ae-e2f0-659c-ce67-9b1b1e9ad8a5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, drepper@redhat.com
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d23ec1ae-e2f0-659c-ce67-9b1b1e9ad8a5@oracle.com> (Prakash
        Sangappa's message of "Wed, 30 Aug 2017 08:57:08 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prakash Sangappa <prakash.sangappa@oracle.com> writes:

> On 8/29/17 5:10 PM, ebiederm@xmission.com wrote:
>
>  "prakash.sangappa" <prakash.sangappa@oracle.com> writes:
>
>  On 08/29/2017 04:02 PM, David Miller wrote:
>
>  From: Prakash Sangappa <prakash.sangappa@oracle.com>
> Date: Mon, 28 Aug 2017 17:12:20 -0700
>
>  Currently passing tid(gettid(2)) of a thread in struct ucred in
> SCM_CREDENTIALS message requires CAP_SYS_ADMIN capability otherwise
> it fails with EPERM error. Some applications deal with thread id
> of a thread(tid) and so it would help to allow tid in SCM_CREDENTIALS
> message. Basically, either tgid(pid of the process) or the tid of
> the thread should be allowed without the need for CAP_SYS_ADMIN capability.
>
> SCM_CREDENTIALS will be used to determine the global id of a process or
> a thread running inside a pid namespace.
>
> This patch adds necessary check to accept tid in SCM_CREDENTIALS
> struct ucred.
>
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
>
> I'm pretty sure that by the descriptions in previous changes to this
> function, what you are proposing is basically a minor form of PID
> spoofing which we only want someone with CAP_SYS_ADMIN over the
> PID namespace to be able to do.
>
> The fix is to allow passing tid of the calling thread itself not of any
> other thread or process. Curious why would this be considered
> as pid spoofing?
>
> This change would enable a thread in a multi threaded process, running
> inside a pid namespace to be identified by the recipient of the
> message easily.
>
> I think a more practical problem is that change, changes what is being
> passed in the SCM_CREDENTIALS from a pid of a process to a tid of a
> thread.  That could be confusing and that confusion could be exploited.
>
> It will be upto the application to decide what to pass, either pid of the 
> process or tid of the thread and the co-operating process receiving the
> message would know what to expect. It does not change or make it 
> mandatory to pass tid. 
>
>  
> It is definitely confusing because in some instances a value can be both
> a tgid and a tid.
>
>  
> I definitely think this needs to be talked about in terms of changing
> what is passed in that field and what the consequences could be.
>
> Agreed that If the receiving process expects a pid and the process sending
> the message sends tid, it can cause confusion, but why would that occur? 
> Shouldn't the sending process know what is the receiving process expecting?
>
>  
> I suspect you are ok.  As nothing allows passing a tid today.  But I
> don't see any analysis on why passing a tid instead of a tgid will not
> confuse the receiving application, and in such confusion introduce a
> security hole.
>
> It would seem that there has to be an understanding between the two
> processes what is being passed(pid or tid) when communicating with 
> each other.

Which is the issue.  SCM_CREDENTIALS is fundamentally about dealing with
processes that are in a less than completely trusting relationship.

> With regards to security, the question basically is what is the consequence
> of passing the wrong id. As I understand it, Interpreting the id to be pid 
> or tid, the effective uid and gid will be the same. It would be a problem 
> only if the incorrect interpretation of the id would refer a different process. 
> But that cannot happen as the the global tid(gettid() of a thread is
> unique.

There is also the issue that the receiving process could look, not see
the pid in proc and assume the sending process is dead.  That I suspect
is the larger danger.

> As long as the thread is alive, that id cannot reference another process / thread. 
> Unless the thread were to exit and the id gets recycled and got used for another 
> thread or process. This would be no different from a process exiting and its
> pid getting recycled which is the case now.

Largely I agree.

If all you want are pid translations I suspect the are far easier ways
thant updating the SCM_CREDENTIALS code.

Eric
