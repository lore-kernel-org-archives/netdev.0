From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 09:10:43 -0700
Message-ID: <23dbaf2e-e02d-d4a1-d409-5c860f254bbc@schaufler-ca.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
 <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
 <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
 <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
 <1508254120.6230.34.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Richard Guy Briggs <rgb@redhat.com>, mszeredi@redhat.com,
        "Eric W. Biederman" <ebiederm@xmission.com>, jlayton@redhat.com,
        Carlos O'Donell <carlos@redhat.com>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        David Howells <dhowells@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andy Lutomirski <luto@kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        cgroups@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>,
        trondmy@primarydata.com
To: Simo Sorce <simo@redhat.com>, Steve Grubb <sgrubb@redhat.com>,
        linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sonic307-17.consmr.mail.ne1.yahoo.com ([66.163.190.40]:44087
        "EHLO sonic307-17.consmr.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757564AbdJQQKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 12:10:50 -0400
In-Reply-To: <1508254120.6230.34.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 8:28 AM, Simo Sorce wrote:
> On Tue, 2017-10-17 at 07:59 -0700, Casey Schaufler wrote:
>> On 10/17/2017 5:31 AM, Simo Sorce wrote:
>>> On Mon, 2017-10-16 at 21:42 -0400, Steve Grubb wrote:
>>>> On Monday, October 16, 2017 8:33:40 PM EDT Richard Guy Briggs
>>>> wrote:
>>>>> There is such a thing, but the kernel doesn't know about it
>>>>> yet.  This same situation exists for loginuid and sessionid
>>>>> which
>>>>> are userspace concepts that the kernel tracks for the
>>>>> convenience
>>>>> of userspace.  As for its name, I'm not particularly picky, so
>>>>> if
>>>>> you don't like CAP_CONTAINER_* then I'm fine with
>>>>> CAP_AUDIT_CONTAINERID.  It really needs to be distinct from
>>>>> CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we don't want to
>>>>> give
>>>>> the ability to set a containerID to any process that is able to
>>>>> do
>>>>> audit logging (such as vsftpd) and similarly we don't want to
>>>>> give
>>>>> the orchestrator the ability to control the setup of the audit
>>>>> daemon.
>>>> A long time ago, we were debating what should guard against rouge
>>>> processes from setting the loginuid. Casey argued that the
>>>> ability to
>>>> set the loginuid means they have the ability to control the audit
>>>> trail. That means that it should be guarded by CAP_AUDIT_CONTROL.
>>>> I
>>>> think the same logic applies today. 
>>> The difference is that with loginuid you needed to give processes
>>> able
>>> to audit also the ability to change it. You do not want to tie the
>>> ability to change container ids to the ability to audit. You want
>>> to be
>>> able to do audit stuff (within the container) without allowing it
>>> to
>>> change the container id.
>> Without a *kernel* policy on containerIDs you can't say what
>> security policy is being exempted.
> The policy has been basically stated earlier.

No. The expected user space behavior has been stated.

> A way to track a set of processes from a specific point in time
> forward. The name used is "container id", but it could be anything.

Then you want Jose Bollo's PTAGS. It's insane to add yet another
arbitrary ID to the task for a special purpose. Add a general tagging
mechanism instead. We could add a gazillion new id's, each with it's
own capability if we head down this road.

> This marker is mostly used by user space to track process hierarchies
> without races, these processes can be very privileged, and must not be
> allowed to change the marker themselves when granted the current common
> capabilities.

Let's be clear. What happens in user space stays in user space.
The kernel does not give a fig about user space policy. There has
to be a kernel policy involved that a capability can exempt.

> Is this a good enough description ? If not can you clarify your
> expectations ?

The kernel enforces kernel policy. Capabilities provide a mechanism
to mark a process as exempt from some aspect of kernel policy. If
you don't have a kernel policy, you don't get a capability. Clear?

>
>>  Without that you can't say what capability is (or isn't)
>> appropriate.
> See if the above is sufficient please.
>
>> You need a reason to have a capability check that makes sense in the
>> context of the kernel security policy.
> I think the proposal had a reason, we may debate on whether that reason
> is good enough.
>
>> Since we don't know what a container is in the kernel,
> Please do not fixate on the word container.
>
>>  that's pretty hard. We don't create "fuzzy" capabilities
>> based on the trendy application behavior of the moment. If the
>> behavior is not related it audit, there's no reason for it, and
>> if it is, CAP_AUDIT_CONTROL works just fine. If this doesn't work
>> in your application security model I suggest that is where you
>> need to make changes.
> The authors of the proposal came to the conclusion that kernel
> assistance is needed. It would be nice to discuss the merits of it.
> If you do not understand why the request has been made it would be more
> useful to ask specific questions to understand what and why is the ask.

I understand pretty darn well.

> Pushing back is fine, if you have understood the problem and have valid
> arguments against a kernel level solution (and possibly suggestions for
> a working user space solution), otherwise you are not adding value to
> the discussion.

The presumption is that the request is reasonable. Adding a capability
in support of an undefined behavior is unreasonable. Based on the discussion,
CAP_AUDIT_CONTROL is completely rational. I understand that it would be
difficult to support your application privilege model. I would like to look
into helping out with that, but have too many burning knives in the air
just now.

>
> Simo.
>
