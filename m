From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Thu, 4 May 2017 10:21:44 -0700
Message-ID: <CAM_iQpU9ys7DuHwz7Ms3HUk9=U+x1exOwjiUeVCOOxSOqO_Caw@mail.gmail.com>
References: <1493874452-3050-2-git-send-email-xiyou.wangcong@gmail.com> <a127b7fe-82a7-53e9-8df4-704f1b295ada@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35668 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755757AbdEDRWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:22:07 -0400
Received: by mail-wm0-f65.google.com with SMTP id d79so4810735wmi.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 10:22:06 -0700 (PDT)
In-Reply-To: <a127b7fe-82a7-53e9-8df4-704f1b295ada@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 4, 2017 at 7:04 AM, David Ahern <dsahern@gmail.com> wrote:
> On 5/3/17 11:07 PM, Cong Wang wrote:
>> For each netns (except init_net), we initialize its null entry
>> in 3 places:
>>
>> 1) The template itself, as we use kmemdup()
>> 2) Code around dst_init_metrics() in ip6_route_net_init()
>> 3) ip6_route_dev_notify(), which is supposed to initialize it after
>> loopback registers
>>
>> Unfortunately the last one still happens in a wrong order because
>> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
>> net->loopback_dev's idev, so we have to do that after we add
>> idev to it. However, this notifier has priority == 0 same as
>> ipv6_dev_notf, and ipv6_dev_notf is registered after
>> ip6_route_dev_notifier so it is called actually after
>> ip6_route_dev_notifier.
>>
>> Fix it by specifying a smaller priority for ip6_route_dev_notifier.
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/route.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 2f11366..4dbf7e2 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -4024,7 +4024,7 @@ static struct pernet_operations ip6_route_net_late_ops = {
>>
>>  static struct notifier_block ip6_route_dev_notifier = {
>>       .notifier_call = ip6_route_dev_notify,
>> -     .priority = 0,
>> +     .priority = -10, /* Must be called after addrconf_notify!! */
>>  };
>>
>>  void __init ip6_route_init_special_entries(void)
>>
>
> And I see a refcnt problem with this change:
>
> root@kenny-jessie2:~# unshare -n
> root@kenny-jessie2:~# logout
> root@kenny-jessie2:~# unshare -n
>
> Message from syslogd@kenny-jessie2 at May  4 07:04:38 ...
>  kernel:[   62.581552] unregister_netdevice: waiting for lo to become
> free. Usage count = 1

Ah, looks like we need to put the refcnt for UNREGISTER too.

Will send v2 to include your ADDRCONF_NOTIFY_PRIORITY suggestion.
