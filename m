From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 09:43:18 -0700
Message-ID: <eb96144d-4ab5-7f9f-de18-b296db35a00a@schaufler-ca.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
 <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
 <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
 <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
 <1508254120.6230.34.camel@redhat.com>
 <1508255091.3129.27.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: mszeredi@redhat.com, trondmy@primarydata.com, jlayton@redhat.com,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        Carlos O'Donell <carlos@redhat.com>, cgroups@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Andy Lutomirski <luto@kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        Al Viro <viro@zeniv.linux.org.uk>
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Simo Sorce <simo@redhat.com>, Steve Grubb <sgrubb@redhat.com>,
        linux-audit@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508255091.3129.27.camel@HansenPartnership.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2017 8:44 AM, James Bottomley wrote:
> On Tue, 2017-10-17 at 11:28 -0400, Simo Sorce wrote:
>>> Without a *kernel* policy on containerIDs you can't say what
>>> security policy is being exempted.
>> The policy has been basically stated earlier.
>>
>> A way to track a set of processes from a specific point in time
>> forward. The name used is "container id", but it could be anything.
>> This marker is mostly used by user space to track process hierarchies
>> without races, these processes can be very privileged, and must not
>> be allowed to change the marker themselves when granted the current
>> common capabilities.
>>
>> Is this a good enough description ? If not can you clarify your
>> expectations ?
> I think you mean you want to be able to apply a label to a process
> which is inherited across forks.

That would be PTAGS. I agree that such a general mechanism
could be very useful for a variety of purposes, not just
containers. I do not agree that a single integer (e.g. a
containerID) warrants more than trivial mechanism.

> The label should only be susceptible
> to modification by something possessing a capability (which one TBD).

I think that the reason we're going to have crying and gnashing
of teeth is that whatever capability is used. There will always be
an issue of the capability granted being less specific than the
application security model would like.

And no, we're not going down the 330 capabilities road. It's been
done in the UNIX world. Application security models hate that
just as much as they hate the coarser granularity.

> The idea is that processes spawned into a container would be labelled
> by the container orchestration system.  It's unclear what should happen
> to processes using nsenter after the fact, but policy for that should
> be up to the orchestration system.

I'm fine with that. The user space policy can be anything y'all like.

> The label will be used as a tag for audit information.

Deep breath ...

Which *is* a kernel security policy mechanism. Since the "label"
is part of the audit information that the kernel is guaranteeing
changing it would be covered by CAP_AUDIT_CONTROL. If the kernel
does not use the "label" for any other purpose this is the only
capability that makes sense for it.

> I think you were missing label inheritance above.
>
> The security implications are that anything that can change the label
> could also hide itself and its doings from the audit system and thus
> would be used as a means to evade detection.  

Yes. This is a consequence of the capability granularity. There is
no way we can make the capability granularity sufficiently fine to
prevent this. No one wants the 330 capabilities that Data General
had in their secure UNIX system. 

> I actually think this
> means the label should be write once (once you've set it, you can't
> change it) and orchestration systems should begin as unlabelled
> processes allowing them to do arbitrary forks.
>
> For nested containers, I actually think the label should be
> hierarchical, so you can add a label for the new nested container but
> it still also contains its parents label as well.

You can't support this reasonably with a single containerID.
You want PTAGS for this. I know that there is resistance to
requiring anything beyond what's in the base kernel (and for
good reasons) for containers. Especially something that is
pending future work. But let's not jam something into the base
kernel that isn't really going to address the issue.

> James
