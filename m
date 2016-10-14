From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: limit a number of namespaces which can be cleaned up concurrently
Date: Thu, 13 Oct 2016 22:06:28 -0500
Message-ID: <87k2db39zf.fsf@x220.int.ebiederm.org>
References: <1476293579-28582-1-git-send-email-avagin@openvz.org>
        <871szk9rl9.fsf@x220.int.ebiederm.org>
        <20161013204405.GA19836@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Andrei Vagin <avagin@openvz.org>, <netdev@vger.kernel.org>,
        <containers@lists.linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>
To: Andrei Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39712 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbcJNDIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 23:08:31 -0400
In-Reply-To: <20161013204405.GA19836@outlook.office365.com> (Andrei Vagin's
        message of "Thu, 13 Oct 2016 13:44:06 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrei Vagin <avagin@virtuozzo.com> writes:

> On Thu, Oct 13, 2016 at 10:49:38AM -0500, Eric W. Biederman wrote:
>> Andrei Vagin <avagin@openvz.org> writes:
>> 
>> > From: Andrey Vagin <avagin@openvz.org>
>> >
>> > The operation of destroying netns is heavy and it is executed under
>> > net_mutex. If many namespaces are destroyed concurrently, net_mutex can
>> > be locked for a long time. It is impossible to create a new netns during
>> > this period of time.
>> 
>> This may be the right approach or at least the right approach to bound
>> net_mutex hold times but I have to take exception to calling network
>> namespace cleanup heavy.
>> 
>> The only particularly time consuming operation I have ever found are calls to
>> synchronize_rcu/sycrhonize_sched/synchronize_net.
>
> I booted the kernel with maxcpus=1, in this case these functions work
> very fast and the problem is there any way.
>
> Accoding to perf, we spend a lot of time in kobject_uevent:
>
> -   99.96%     0.00%  kworker/u4:1     [kernel.kallsyms]  [k] unregister_netdevice_many                                                                      ▒
>    - unregister_netdevice_many                                                                                                                               ◆
>       - 99.95% rollback_registered_many                                                                                                                      ▒
>          - 99.64% netdev_unregister_kobject                                                                                                                  ▒
>             - 33.43% netdev_queue_update_kobjects                                                                                                            ▒
>                - 33.40% kobject_put                                                                                                                          ▒
>                   - kobject_release                                                                                                                          ▒
>                      + 33.37% kobject_uevent                                                                                                                 ▒
>                      + 0.03% kobject_del                                                                                                                     ▒
>                + 0.03% sysfs_remove_group                                                                                                                    ▒
>             - 33.13% net_rx_queue_update_kobjects                                                                                                            ▒
>                - kobject_put                                                                                                                                 ▒
>                - kobject_release                                                                                                                             ▒
>                   + 33.11% kobject_uevent                                                                                                                    ▒
>                   + 0.01% kobject_del                                                                                                                        ▒
>                     0.00% rx_queue_release                                                                                                                   ▒
>             - 33.08% device_del                                                                                                                              ▒
>                + 32.75% kobject_uevent                                                                                                                       ▒
>                + 0.17% device_remove_attrs                                                                                                                   ▒
>                + 0.07% dpm_sysfs_remove                                                                                                                      ▒
>                + 0.04% device_remove_class_symlinks                                                                                                          ▒
>                + 0.01% kobject_del                                                                                                                           ▒
>                + 0.01% device_pm_remove                                                                                                                      ▒
>                + 0.01% sysfs_remove_file_ns                                                                                                                  ▒
>                + 0.00% klist_del                                                                                                                             ▒
>                + 0.00% driver_deferred_probe_del                                                                                                             ▒
>                  0.00% cleanup_glue_dir.isra.14.part.15                                                                                                      ▒
>                  0.00% to_acpi_device_node                                                                                                                   ▒
>                  0.00% sysfs_remove_group                                                                                                                    ▒
>               0.00% klist_del                                                                                                                                ▒
>               0.00% device_remove_attrs                                                                                                                      ▒
>          + 0.26% call_netdevice_notifiers_info                                                                                                               ▒
>          + 0.04% rtmsg_ifinfo_build_skb                                                                                                                      ▒
>          + 0.01% rtmsg_ifinfo_send                                                                                                                           ▒
>         0.00% dev_uc_flush                                                                                                                                   ▒
>         0.00% netif_reset_xps_queues_gt
>
> Someone can listen these uevents, so we can't stop sending them without
> breaking backward compatibility. We can try to optimize
> kobject_uevent...

Oh that is a surprise.  We can definitely skip genenerating uevents for
network namespaces that are exiting because by definition no one can see
those network namespaces.  If a socket existed that could see those
uevents it would hold a reference to the network namespace and as such
the network namespace could not exit.

That sounds like it is worth investigating a little more deeply.

I am surprised that allocation and freeing is so heavy we are spending
lots of time doing that.  On the other hand kobj_bcast_filter is very
dumb and very late so I expect something can be moved earlier and make
that code cheaper with the tiniest bit of work.

Eric
