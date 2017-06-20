From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [net,v2] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Tue, 20 Jun 2017 14:37:04 +0800
Message-ID: <5948C290.6050409@rock-chips.com>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com> <59489369.8000309@rock-chips.com> <CAM_iQpWN6qFsQ_oAMXjC7k00pf0j90zxdx6hzUS58MFn29QSbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Ahern <dsahern@gmail.com>,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.132]:37268 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFTGhQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 02:37:16 -0400
In-Reply-To: <CAM_iQpWN6qFsQ_oAMXjC7k00pf0j90zxdx6hzUS58MFn29QSbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong Wang,

On 06/20/2017 12:54 PM, Cong Wang wrote:
> Hello,
>
> On Mon, Jun 19, 2017 at 8:15 PM, jeffy <jeffy.chen@rock-chips.com> wrote:
>> but actually they are not guaranteed to be paired:
>>
>> the netdev_run_todo(see the first dump stack above) would call
>> netdev_wait_allrefs to rebroadcast unregister notification multiple times,
>> unless timed out or all of the "struct net_device"'s refs released:
>>
>>   * This is called when unregistering network devices.
>>   *
>>   * Any protocol or device that holds a reference should register
>>   * for netdevice notification, and cleanup and put back the
>>   * reference if they receive an UNREGISTER event.
>>   * We can get stuck here if buggy protocols don't correctly
>>   * call dev_put.
>>   */
>> static void netdev_wait_allrefs(struct net_device *dev)
>> {
>> ...
>>          while (refcnt != 0) {
>>                  if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
>>                          rtnl_lock();
>>
>>                          /* Rebroadcast unregister notification */
>>                          call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>>
>>                          __rtnl_unlock();
>>                          rcu_barrier();
>>                          rtnl_lock();
>>
>>
>> call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
>
> Interesting, I didn't notice this corner-case, because normally
> we would hit the one in rollback_registered_many(). Probably
> we need to add a check
>
> if (dev->reg_state == NETREG_UNREGISTERING)
>
> in ip6_route_dev_notify(). Can you give it a try?
the NETREG_UNREGISTERING check works for my test:)

but i saw dev_change_net_namespace also call NETDEV_UNREGISTER & 
NETDEV_REGISTER:

int dev_change_net_namespace(struct net_device *dev, struct net *net, 
const char *pat)
{
...
         /* Don't allow namespace local devices to be moved. */
         err = -EINVAL;
         if (dev->features & NETIF_F_NETNS_LOCAL)
                 goto out;

         /* Ensure the device has been registrered */
         if (dev->reg_state != NETREG_REGISTERED)
                 goto out;
...
         /* Notify protocols, that we are about to destroy
          * this device. They should clean all the things.
          *
          * Note that dev->reg_state stays at NETREG_REGISTERED.
          * This is wanted because this way 8021q and macvlan know
          * the device is just moving and can keep their slaves up.
          */
         call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
...
         /* Notify protocols, that a new device appeared. */
         call_netdevice_notifiers(NETDEV_REGISTER, dev);


maybe we should also add a check for NETDEV_REGISTER event? maybe:
         if (dev->reg_state != NETREG_REGISTERED)


>
> I guess we probably need to revise other NETDEV_UNREGISTER
> handlers too.
>
> I will send a patch tomorrow.
sounds great~
>
> Thanks!
>
>
>
