From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 06 Mar 2010 12:48:31 -0800
Message-ID: <m1aaulyy5c.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B926B1B.5070207-GANU6spQydw@public.gmane.org> (Daniel Lezcano's message of "Sat\,
	06 Mar 2010 15\:47\:55 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:

> Eric W. Biederman wrote:

> If the normal rules of parentage apply, that means pid 0 has to wait it's child.
> If we are in the scenario of pid 0, it's child pid 1234 and we kill the pid 1 of
> the pid namespace, I suppose pid 1234 will be killed too.
> The pid 0 will stay in the pid namespace and will able to fork again a new pid
> 1.
>
> I think Serge already reported that...
>
> That sounds good :)

I expect zap_pid_ns_processes should also arrange so we cannot allocate any
more processes.  We certainly need to do something explicit or pid 1 won't
be allocated.  It might make sense to resurrect a pid namespace after it's
death but it is definitely weird.

>> In a lot of ways I like this idea of sys_hijack/sys_cloneat, and I
>> don't think anything I am doing fundamentally undermines it.  The use
>> case of doing things in fork is that there is automatic inheritance of
>> everything.  All of the namespaces and all of the control groups, and
>> possibly also the parent process.  
> And also the rootfs for executing the command inside the container
> (eg. shutdown), the uid/gid (if there is a user namespace), the mount points,
> ...
> But I suppose we can do the same with setns for all the namespaces and chrooting
> within the container rootfs.
>
> What I see is a problem with the tty. For example, we cloneat the init process
> of the container which is usually /sbin/init but this one has its tty mapped to
> /dev/console, so the output of the exec'ed command will go to the console.

My original thinking was that the fd's would come from the caller of sys_cloneat....

>> Overall it sounds like the semantics I have proposed with
>> unshare(CLONE_NEWPID) are workable, and simple to implement.  The
>> extra fork is a bit surprising but it certainly does not
>> look like a show stopper for implementing a pid namespace join.
>>   
> I agree, it's some kind of "ghost" process.
> IMO, with a bit of userspace code it would be possible to enter or exec a
> command inside a container with nsfd, setns.
>
> +1 to test your patchset Eric :)

I will see about reposting sometime soon.

> Just a mindless suggestion, the "nsopen" / "nsattach" syscall names should be
> more clear no ?

Not bad suggestions.

I am going to explore a bit more.  Given that nsfd is using the same
permission checks as a proc file, I think I can just make it a proc
file.  Something like "/proc/<pid>/ns/net".  With a little luck that
won't suck too badly.

> Jumping back, one question about the nsfd and the poll for waiting the end of
> the namespace.
> If we have an openened file descriptor on a specific namespace, we grab a
> reference on this one, so the namespace won't be destroyed until we close the fd
> which is used to poll the end of the namespace, no ? Did I miss something ?

Not really.  The assumption was that there would be a very similar
file descriptor that we could use with poll.

Eric
