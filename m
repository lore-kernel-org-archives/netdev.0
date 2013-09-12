From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Thu, 12 Sep 2013 14:48:19 -0700
Message-ID: <CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:53828 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421Ab3ILVsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 17:48:19 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz11so357111veb.3
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 14:48:19 -0700 (PDT)
In-Reply-To: <87txhp249u.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 1:06 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>
>> Resending.
>
> To summarize:
>
> In netdev_run_todo, netdev_wait_allrefs, call_netdevice_notifiers you
> have observed a situation where dev_net(dev) was an invalid pointer.
>

Correct.


> My first impression is that we probably just want to remove the repeated
> call to call_netdevice_notifiers, that happens after 1 second of
> waiting.
>
> Your suggested patch below doesn't have a prayer of working, as it only
> decreases the device reference count after the loop to wait for the
> reference count to go to zero.
>

Actually it did work. In 3.4 it avoided the crash in
inetpeer_invalidate_tree and it did not cause any visible adverse
effects after running it several days on multiple servers that create
and destroy namespaces on a regular basis.
The extra refcount that is taken and released is on the loopback_dev
of the namespace that the net_device is in. The assumption is that
loopback_dev is always the last net_device to be destroyed in a
namespace. So each net_device in a namespace (except for the
loopback_dev itself) takes such reference when it is unlisted, and it
releases it after it is destroyed (after netdev_wait_allrefs).
The patch also makes sure that any loopback_devs are at the tail of
net_todo_list within every namespace in every instance of
netdev_run_todo. This guarantees that no deadlocks are introduced,
since the relative order of net_devices within each namespace is
preserved, and only non-loopback_devs take and release the extra
reference.

> Your patch modified to grab a count on the network namespace the device
> references and not the device itself might make sense, but that runs the
> risk of incrementing the network namespace counts after the network
> namespace is down.

Right.

>
> Simply not rerunning call_netdevice_notifiers seems like the proper
> approach to fix this.
>

That would be great. There would still be one scenario to take care of though:

- veth interfaces v0 and v1 are in namespaces ns0 and ns1.
- process p0 unregisters v0, which also causes v1 to be unregistered.
When p0 enters netdev_run_todo both v0 and v1 are in net_todo_list and
have been unlisted from their namespaces.
- then in p0's netdev_run_todo:

void netdev_run_todo(void)
{
        struct list_head list;

        /* Snapshot list, allow later requests */
        list_replace_init(&net_todo_list, &list);

        __rtnl_unlock();


        /* Wait for rcu callbacks to finish before next phase */
        if (!list_empty(&list))
                rcu_barrier();

********* Assume ns1 is destroyed by another process here ************

        while (!list_empty(&list)) {
                struct net_device *dev
                        = list_first_entry(&list, struct net_device, todo_list);
                list_del(&dev->todo_list);

                rtnl_lock();
                call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);

********* dst_dev_event/dst_ifdown is invoked here, and it tries to access
            dev_net(dev)->loopback_dev.
            In case of v1 this would be an invalid pointer. *****************

                __rtnl_unlock();

Similar scenarios apply if v1 is a vlan or macvlan interface, and v0
is its real device.

Francesco
