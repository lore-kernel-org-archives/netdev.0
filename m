From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH v2 net-next 2/4] net: dev: add batching to net_device notifiers
Date: Sat, 6 Feb 2016 22:25:20 -0800
Message-ID: <CAO7SqHAX7e6sXkcEmd-hAn=Sg4AdNCRS1iFN7_F=aDnidnZOvg@mail.gmail.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
	<1454628956-4803-3-git-send-email-noureddine@arista.com>
	<alpine.LFD.2.11.1602062023180.1718@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37380 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcBGGZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 01:25:22 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so77182954wme.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 22:25:21 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1602062023180.1718@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 6, 2016 at 10:58 AM, Julian Anastasov <ja@ssi.bg> wrote:

>
>         I now see that we should split the loop
> here, so that NETDEV_DOWN_BATCH is called only once per net:
>
>                 bool down = false;
>
>                 for_each_netdev(net, dev) {
>                         if (dev == last)
>                                 break;
>
>                         if (dev->flags & IFF_UP) {
>                                 call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
>                                                         dev);
>                                 call_netdevice_notifier(nb, NETDEV_DOWN, dev);
>                                 down = true;
>                         }
>                 }
>
>                 rt_cache_flush and arp_ifdown_all will be called
>                 on NETDEV_UNREGISTER_BATCH, so use 'down' flag:
>
>                 if (down)
>                         call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
>                                                 net->loopback_dev);
>                 for_each_netdev(net, dev) {
>                         if (dev == last)
>                                 goto outroll;
>                         call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>                 }
>                 call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
>                                         net->loopback_dev);
>
>
>>                       }
>>                       call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>>               }
>> +             call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
>> +                                     net->loopback_dev);
>>       }
>>
>>  outroll:
>> +     call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH, last);
>>       raw_notifier_chain_unregister(&netdev_chain, nb);
>>       goto unlock;
>>  }

I am not sure we need to worry too much about optimizing the failure
code path to justify splitting into two loops.


>>  static void rollback_registered_many(struct list_head *head)
>>  {

>>       list_for_each_entry(dev, head, unreg_list) {
>> -             struct sk_buff *skb = NULL;
>> -
>>               /* Shutdown queueing discipline. */
>>               dev_shutdown(dev);
>>
>> @@ -6475,6 +6497,20 @@ static void rollback_registered_many(struct list_head *head)
>>                  this device. They should clean all the things.
>>               */
>>               call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>> +     }
>> +
>> +     /* call batch notifiers which act on net namespaces */
>> +     list_for_each_entry(dev, head, unreg_list) {
>> +             net_add_event_list(&net_head, dev_net(dev));
>
>         Looks like we can move the above net_add_event_list with
> the comment into the previous loop after NETDEV_UNREGISTER,
> we will save some cycles.
>

I didn't move it into the previous loop because the NETDEV_UNREGISTER
notifier can
end up calling rollback_registered_many (for example the vlan driver
unregistering
all vlans on top of a device) in which case we would be using the
event_list in the net
namespace.

> Julian Anastasov <ja@ssi.bg>

Thanks,

Salam
