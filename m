From: Wengang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 30 Dec 2014 11:01:42 +0800
Message-ID: <54A21596.7000706@oracle.com>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com> <CAHA+R7M-Nm_R-AaKQ0nX4L3O=BN5_m1v-8sWJSaE_UmGyo8zwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHA+R7M-Nm_R-AaKQ0nX4L3O=BN5_m1v-8sWJSaE_UmGyo8zwA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8830=E6=97=A5 05:32, Cong Wang =E5=86=99=
=E9=81=93:
> On Mon, Nov 24, 2014 at 9:36 PM, Wengang Wang <wen.gang.wang@oracle.c=
om> wrote:
>> When last slave of a bonding master is removed, the bonding then doe=
s not work.
>> At the time if packet_snd is called against with a master net_device=
, it calls
>> then header_ops->create which points to slave's header_ops. In case =
the slave
>> is ipoib and the module is unloaded, header_ops would point to inval=
id address.
>> Accessing it will cause problem.
>> This patch tries to fix this issue by moving ipoib_header_ops to vml=
inux to keep
>> it valid even when ipoib module is unloaded.
>>
> I still don't think this is the right way to fix the bug, because
> there are other modules which have the same bug, for example,
> net/bluetooth/6lowpan.c (unless it can't be enslaved into a bond
> of course, I haven't verified). We don't want to move them all
> to builtin kernel, do we?

I don't think bluetooth needs bonding(and you didn't verify at all).
Do you have strong reason(examples)?

> On the other hand, as Jay explained, bonding is probably
> the only one which has the problem, why not solve it in bonding?
> I mean why do we have to adjust other modules just for bonding?

There are more than one way we do things. For this case, considering
needs, complexity and stability I think moving ipoib_header_ops is the
right way to go.

> When its slave device gets removed, some netdev event is sent
> to the master, so why not reset the header_ops to ether header ops
> up on this event? Something like below (not even compile tested):
>
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 184c434..aedccae 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1726,6 +1726,7 @@ static int __bond_release_one(struct net_device=
 *bond_dev,
>          if (!bond_has_slaves(bond)) {
>                  bond_set_carrier(bond);
>                  eth_hw_addr_random(bond_dev);
> +               ether_setup(bond_dev);
>          }
>
>          unblock_netpoll_tx();
>
> It should solve more than just your ipoib case.
Do you think it's safe in a race condition? Before you change=20
header_ops, you have no
way to prevent another thread from accessing the old one.

> Last but not least, since you said you saw the crash in packet_snd(),
> it would also be interesting to know why packet_snd() still picks thi=
s
> bond dev after all its slaves are gone, after all it is not a functio=
nal
> device without any slave (its carrier is off).

It's quite normal in a race situation.

thanks,
wengang
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
