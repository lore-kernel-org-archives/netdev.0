From: Paul Moore <paul@paul-moore.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 19 Oct 2017 13:47:59 -0400
Message-ID: <CAHC9VhRHnDHFF-GZEz46kOZWQM6gCx3pWPZgOmd=a9R1W2CQFg@mail.gmail.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com> <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
 <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
 <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com> <1508254120.6230.34.camel@redhat.com>
 <1508255091.3129.27.camel@HansenPartnership.com> <CAHC9VhRV9m6-APj3ofMQc22rL-WUoDzB8-urUxryszjCHHHLTg@mail.gmail.com>
 <49752b6f-8a77-d1e5-8acb-5a1eed0a992c@suse.de> <871sm0j7bm.fsf@xmission.com>
 <CAHC9VhTYF-MJm3ejWXE1H-eeXKaNBkeWKwdiKdj093xATYn7nQ@mail.gmail.com> <87y3o7gl5l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Aleksa Sarai <asarai@suse.de>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        cgroups@vger.kernel.org, mszeredi@redhat.com,
        Andy Lutomirski <luto@kernel.org>, jlayton@redhat.com,
        "Carlos O'Donell" <carlos@redhat.com>,
        API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-audit@redhat.com, Simo Sorce <simo@redhat.com>,
        Development <netdev@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Eric Paris <eparis@parisplace.org>,
        Steve Grubb <sgrubb@redhat.com>, trondmy@primarydata.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:57024 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdJSRsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:48:01 -0400
Received: by mail-lf0-f53.google.com with SMTP id 90so10506757lfs.13
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 10:48:00 -0700 (PDT)
In-Reply-To: <87y3o7gl5l.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 12:25 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Paul Moore <paul@paul-moore.com> writes:
>
>> On Wed, Oct 18, 2017 at 8:43 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Aleksa Sarai <asarai@suse.de> writes:
>>>>>> The security implications are that anything that can change the label
>>>>>> could also hide itself and its doings from the audit system and thus
>>>>>> would be used as a means to evade detection.  I actually think this
>>>>>> means the label should be write once (once you've set it, you can't
>>>>>> change it) ...
>>>>>
>>>>> Richard and I have talked about a write once approach, but the
>>>>> thinking was that you may want to allow a nested container
>>>>> orchestrator (Why? I don't know, but people always want to do the
>>>>> craziest things.) and a write-once policy makes that impossible.  If
>>>>> we punt on the nested orchestrator, I believe we can seriously think
>>>>> about a write-once policy to simplify things.
>>>>
>>>> Nested containers are a very widely used use-case (see LXC system containers,
>>>> inside of which people run other container runtimes). So I would definitely
>>>> consider it something that "needs to be supported in some way". While the LXC
>>>> guys might be a *tad* crazy, the use-case isn't. :P
>>
>> No worries, we're all a little crazy in our own special ways ;)
>>
>> Kidding aside, thanks for explaining the use case.
>>
>>> Of course some of that gets to running auditd inside a container which
>>> we don't have yet either.
>>>
>>> So I think to start it is perfectly fine to figure out the non-nested
>>> case first and what makes sense there.  Then to sort out the nested
>>> container case.
>>>
>>> The solution might be that a process gets at most one id per ``audit
>>> namespace''.
>>
>> In an attempt to stay on-topic, let's try to stick with "audit
>> container ID" or "container ID" if you must.  I really want to avoid
>> the term "audit namespace" simply because the term "namespace" implies
>> some things which we aren't planning on doing.
>
> This is 100% on topic.  I am saying that unless we are planing to have
> auditd running in a container with it's own set of rules you probably
> don't care about nested containers.  Last time I heard a discussion
> about that the term in use was audit namespace.   So I was referring to
> that support when I said audit namespace, even if the end result only
> loosely fits the term namespace.

My "stay on-topic" comment is directed at, and limited to, your choice
of terminology, not the discussion about container nesting.  I'm
purposefully not using the term "audit namespace" to refer to anything
that Richard has presented, and I'm kindly asking you to do the same,
it simply doesn't fit.

> I could be wrong of course.  I don't fully understand what is driving
> the desire to connect audit and containers.  But my naive guess is that
> one from an audit perspective you don't care about nested containers
> unless there is also a nested auditd who is looking at it from a nested
> perspective.

Two motivations that are clear to me: the first is the desire to be
able to associate events in the audit log with a container (much like
how the session ID helped us associate events with a login session),
the second is the desire for users to run an audit daemon instance in
their containers to capture audit events generated by their container.
There is also a security certification motivation, see some of Steve's
comments for more on that.

-- 
paul moore
www.paul-moore.com
