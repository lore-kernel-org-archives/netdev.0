From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Mon, 21 Oct 2013 19:30:13 -0400
Message-ID: <CA+FuTScA26dW8bO5YdKTKp9tjSM-xVqkdkq8xzu-wH0cT=Wh8Q@mail.gmail.com>
References: <524AB26B.1070700@6wind.com> <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>
 <20131001.125923.700243113980583930.davem@davemloft.net> <524BC816.1000702@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, pshelar@nicira.com,
	gregkh@linuxfoundation.org, stable@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:63905 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3JUXap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 19:30:45 -0400
Received: by mail-qa0-f51.google.com with SMTP id ii20so2889043qab.3
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 16:30:44 -0700 (PDT)
In-Reply-To: <524BC816.1000702@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 2, 2013 at 3:15 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 01/10/2013 18:59, David Miller a =E9crit :
>
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Tue,  1 Oct 2013 18:04:59 +0200
>>
>>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel p=
aram
>>> via
>>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>>
>>> Now that it is done, we must remove the explicit call to
>>> unregister_netdevice_queue(), because  the fallback tunnel is added=
 to
>>> the queue
>>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdevi=
ces
>>> (this
>>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns"))=
=2E
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>>
>> Applied and queued up for -stable.
>>
>> But I imagine since the x-netns changes aren't in various -stable
>> branches this will need to be adjusted a bit?
>
> Yes, it's what I've tried to say in the commit log ;-)
>
> In fact, before the x-netns changes, we must keep the
> unregister_netdevice_queue() line.

In 3.11 linux-stable, this patch was merged between 3.11.4 and 3.11.5
in commit 3783100, after the x-netns changes in commit 5e6700b3bf, but
the unregister_netdevice_queue was kept.

I think that caused the following bug. In 3.11.6, a simple `modprobe
sit && rmmod sit` hits the BUG at net/core/dev.c:5039:

  BUG_ON(dev->reg_state !=3D NETREG_REGISTERED);

The device is actually NETREG_RELEASED at one point because the device
is now unregistered twice. The issue goes away by porting the
remainder of the original commit: the one liner that removes the call
to unregister_netdevice_queue.

+++ b/net/ipv6/sit.c
@@ -1708,7 +1708,6 @@ static void __net_exit sit_exit_net(struct net *n=
et)

        sit_destroy_tunnels(sitn, &list);
-       unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
        unregister_netdevice_many(&list);

If correct, let me know if I should send a proper one-line patch
against 3.11.y. Since I haven't looked at this code before, I found it
safer to report the issue first.

5e6700b3bf was not applied to 3.10 stable, so that branch is not affect=
ed.
