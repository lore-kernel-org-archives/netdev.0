From: Paul Moore <paul@paul-moore.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 19 Oct 2017 11:51:13 -0400
Message-ID: <CAHC9VhTN069L+-ei05EB8csiv1uJvoB-4SNhb9BcxSom=cRVeg@mail.gmail.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com> <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
 <81c15928-c445-fb8e-251c-bee566fbbf58@schaufler-ca.com> <20171019000527.eio6dfsmujmtioyt@madcap2.tricolour.ca>
 <18cb69a5-f998-0e6e-85df-7f4b9b768a6f@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Richard Guy Briggs <rgb@redhat.com>, mszeredi@redhat.com,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Simo Sorce <simo@redhat.com>, jlayton@redhat.com,
        "Carlos O'Donell" <carlos@redhat.com>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        David Howells <dhowells@redhat.com>,
        Linux Audit <linux-audit@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andy Lutomirski <luto@kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        cgroups@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>,
        trondmy@primarydata.com
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18cb69a5-f998-0e6e-85df-7f4b9b768a6f@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 9:32 AM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> On 10/18/2017 5:05 PM, Richard Guy Briggs wrote:
>> On 2017-10-17 01:10, Casey Schaufler wrote:
>>> On 10/16/2017 5:33 PM, Richard Guy Briggs wrote:
>>>> On 2017-10-12 16:33, Casey Schaufler wrote:
>>>>> On 10/12/2017 7:14 AM, Richard Guy Briggs wrote:
>>>>>> Containers are a userspace concept.  The kernel knows nothing of them.
>>>>>>
>>>>>> The Linux audit system needs a way to be able to track the container
>>>>>> provenance of events and actions.  Audit needs the kernel's help to do
>>>>>> this.
>>>>>>
>>>>>> Since the concept of a container is entirely a userspace concept, a
>>>>>> registration from the userspace container orchestration system initiates
>>>>>> this.  This will define a point in time and a set of resources
>>>>>> associated with a particular container with an audit container ID.
>>>>>>
>>>>>> The registration is a pseudo filesystem (proc, since PID tree already
>>>>>> exists) write of a u8[16] UUID representing the container ID to a file
>>>>>> representing a process that will become the first process in a new
>>>>>> container.  This write might place restrictions on mount namespaces
>>>>>> required to define a container, or at least careful checking of
>>>>>> namespaces in the kernel to verify permissions of the orchestrator so it
>>>>>> can't change its own container ID.  A bind mount of nsfs may be
>>>>>> necessary in the container orchestrator's mntNS.
>>>>>> Note: Use a 128-bit scalar rather than a string to make compares faster
>>>>>> and simpler.
>>>>>>
>>>>>> Require a new CAP_CONTAINER_ADMIN to be able to carry out the
>>>>>> registration.
>>>>> Hang on. If containers are a user space concept, how can
>>>>> you want CAP_CONTAINER_ANYTHING? If there's not such thing as
>>>>> a container, how can you be asking for a capability to manage
>>>>> them?
>>>> There is such a thing, but the kernel doesn't know about it yet.
>>> Then how can it be the kernel's place to control access to a
>>> container resource, that is, the containerID.
>> Ok, let me try to address your objections.
>>
>> The kernel can know enough that if it is already set to not allow it to
>> be set again.  Or if the user doesn't have permission to set it that the
>> user be denied this action.  How is this different from loginuid and
>> sessionid?
>>>>   This
>>>> same situation exists for loginuid and sessionid which are userspace
>>>> concepts that the kernel tracks for the convenience of userspace.
>>> Ah, no. Loginuid identifies a user, which is a kernel concept in
>>> that a user is defined by the uid.
>> This simple explanation doesn't help me.  What makes that a kernel
>> concept?  The fact that it is stored and compared in more than one
>> place?
>>
>>> The session ID has well defined kernel semantics. You're trying to say
>>> that the containerID is an opaque value that is meaningless to the
>>> kernel, but you still want the kernel to protect it. How can the
>>> kernel know if it is protecting it correctly?
>> How so?  A userspace process triggers this.  Does the kernel know what
>> these values mean?  Does it do anything with them other than report
>> them or allow audit to filter them?  It is given some instructions on
>> how to treat it.
>>
>> This is what we're trying to do with the containerID.
>>
>>>>   As
>>>> for its name, I'm not particularly picky, so if you don't like
>>>> CAP_CONTAINER_* then I'm fine with CAP_AUDIT_CONTAINERID.  It really
>>>> needs to be distinct from CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we
>>>> don't want to give the ability to set a containerID to any process that
>>>> is able to do audit logging (such as vsftpd) and similarly we don't want
>>>> to give the orchestrator the ability to control the setup of the audit
>>>> daemon.
>>> Sorry, but what aspect of the kernel security policy is this
>>> capability supposed to protect? That's what capabilities are
>>> for, not the undefined support of undefined user-space behavior.
>> Similarly, loginuids and sessionIDs are only used for audit tracking and
>> filtering.
>
> Tell me again why you're not reusing either of these?

Ah, granularity arguments, welcome back old friend :)

Once again, we're still trying to sort all this out so I reserve the
right to change my mind, but my current thinking is as follows ...
CAP_AUDIT_WRITE exists to control which applications can submit
userspace generated audit records to the kernel, CAP_AUDIT_CONTROL
exists to control which applications can manage the in-kernel audit
configuration (e.g. filter rules) and the current task's loginuid
value.  Reusing CAP_AUDIT_WRITE here would allow any application that
can submit userspace audit records the ability to change the audit
container ID; this would be bad, we don't allow CAP_AUDIT_WRITE to
change the loginuid, it would be even worse to allow it to change the
audit container ID.  Reusing CAP_AUDIT_CONTROL is less worse than than
CAP_AUDIT_WRITE, but it gets sticky once we get to the part where we
want to auditd instances in containers, complete with their own
queues, filtering rules, etc..  Perhaps we could use CAP_AUDIT_CONTROL
to guard the audit container ID value, but we would always want to do
that check in the init userns in order to prevent container bound
processes from manipulating their own audit container ID.

-- 
paul moore
www.paul-moore.com
