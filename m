From: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] connector: add cgroup release event report to proc connector
Date: Thu, 28 May 2015 09:54:31 +0100
Message-ID: <CAK7xexmATyoUsOb5cgHF-Pz91ihQHm47sJoXmi15fk87yBJjNw@mail.gmail.com>
References: <1432678051-4372-1-git-send-email-dimitri.j.ledkov@intel.com>
 <5565A8F9.8040601@huawei.com> <CAK7xexkFm_BZ9sdB3VAZ-WGiikBeAQfaimXjggEtac+M2diV-g@mail.gmail.com>
 <55668BE9.1090100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
To: Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55668BE9.1090100-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 28 May 2015 at 04:30, Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
> On 2015/5/27 20:37, Dimitri John Ledkov wrote:
>> On 27 May 2015 at 12:22, Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>>> On 2015/5/27 6:07, Dimitri John Ledkov wrote:
>>>> Add a kernel API to send a proc connector notification that a cgroup
>>>> has become empty. A userspace daemon can then act upon such
>>>> information, and usually clean-up and remove such a group as it's no
>>>> longer needed.
>>>>
>>>> Currently there are two other ways (one for current & one for unified
>>>> cgroups) to receive such notifications, but they either involve
>>>> spawning userspace helper or monitoring a lot of files. This is a
>>>> firehose of all such events instead from a single place.
>>>>
>>>> In the current cgroups structure the way to get notifications is by
>>>> enabling `release_agent' and setting `notify_on_release' for a given
>>>> cgroup hierarchy. This will then spawn userspace helper with removed
>>>> cgroup as an argument. It has been acknowledged that this is
>>>> expensive, especially in the exit-heavy workloads. In userspace this
>>>> is currently used by systemd and CGmanager that I know of, both of
>>>> agents establish connection to the long running daemon and pass the
>>>> message to it. As a courtesy to other processes, such an event is
>>>> sometimes forwarded further on, e.g. systemd forwards it to the system
>>>> DBus.
>>>>
>>>> In the future/unified cgroups structure support for `release_agent' is
>>>> removed, without a direct replacement. However, there is a new
>>>> `cgroup.populated' file exposed that recursively reports if there are
>>>> any tasks in a given cgroup hierarchy. It's a very good flag to
>>>> quickly/lazily scan for empty things, however one would need to
>>>> establish inotify watch on each and every cgroup.populated file at
>>>> cgroup setup time (ideally before any pids enter said cgroup). Thus
>>>> again anybody else, but the original creator of a given cgroup, has a
>>>> chance to reliably monitor cgroup becoming empty (since there is no
>>>> reliable recursive inotify watch).
>>>>
>>>> Hence, the addition to the proc connector firehose. Multiple things,
>>>> albeit with a CAP_NET_ADMIN in the init pid/user namespace), could
>>>> connect and monitor cgroups release notifications. In a way, this
>>>> repeats udev history, at first it was a userspace helper, which later
>>>> became a netlink socket. And I hope, that proc connector is a
>>>> naturally good fit for this notification type.
>>>>
>>>> For precisely when cgroups should emit this event, see next patch
>>>> against kernel/cgroup.c.
>>>>
>>>
>>> We really don't want yet another way for cgroup notification.
>>>
>>
>> we do have multiple information sources for similar events in other
>> places... e.g. fork events can be tracked with ptrace and with
>> proc-connector, ditto other things.
>>
>>> Systemd is happy with this cgroup.populated interface. Do you have any
>>> real use case in mind that can't be satisfied with inotify watch?
>>>
>>
>> cgroup.populated is not implemented in systemd and would require a lot
>> of inotify watches.
>
> I believe systemd will use cgroup.populated, though I don't know its
> roadmap. Maybe it's waiting for the kernel to remove the experimental
> flag of unified hierarchy.
>

There is no code in master to support unified hierarchy in systemd
that I can see. And more and more things rely on the current
hierarchy, especially around container-like technologies.

>> Also it's only set on the unified structure and
>> not exposed on the current one.
>>
>> Also it will not allow anybody else to establish notify watch in a
>> timely manner. Thus anyone external to the cgroups creator will not be
>> able to monitor cgroup.populated at the right time.
>
> I guess this isn't a problem, as you can watch the IN_CREATE event, and
> then you'll get notified when a cgroup is created.
>

It is a problem, there is no effective way to establish race-free
inotify watches, which is well known. Having a watch on
/sys/fs/cgroup, one has to establish inotify watch on a directory
created there, and then another watch on cgroup.populated within
there. By which time a process could have already entered, run and
exited.

>> With
>> proc_connector I was thinking processes entering cgroups would be
>> useful events as well, but I don't have a use-case for them yet thus
>> I'm not sure how the event should look like.
>>
>> Would cgroup.populated be exposed on the legacy cgroup hierchy? At the
>> moment I see about ~20ms of my ~200ms boot wasted on spawning the
>> cgroups agent and I would like to get rid of that as soon as possible.
>> This patch solves it for me. ( i have a matching one to connect to
>> proc connector and then feed notifications to systemd via systemd's
>> private api end-point )
>>
>> Exposing cgroup.populated irrespective of the cgroup mount options
>> would be great, but would result in many watches being established
>> awaiting for a once in a lifecycle condition of a cgroup. Imho this is
>> wasteful, but nonetheless will be much better than spawning the agent.
>>
>
> Each inotify watch will consume a little memory, which should be
> acceptable.
>
>> Would a patch that exposes cgroup.populated on legacy cgroup structure
>> be accepted? It is forward-compatible afterall... or no?
>>
>
> I'm afraid no...All new features are done in unified hiearchy, and we've
> been restraining from adding them to the legacy hierarchy.
>

Am I right to say it's been a year with little movements in unified
hierarchy?! What's the current status on unmarking it experimental,
and/or what else needs doing in kernel and/or userspace?

What you are saying is that we have inefficient notification mechanism
that hammers everyone's boot time significantly, and no current path
to resolve it. What can I do get us efficient cgroup release
notifications soon?
This patch-set is a no-op if one doesn't subscribe from the userspace
and has no other side effects that I can trivially see and is very
similar in-spirit to other notifications that proc-connector
generates. E.g. /proc/pid/comm is exposed as a file, yet there is proc
connector notification as well about comm name changes. Maybe Evgeniy
can chip in, if such a notification would be beneficial to
proc-connector.

-- 
Regards,

Dimitri.
Pura Vida!

https://clearlinux.org
Open Source Technology Center
Intel Corporation (UK) Ltd. - Co. Reg. #1134945 - Pipers Way, Swindon SN3 1RJ.
