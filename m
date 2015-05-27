From: Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] connector: add cgroup release event report to proc
 connector
Date: Wed, 27 May 2015 19:22:33 +0800
Message-ID: <5565A8F9.8040601@huawei.com>
References: <1432678051-4372-1-git-send-email-dimitri.j.ledkov@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432678051-4372-1-git-send-email-dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/5/27 6:07, Dimitri John Ledkov wrote:
> Add a kernel API to send a proc connector notification that a cgroup
> has become empty. A userspace daemon can then act upon such
> information, and usually clean-up and remove such a group as it's no
> longer needed.
> 
> Currently there are two other ways (one for current & one for unified
> cgroups) to receive such notifications, but they either involve
> spawning userspace helper or monitoring a lot of files. This is a
> firehose of all such events instead from a single place.
> 
> In the current cgroups structure the way to get notifications is by
> enabling `release_agent' and setting `notify_on_release' for a given
> cgroup hierarchy. This will then spawn userspace helper with removed
> cgroup as an argument. It has been acknowledged that this is
> expensive, especially in the exit-heavy workloads. In userspace this
> is currently used by systemd and CGmanager that I know of, both of
> agents establish connection to the long running daemon and pass the
> message to it. As a courtesy to other processes, such an event is
> sometimes forwarded further on, e.g. systemd forwards it to the system
> DBus.
> 
> In the future/unified cgroups structure support for `release_agent' is
> removed, without a direct replacement. However, there is a new
> `cgroup.populated' file exposed that recursively reports if there are
> any tasks in a given cgroup hierarchy. It's a very good flag to
> quickly/lazily scan for empty things, however one would need to
> establish inotify watch on each and every cgroup.populated file at
> cgroup setup time (ideally before any pids enter said cgroup). Thus
> again anybody else, but the original creator of a given cgroup, has a
> chance to reliably monitor cgroup becoming empty (since there is no
> reliable recursive inotify watch).
> 
> Hence, the addition to the proc connector firehose. Multiple things,
> albeit with a CAP_NET_ADMIN in the init pid/user namespace), could
> connect and monitor cgroups release notifications. In a way, this
> repeats udev history, at first it was a userspace helper, which later
> became a netlink socket. And I hope, that proc connector is a
> naturally good fit for this notification type.
> 
> For precisely when cgroups should emit this event, see next patch
> against kernel/cgroup.c.
> 

We really don't want yet another way for cgroup notification.

Systemd is happy with this cgroup.populated interface. Do you have any
real use case in mind that can't be satisfied with inotify watch?
