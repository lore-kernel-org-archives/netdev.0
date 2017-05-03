From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: GPF in rt6_device_match
Date: Wed, 3 May 2017 16:35:54 -0700
Message-ID: <CAM_iQpVbcOL3BD6SkVAOFLVCX5q_OpO0vfYnwG6XE4vdJkiw5Q@mail.gmail.com>
References: <CAAeHK+yfX9ZtpFMTFXKAtjYE17MDBXMQJS_mH0b3=xTuv3jk9g@mail.gmail.com>
 <CAM_iQpUtVZiKTxnUBYEPLQzJSK+G_=Be-uzwuqph6g2VPsZijw@mail.gmail.com>
 <4ef76406-8e05-ccdf-fefb-dc47d56c71c9@gmail.com> <CAM_iQpVwBp=11c_SQgNxdONefHfZQiyzRwb2pOGgJVECytOzgg@mail.gmail.com>
 <dece4ab2-86b0-1649-5e34-1a9fa1240792@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33142 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdECXgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:36:16 -0400
In-Reply-To: <dece4ab2-86b0-1649-5e34-1a9fa1240792@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 3:09 PM, David Ahern <dsahern@gmail.com> wrote:
> On 5/3/17 4:02 PM, Cong Wang wrote:
>> On Wed, May 3, 2017 at 11:22 AM, David Ahern <dsahern@gmail.com> wrote:
>>> On 5/3/17 11:02 AM, Cong Wang wrote:
>>>> A quick glance shows we need to simply check local->rt6i_idev
>>>> since we do the same check for sprt right above.
>>>
>>> As I recall, rt6i_idev is set for all routes except null_entry and it is
>>> not set on null_entry only because of initialization order.
>>
>> Are you sure?
>>
>>         if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
>>                 net->ipv6.ip6_null_entry->dst.dev = dev;
>>                 net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
>> #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>>                 net->ipv6.ip6_prohibit_entry->dst.dev = dev;
>>                 net->ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(dev);
>>                 net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
>>                 net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
>> #endif
>>         }
>>
>> Loopback is the first one to register, so null entry is set to
>> loopback dev initially. Similar for init_net.
>>
>
> Why don't you add a printk and see ;-)

Ah, we need:

@@ -4024,7 +4027,7 @@ static struct pernet_operations ip6_route_net_late_ops = {

 static struct notifier_block ip6_route_dev_notifier = {
        .notifier_call = ip6_route_dev_notify,
-       .priority = 0,
+       .priority = -10, /* Must be called after addrconf_notify!! */
 };
