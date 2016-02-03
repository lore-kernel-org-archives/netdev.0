From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next 2/4] net: dev: add batching to net_device notifiers
Date: Tue, 2 Feb 2016 22:31:06 -0800
Message-ID: <CAO7SqHBKrPvaEhLeEJsCrjYEiPcZ6MpyfwY43NwhGLWhW4VTNQ@mail.gmail.com>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com>
	<1454365952-10324-3-git-send-email-noureddine@arista.com>
	<alpine.LFD.2.11.1602022219010.2006@ja.home.ssi.bg>
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
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37699 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbcBCGbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 01:31:08 -0500
Received: by mail-wm0-f48.google.com with SMTP id l66so54767370wml.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 22:31:07 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1602022219010.2006@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 12:55 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 1 Feb 2016, Salam Noureddine wrote:
>
>> @@ -1572,8 +1582,12 @@ rollback:

>>                       call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>> +                     call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
>> +                                             dev);
>
>                         If the rule is once per net, the above call...
>
>>               }
>
>                 should be here:
>
>                 call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
>                                         net->loopback_dev);
>
>         and also once after outroll label?:

That's a good optimization to add. I was mostly focusing on the device
unregister path.

>
>         call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH, last);
>
>>       }
>>
>> @@ -1614,8 +1628,12 @@ int unregister_netdevice_notifier(struct notifier_block *nb)

>>                       call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>> +                     call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
>> +                                             dev);
>
>                         Above call...
>
>>               }
>
>                 should be here, for net->loopback_dev?
> Also, is it ok to call NETDEV_DOWN_BATCH many times, as result,
> sometimes after NETDEV_UNREGISTER?

Same here, I can add this optimization. I think it is fine to call the
BATCH notifiers
for every interface. It is just better to do it for many interfaces at
the same time.


>> +     list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
>> +             call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
>> +                                      net->loopback_dev);
>> +             net_del_event_list(net);
>> +     }
>> +
>
>         NETDEV_UNREGISTER* should not be called before
> following synchronize_net and NETDEV_UNREGISTER. May be
> we should split the loop: loop (dev_shutdown+NETDEV_UNREGISTER)
> followed by above NETDEV_UNREGISTER_BATCH then again the
> loop for all remaining calls
>
>>       synchronize_net();
>>
>>       list_for_each_entry(dev, head, unreg_list)
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

The call to NETDEV_UNREGISTER_BATCH is actually after NETDEV_UNREGISTER,
it seems the other way around in the patch because it is showing part
of netdev_wait_allrefs
and not rollback_registered_may.

Thanks,

Salam
