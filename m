From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 17:26:41 -0800
Message-ID: <m1mxywyege.fsf@fess.ebiederm.org>
References: <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<20100226010915.GA20106@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>
To: Matt Helsley <matthltc@us.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100226010915.GA20106@count0.beaverton.ibm.com> (Matt Helsley's message of "Thu\, 25 Feb 2010 17\:09\:15 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Helsley <matthltc@us.ibm.com> writes:

> On Thu, Feb 25, 2010 at 12:57:02PM -0800, Eric W. Biederman wrote:
>> 
>> Introduce two new system calls:
>> int nsfd(pid_t pid, unsigned long nstype);
>> int setns(unsigned long nstype, int fd);
>> 
>> These two new system calls address three specific problems that can
>> make namespaces hard to work with.
>> - Namespaces require a dedicated process to pin them in memory.
>> - It is not possible to use a namespace unless you are the
>>   child of the original creator.
>> - Namespaces don't have names that userspace can use to talk
>>   about them.
>> 
>> The nsfd() system call returns a file descriptor that can
>> be used to talk about a specific namespace, and to keep
>> the specified namespace alive.
>> 
>> The fd returned by nsfd() can be bind mounted as:
>> mount --bind /proc/self/fd/N /some/filesystem/path
>> to keep the namespace alive indefinitely as long as
>> it is mounted.
>> 
>> open works on the fd returned by nsfd() so another
>> process can get a hold of it and do interesting things.
>> 
>> Overall that allows for persistent naming of namespaces
>> according to userspace policy.
>> 
>> setns() allows changing the namespace of the current process
>> to a namespace that originates with nsfd().
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>> 
>> This is just my first pass at this, and not yet compiled tested.
>> I was pleasantly surprised at how easy all of this was to implement.
>
> <snip>
>
>> +SYSCALL_DEFINE2(setns, unsigned long, nstype, int, fd)
>> +{
>> +	struct file *file;
>> +
>> +	if (!capable(CAP_SYS_ADMIN))
>> +		return -EPERM;
>
> Is this check preliminary? In the future would we check against the
> owner of the target namespace too? Naturally that will require tagging
> each namespace with an owner but I thought that was already part of the
> plan...

We aren't modifying the namespace here so namespace owners are
irrelevant here.

We are modifying the process so we need to have CAP_SYS_ADMIN in the
processes credential/uid namespace.

Eric
