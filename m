From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Wed, 12 Dec 2012 12:56:39 +0400
Message-ID: <50C846C7.5050904@parallels.com>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com> <20121207010355.c809b3f7.akpm@linux-foundation.org> <20121207142331.GC4004@sergelap> <50C1FD9D.5020703@parallels.com> <87r4n1buuw.fsf@xmission.com> <50C6EDF0.5060108@parallels.com> <87txrs30ur.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rui Xiang <leo.ruixiang@gmail.com>, <netdev@vger.kernel.org>,
	<containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:45935 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab2LLI4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 03:56:38 -0500
In-Reply-To: <87txrs30ur.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2012 10:22 PM, Eric W. Biederman wrote:
> Glauber Costa <glommer@parallels.com> writes:
> 
>> On 12/07/2012 10:05 PM, Eric W. Biederman wrote:
>>> Glauber Costa <glommer@parallels.com> writes:
>>>
>>>> I keep asking myself if it isn't the case of forwarding to a container
>>>> all messages printed in process context. That will obviously exclude all
>>>> messages resulting from kthreads - that will always be in the initial
>>>> namespace anyway, interrupts, etc. There is no harm, for instance, in
>>>> delivering the same message twice: one to the container, and the other
>>>> to the host system.
>>>
>>> Except that there is harm in double printing.  One of the better
>>> justifications for doing something with the kernel log is that it is
>>> possible to overflow the kernel log with operations performed
>>> exclusively in a container.
>>>
>> I don't agree with you here.
>>
>> If we are double printing, we are using up more memory, but we also have
>> an extra buffer anyway. The messages are print on behalf of the user,
>> but still, by the kernel.
>>
>> So one of the following will necessarily hold:
>>
>> 1) There is no way that the process can overflow the main log, and as a
>> consequence, the container log, that has less messages than it.
>>
>> 2) The process will overflow the main log. But since we are not printing
>> anything extra to the main log compared to the scenario in which the
>> process lives in the main namespace, this would already be a problem
>> independent of namespaces. And needs to be fixed.
> 
> Well mounts, brining network interfaces up and down, running packets
> through our own choice of firewall rules, possibly enabling debug
> messages on network interfaces has the potential to create messages we
> aren't seeing today.
> 

There are two kinds of messages: the ones that would be print anyway if
you were not running in an ns, which we have no reason to fear, and the
ones that only exist because we wrote the code for them, due to ns
support. They are no different from writing a new fs support, driver,
etc. Any new functionality can print new messages, and we have to be
sure they won't fill the log. We write that code, so it is on us to make
sure the messages are being print in a reasonable rate.

This should be true for all messages running in process context. It is
either that, or we have a bug and we relying on a specific clone flag to
protect us against the buffer overrun.


>> IOW, double printing should not print anything *extra* to the main log.
>> It just prints to the container log, and leaves a copy to the box admin
>> to see. I think it is very reasonable to imagine that the main admin
>> would like to see anything the kernel has to tell him about the box.
> 
> The only reason that I have seen for doing anything with printks is
> because we are generating messages that would not be generated in a
> non-container environment.  At which point double printing is scary
> because it allows a container user to flood the kernel log ring buffer
> and suppress interesting messages.
> 
>>> I do think the idea of process context printks going to the current
>>> container one worth playing with.
>>>
>>
>> It still leaves the problem of prinkts outside process context that
>> should go to a namespace open. But it is easy to extend this idea to do
>> both.
> 
> Hmm.  For printks from process context I think I can see a point where
> double printing makes sense, because that is a rather indiscriminate grab
> of printk messages.
> 
exactly. What I have in mind this whole time, is that if you are
printing a message of interest of the container admin, it is *very
likely* also of interest of the box admin, specially if it indicates
something going wrong. Maybe what goes and does not go to the main
buffer can be determined by the log level of each buffer. But still, I
think that just hiding them from the box admin may not exactly be what
we want.

Cheers
