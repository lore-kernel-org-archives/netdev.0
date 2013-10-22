From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Tue, 22 Oct 2013 09:34:44 +0200
Message-ID: <52662A94.9000501@6wind.com>
References: <524AB26B.1070700@6wind.com> <1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com> <20131001.125923.700243113980583930.davem@davemloft.net> <524BC816.1000702@6wind.com> <CA+FuTScA26dW8bO5YdKTKp9tjSM-xVqkdkq8xzu-wH0cT=Wh8Q@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, pshelar@nicira.com,
	gregkh@linuxfoundation.org, stable@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CA+FuTScA26dW8bO5YdKTKp9tjSM-xVqkdkq8xzu-wH0cT=Wh8Q@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 22/10/2013 01:30, Willem de Bruijn a =E9crit :
> On Wed, Oct 2, 2013 at 3:15 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Le 01/10/2013 18:59, David Miller a =E9crit :
>>
>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Date: Tue,  1 Oct 2013 18:04:59 +0200
>>>
>>>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel =
param
>>>> via
>>>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>>>
>>>> Now that it is done, we must remove the explicit call to
>>>> unregister_netdevice_queue(), because  the fallback tunnel is adde=
d to
>>>> the queue
>>>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdev=
ices
>>>> (this
>>>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns")=
).
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>>
>>> Applied and queued up for -stable.
>>>
>>> But I imagine since the x-netns changes aren't in various -stable
>>> branches this will need to be adjusted a bit?
>>
>> Yes, it's what I've tried to say in the commit log ;-)
>>
>> In fact, before the x-netns changes, we must keep the
>> unregister_netdevice_queue() line.
>
> In 3.11 linux-stable, this patch was merged between 3.11.4 and 3.11.5
> in commit 3783100, after the x-netns changes in commit 5e6700b3bf, bu=
t
> the unregister_netdevice_queue was kept.
>
> I think that caused the following bug. In 3.11.6, a simple `modprobe
> sit && rmmod sit` hits the BUG at net/core/dev.c:5039:
>
>    BUG_ON(dev->reg_state !=3D NETREG_REGISTERED);
>
> The device is actually NETREG_RELEASED at one point because the devic=
e
> is now unregistered twice. The issue goes away by porting the
> remainder of the original commit: the one liner that removes the call
> to unregister_netdevice_queue.
>
> +++ b/net/ipv6/sit.c
> @@ -1708,7 +1708,6 @@ static void __net_exit sit_exit_net(struct net =
*net)
>
>          sit_destroy_tunnels(sitn, &list);
> -       unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
>          unregister_netdevice_many(&list);
>
> If correct, let me know if I should send a proper one-line patch
> against 3.11.y. Since I haven't looked at this code before, I found i=
t
> safer to report the issue first.
Yes, this line should be removed, like it was done in the original patc=
h
(x-netns for sit is part of 3.11).

>
> 5e6700b3bf was not applied to 3.10 stable, so that branch is not affe=
cted.
Right.
