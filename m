From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: limit a number of namespaces which can be cleaned up concurrently
Date: Sat, 15 Oct 2016 11:36:45 -0500
Message-ID: <87eg3hy3fm.fsf@x220.int.ebiederm.org>
References: <1476293579-28582-1-git-send-email-avagin@openvz.org>
        <871szk9rl9.fsf@x220.int.ebiederm.org>
        <20161013204405.GA19836@outlook.office365.com>
        <87k2db39zf.fsf@x220.int.ebiederm.org>
        <20161014212642.GA2005@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrei Vagin <avagin@openvz.org>, <netdev@vger.kernel.org>,
        <containers@lists.linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>
To: Andrei Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42623 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbcJOQiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 12:38:51 -0400
In-Reply-To: <20161014212642.GA2005@outlook.office365.com> (Andrei Vagin's
        message of "Fri, 14 Oct 2016 14:26:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrei Vagin <avagin@virtuozzo.com> writes:

> On Thu, Oct 13, 2016 at 10:06:28PM -0500, Eric W. Biederman wrote:
>> Andrei Vagin <avagin@virtuozzo.com> writes:
>> 
>> > On Thu, Oct 13, 2016 at 10:49:38AM -0500, Eric W. Biederman wrote:
>> >> Andrei Vagin <avagin@openvz.org> writes:
>> >> 
>> >> > From: Andrey Vagin <avagin@openvz.org>
>> >> >
>> >> > The operation of destroying netns is heavy and it is executed under
>> >> > net_mutex. If many namespaces are destroyed concurrently, net_mutex can
>> >> > be locked for a long time. It is impossible to create a new netns during
>> >> > this period of time.
>> >> 
>> >> This may be the right approach or at least the right approach to bound
>> >> net_mutex hold times but I have to take exception to calling network
>> >> namespace cleanup heavy.
>> >> 
>> >> The only particularly time consuming operation I have ever found are calls to
>> >> synchronize_rcu/sycrhonize_sched/synchronize_net.
>> >
>> > I booted the kernel with maxcpus=1, in this case these functions work
>> > very fast and the problem is there any way.
>> >
>> > Accoding to perf, we spend a lot of time in kobject_uevent:
>> >
>> > -   99.96%     0.00%  kworker/u4:1     [kernel.kallsyms]  [k] unregister_netdevice_many
>> >    - unregister_netdevice_many
>> >       - 99.95% rollback_registered_many
>> >          - 99.64% netdev_unregister_kobject
>> >             - 33.43% netdev_queue_update_kobjects
>> >                - 33.40% kobject_put
>> >                   - kobject_release
>> >                      + 33.37% kobject_uevent
>> >                      + 0.03% kobject_del
>> >                + 0.03% sysfs_remove_group
>> >             - 33.13% net_rx_queue_update_kobjects
>> >                - kobject_put
>> >                - kobject_release
>> >                   + 33.11% kobject_uevent
>> >                   + 0.01% kobject_del
>> >                     0.00% rx_queue_release
>> >             - 33.08% device_del
>> >                + 32.75% kobject_uevent
>> >                + 0.17% device_remove_attrs
>> >                + 0.07% dpm_sysfs_remove
>> >                + 0.04% device_remove_class_symlinks
>> >                + 0.01% kobject_del
>> >                + 0.01% device_pm_remove
>> >                + 0.01% sysfs_remove_file_ns
>> >                + 0.00% klist_del
>> >                + 0.00% driver_deferred_probe_del
>> >                  0.00% cleanup_glue_dir.isra.14.part.15
>> >                  0.00% to_acpi_device_node
>> >                  0.00% sysfs_remove_group
>> >               0.00% klist_del
>> >               0.00% device_remove_attrs
>> >          + 0.26% call_netdevice_notifiers_info
>> >          + 0.04% rtmsg_ifinfo_build_skb
>> >          + 0.01% rtmsg_ifinfo_send
>> >         0.00% dev_uc_flush
>> >         0.00% netif_reset_xps_queues_gt
>> >
>> > Someone can listen these uevents, so we can't stop sending them without
>> > breaking backward compatibility. We can try to optimize
>> > kobject_uevent...
>> 
>> Oh that is a surprise.  We can definitely skip genenerating uevents for
>> network namespaces that are exiting because by definition no one can see
>> those network namespaces.  If a socket existed that could see those
>> uevents it would hold a reference to the network namespace and as such
>> the network namespace could not exit.
>> 
>> That sounds like it is worth investigating a little more deeply.
>> 
>> I am surprised that allocation and freeing is so heavy we are spending
>> lots of time doing that.  On the other hand kobj_bcast_filter is very
>> dumb and very late so I expect something can be moved earlier and make
>> that code cheaper with the tiniest bit of work.
>> 
>
> I'm sorry, I've collected this data for a kernel with debug options
> (DEBUG_SPINLOCK, PROVE_LOCKING, DEBUG_LIST, etc). If a kernel is
> compiled without debug options, kobject_uevent becomes less expensive,
> but still expensive.
>
> -   98.64%     0.00%  kworker/u4:2  [kernel.kallsyms]    [k] cleanup_net
>    - cleanup_net
>       - 98.54% ops_exit_list.isra.4
>          - 60.48% default_device_exit_batch
>             - 60.40% unregister_netdevice_many
>                - rollback_registered_many
>                   - 59.82% netdev_unregister_kobject
>                      - 20.10% device_del
>                         + 19.44% kobject_uevent
>                         + 0.40% device_remove_attrs
>                         + 0.17% dpm_sysfs_remove
>                         + 0.04% device_remove_class_symlinks
>                         + 0.04% kobject_del
>                         + 0.01% device_pm_remove
>                         + 0.01% sysfs_remove_file_ns
>                      - 19.89% netdev_queue_update_kobjects
>                         + 19.81% kobject_put
>                         + 0.07% sysfs_remove_group
>                      - 19.79% net_rx_queue_update_kobjects
>                           kobject_put
>                         - kobject_release
>                            + 19.77% kobject_uevent
>                            + 0.02% kobject_del
>                              0.01% rx_queue_release
>                      + 0.02% kset_unregister
>                        0.01% pm_runtime_set_memalloc_noio
>                        0.01% bus_remove_device
>                   + 0.45% call_netdevice_notifiers_info
>                   + 0.07% rtmsg_ifinfo_build_skb
>                   + 0.04% rtmsg_ifinfo_send
>                     0.01% kset_unregister
>             + 0.07% rtnl_unlock
>          + 19.27% rpcsec_gss_exit_net
>          + 5.45% tcp_net_metrics_exit
>          + 5.31% sunrpc_exit_net
>          + 3.18% ip6addrlbl_net_exit 
>
>
> So after removing kobject_uevent, cleanup_net becomes more than two times faster:
>
> 1000 namespaces are cleaned up for 2.8 seconds with uevents, and 1.2 senconds
> without uevents. I do this experiments with max_cpus=1 to exclude synchronize_rcu.
>
> As a summary we can skip generating uevents, but it doesn't solve the original
> problem. If we want to avoid the limit introduced in this patch, we have
> to reduce the time for destroing net namespace in dozen times, don't
> we?

It definitely looks like optimizing kobject_uevent for this case is
worth while.

I would not mind getting the raw cost of network namespace cleanups
below 2.8ms or with uevent cleanups 1.2ms.  There is just a lot going on
for a lot of good reasons in the networking stack so that can be tricky.

The larger issue is that there is a trade off between latency and
throughput in network namespace destruction.  Consider the case of
vsftpd.  Which creates a new network namespace for every connection.
Something like that can wind up with a huge backlog of network
namespaces to clean up while continually creating more.  The system will
go OOM if we don't stop and cleanup what we have.

And the batching is very very important for throughput.  So the smallest
batch size we could really accept is a batch size that does not hurt
throughput when destroying network namespaces.  Otherwise we will have a
growing backlog of network namespaces to cleanup and a system that
eventuallys stops being usable at all.  In that context I think a long
hold time on net_mutex is preferable to a system that does not work at
all.

Now I would love to make both the throughput and the latency better I
would be all in favor of that, but that requires some deep changes to
the network namespace initialization and cleanup.  Unfortunately I
haven't stared at the problem enough to know what those changes would
need to be.  But something where we would not need to serialize network
namespace cleanup between different network namespaces.  And ideally
something we could implement incrementally as there is so much
networking code I don't expect we could verify and change verything
overnight.

That plus in practice the bottleneck has always been the synchronize_rcu
calls which tend to take at least a millisecond a piece.  Being able
overlap those synchronize_rcu calls in the common case has reduced
the time to run the network stack cleanup code by very dramatic amounts.

Right now I am very happy that the network namespace cleanup code is
working properly.  When I started the network stack cleanup code to
cleanup network namespaces I found actual functional bugs.  I will be
even happier if we can figure out how to make it all run fast.

But ultimately we have the net_mutex and the rtnl_lock that serialize
things on the setup and cleanup paths and to allow creation to proceed
while cleanup is ongoing we need to find a way to avoid serialization by
either of those, and I have honestly drawn a blank.

So right now my best suggestion for making things better is to find and
fix each little piece we can fix.  Until the things are working as best
we can make them work.  It is not sexy or glamorous or fast but it makes
things better and is the best that I can see to do.

Eric


> Here is a perf report after skipping generating uevents:
> -   93.27%     0.00%  kworker/u4:1  [kernel.kallsyms]   [k] cleanup_net
>    - cleanup_net
>       - 92.97% ops_exit_list.isra.4
>          - 35.14% rpcsec_gss_exit_net
>             - gss_svc_shutdown_net
>                - 17.40% rsc_cache_destroy_net
>                   + 8.64% cache_unregister_net
>                   + 8.52% cache_purge
>                   + 0.22% cache_destroy_net
>                + 9.00% cache_unregister_net
>                + 8.49% cache_purge
>                + 0.15% destroy_use_gss_proxy_proc_entry
>                + 0.10% cache_destroy_net
>          - 14.35% tcp_net_metrics_exit
>             - 7.32% tcp_metrics_flush_all
>                + 4.86% _raw_spin_unlock_bh
>                  0.59% __local_bh_enable_ip
>               6.12% _raw_spin_lock_bh
>               0.90% _raw_spin_unlock_bh
>          - 13.08% sunrpc_exit_net
>             - 6.91% ip_map_cache_destroy
>                + 3.90% cache_unregister_net
>                + 2.86% cache_purge
>                + 0.15% cache_destroy_net
>             + 5.95% unix_gid_cache_destroy
>             + 0.12% rpc_pipefs_exit_net
>             + 0.10% rpc_proc_exit
>          - 7.35% ip6addrlbl_net_exit
>             + call_rcu_sched
>          + 3.34% xfrm_net_exit
>          + 1.22% ipv6_frags_exit_net
>          + 1.17% ipv4_frags_exit_net
>          + 0.78% fib_net_exit
>          + 0.76% inet6_net_exit
>          + 0.76% devinet_exit_net
>          + 0.68% addrconf_exit_net
>          + 0.63% igmp6_net_exit
>          + 0.59% ipv4_mib_exit_net
>          + 0.59% uevent_net_exit  
>
>> Eric
