From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 01 Mar 2010 11:24:59 -0800
Message-ID: <m1aaur26b8.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, hadi@cyberus.ca,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B8AE8C1.1030305@free.fr> (Daniel Lezcano's message of "Sun\, 28 Feb 2010 23\:05\:53 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano@free.fr> writes:


>> Replacing struct pid is guaranteed to do all kinds of nasty things with
>> signal handling and the like, de_thread is nasty enough and you are talking
>> something worse.  So if we can change pid namespaces without changing
>> the pid I am for it.
>
> I agree with all the points you and Pavel you talked about but I don't feel
> comfortable to have the current process to switch the pid namespace because of
> the process tree hierarchy (what will be the parent of the process when you
> enter the pid namespace for example). What is the difference with the sys_bindns
> or the sys_hijack, proposed a couple of years ago ?

I was not aiming at the general enter case.  There is a very specific case
in networking where we only need a network namespace, not full blown containers
so I was seeing what could be done to handle the easy case.

The big idea is solving the namespace naming issues with bind mounts and file
descriptors.  All of the rest is window dressing for that idea.

setns looks like the easy way but what is really needed for the network namespace
is a way to open sockets that are in a specified network namespace.

> I did a suggestion some weeks ago about a new syscall 'cloneat' where the child
> process becomes the child of the targeted process specified in the
> syscall. Maybe it would be interesting to replace the 'setns' by, or add, a
> cloneat' syscall with the file descriptor passed as parameter. The copy_process
> function shall not use the nsproxy of the caller but the one provided in the fd
> argument.
>
> The newly created process becomes the child of the process where we retrieve the
> namespace with nsfd and this one have to 'waitpid' it, (the caller of 'cloneat'
> can not wait it). It's a bit similar with the CLONE_PARENT flag, except the
> creation order is inverted (the father creates for the child).
>
> So when entering the container, we specify the pid 1 of the container which is
> usually a child reaper.
>
> Does it make sense ?

Essentially.  I am not hugely interested in solving the general case
if it takes us off into tangents about pid namespace semantics.

I have just realized that while the original use case for having unix
domain sockets able to work across network namespaces was a little
weak, there are much better arguments.  Operationally it is a game
changer.  In the case where you don't need to support migration it
allows direct access to your X server and greatly simplifies the
design of a server designed to start processes in your container.

Eric
