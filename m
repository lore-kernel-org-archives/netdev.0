From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next-2.6] netns: call ops_free right after ops_exit
Date: Sun, 25 Apr 2010 20:06:07 -0700
Message-ID: <m1r5m2ud40.fsf@fess.ebiederm.org>
References: <20100425092600.GB2866@psychotron.redhat.com>
	<20100425.025902.94572342.davem@davemloft.net>
	<m1k4rvvb5x.fsf@fess.ebiederm.org>
	<20100425184430.GA2891@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49928 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab0DZDGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 23:06:12 -0400
In-Reply-To: <20100425184430.GA2891@psychotron.redhat.com> (Jiri Pirko's message of "Sun\, 25 Apr 2010 20\:44\:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> writes:

> Sun, Apr 25, 2010 at 04:50:34PM CEST, ebiederm@xmission.com wrote:
>>David Miller <davem@davemloft.net> writes:
>>
>>> From: Jiri Pirko <jpirko@redhat.com>
>>> Date: Sun, 25 Apr 2010 11:26:01 +0200
>>>
>>>> There's no need to iterate this twice. We can free net generic
>>>> variables right after exit is called.
>>>>
>>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>>
>>> Are you sure there are no problems with doing this?
>>>
>>> What if there are inter-net variable reference dependencies
>>> or something like that?
>>>
>>> I really suspect it is being done this way on purpose, but
>>> in the end I defer to experts like Eric B. :-)
>>
>>I am pretty certain there is a problem.  My memory is fuzzy this
>>morning but I believe we can have rcu references between various
>>pieces of the networking stack for a single network namespace.  So we
>>need to cause all of the network namespace to exit before it is safe
>>to free those pieces.
>
> Hmm, that doesn't make much sense to me. Since the allocated memory in question
> is used locally, after exit() is called, the memory chunk should not be used by
> anyone and if it is, I think it's a bug.
>
> Earlier, when the memory wasn't allocated automatically (by filling .size)
> memory was individually freed in exit(). From what I understood from your reply,
> you are telling this was buggy?

Now I remember clearly.  The use case for not freeing memory
immediately is the delayed freeing of network devices.  Ideally we
delay unregistering all of the network devices into
default_device_exit_batch, when we terminate one or namespaces.

Since network devices are freed outside of their exit routines we need
to keep their per net memory around until they are freed.

Ultimately all of this is much easier to think about if these chunks of
memory can be logically thought of as living on struct net and have the
same lifetime rules.

Eric
