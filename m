From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: VXLAN RCU error
Date: Thu, 23 Feb 2017 15:46:57 -0800
Message-ID: <CAOrHB_C3edy09ayKx891xoJgz=XNWu2A0NE5Jszy=QJ34H9_6A@mail.gmail.com>
References: <20170222142745.31c5f75e@cakuba.netronome.com> <20170222203031.45513e4c@cakuba.netronome.com>
 <20170223002025.2d2d3c4e@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:55283 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbdBXAA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 19:00:28 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id CCDE5535E66
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:48:02 +0100 (CET)
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 657B1A80CB
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:47:00 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id xH0ob_-8tj4a for <netdev@vger.kernel.org>;
        Fri, 24 Feb 2017 00:46:58 +0100 (CET)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 61A0FA80C0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:46:58 +0100 (CET)
Received: by mail-wm0-f54.google.com with SMTP id t18so6062803wmt.0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:46:58 -0800 (PST)
In-Reply-To: <20170223002025.2d2d3c4e@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 12:20 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Wed, 22 Feb 2017 20:30:31 -0800, Jakub Kicinski wrote:
>> On Wed, 22 Feb 2017 14:27:45 -0800, Jakub Kicinski wrote:
>> > [ 1571.067134] ===============================
>> > [ 1571.071842] [ ERR: suspicious RCU usage.  ]
>> > [ 1571.076546] 4.10.0-debug-03232-g12d656af4e3d #1 Tainted: G        W  O
>> > [ 1571.084166] -------------------------------
>> > [ 1571.088867] ../drivers/net/vxlan.c:2111 suspicious rcu_dereference_check() usage!
>> > [ 1571.097286]
>> > [ 1571.097286] other info that might help us debug this:
>> > [ 1571.097286]
>> > [ 1571.106305]
>> > [ 1571.106305] rcu_scheduler_active = 2, debug_locks = 1
>> > [ 1571.113654] 3 locks held by ping/13826:
>> > [ 1571.117968]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffffa1cd4972>] raw_sendmsg+0x14e2/0x2e40
>> > [ 1571.127758]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffffa1be9594>] ip_finish_output2+0x274/0x1390
>> > [ 1571.138135]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffffa1a9b63c>] __dev_queue_xmit+0x1ec/0x2750
>> ....
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 4e27c5b09600..8aa3e837cd6c 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2109,7 +2109,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>                                      vxlan->cfg.port_max, true);
>>
>>         if (dst->sa.sa_family == AF_INET) {
>> -               struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
>> +               struct vxlan_sock *sock4 = rcu_dereference_bh(vxlan->vn4_sock);
>>                 struct rtable *rt;
>>                 __be16 df = 0;
>>
>> @@ -2148,7 +2148,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>                                     src_port, dst_port, xnet, !udp_sum);
>>  #if IS_ENABLED(CONFIG_IPV6)
>>         } else {
>> -               struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
>> +               struct vxlan_sock *sock6 = rcu_dereference_bh(vxlan->vn6_sock);
>>
>>                 ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
>>                                         rdst ? rdst->remote_ifindex : 0, tos,
>>
>
> Ugh.  Looks like this may not work even if it makes the splat go away.
> synchronize_net() doesn't seem to wait for the _bh() flavor of RCU, so
> we need to add syncronize_rcu_bh() call before freeing the socket or do
> a normal rcu_read_lock()/unlock() on the fast path.  Any RCU experts
> want to comment? :)
>
I think both solutions would work. I prefer using rcu_read-lock in
fast path. We already execute vxlan rcv path in rcu read lock so it
would make it consistent with xmit path.

> FWIW geneve will need similar fix, I presume.

I agree.
