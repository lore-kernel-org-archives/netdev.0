From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 03/33] net: set name_assign_type in alloc_netdev()
Date: Thu, 10 Jul 2014 15:02:41 +0200
Message-ID: <CAG-2HqXZe26RVnWCKpCfkPmP+OOA5fnrUL-o3+258KLTHPoxOA@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-4-git-send-email-teg@jklm.no> <87tx6ph8u5.fsf@nemi.mork.no>
 <CAG-2HqVvW2dh5y8xn9v-B29ohFTcPGgY3NY-P5y_xZu0SGgG3g@mail.gmail.com> <87ha2ph2ow.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ha2ph2ow.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 1:29 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Tom Gundersen <teg@jklm.no> writes:
>> On Thu, Jul 10, 2014 at 11:16 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wr=
ote:
>>> Tom Gundersen <teg@jklm.no> writes:
>>>
>>>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
>>>> index 5dc638c..f405e05 100644
>>>> --- a/net/ethernet/eth.c
>>>> +++ b/net/ethernet/eth.c
>>>> @@ -390,7 +390,8 @@ EXPORT_SYMBOL(ether_setup);
>>>>  struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned i=
nt txqs,
>>>>                                     unsigned int rxqs)
>>>>  {
>>>> -     return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, t=
xqs, rxqs);
>>>> +     return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNO=
WN,
>>>> +                             ether_setup, txqs, rxqs);
>>>>  }
>>>>  EXPORT_SYMBOL(alloc_etherdev_mqs);
>>>
>>> I believe this chunk makes the rest of this exercise pretty pointle=
ss.
>>>
>>> bjorn@nemi:/usr/local/src/git/linux$ git grep alloc_etherdev driver=
s/net/|wc -l
>>> 283
>>>
>>> I don't care enough to go look, but I'd be surprised if none of tho=
se
>>> drivers rename the device before registering it.
>>
>> I did look for that, and I only found devices being renamed to the
>> same name assign type as eth%d (wlan%d, etc).
>
> You explain the vlan patch as follows:
>
>  "When deriving the name from the real device, inherit the assign typ=
e, otherwise
>   set PREDICTABLE as the name will be uniquely determined by the VLAN=
ID."
>
>
> How come the same doesn't apply here?:
>
> struct net_device * hostap_add_interface(struct local_info *local,
>                                          int type, int rtnl_locked,
>                                          const char *prefix,
>                                          const char *name)
> {
>         struct net_device *dev, *mdev;
>         struct hostap_interface *iface;
>         int ret;
>
>         dev =3D alloc_etherdev(sizeof(struct hostap_interface));
>         if (dev =3D=3D NULL)
>                 return NULL;
>
>         iface =3D netdev_priv(dev);
>         iface->dev =3D dev;
>         iface->local =3D local;
>         iface->type =3D type;
>         list_add(&iface->list, &local->hostap_interfaces);
>
>         mdev =3D local->dev;
>         eth_hw_addr_inherit(dev, mdev);
>         dev->base_addr =3D mdev->base_addr;
>         dev->irq =3D mdev->irq;
>         dev->mem_start =3D mdev->mem_start;
>         dev->mem_end =3D mdev->mem_end;
>
>         hostap_setup_dev(dev, local, type);
>         dev->destructor =3D free_netdev;
>
>         sprintf(dev->name, "%s%s", prefix, name);
> ..
>
> when this is called as
>
>         dev =3D hostap_add_interface(local, HOSTAP_INTERFACE_WDS, rtn=
l_locked,
>                                    local->ddev->name, "wds%d");
>
> ..
>         local->apdev =3D hostap_add_interface(local, HOSTAP_INTERFACE=
_AP,
>                                             rtnl_locked, local->ddev-=
>name,
>                                             "ap");
> ..
>         local->stadev =3D hostap_add_interface(local, HOSTAP_INTERFAC=
E_STA,
>                                              rtnl_locked, local->ddev=
->name,
>                                              "sta");
>
>
> ?
>
> Yes, this is an exception.  But so are every instance of alloc_netdev
> ending up with something different from NET_NAME_ENUM...

Indeed, I missed this case. And given I missed that one, you are
probably right there are others.

> How much would this patchset reduce to if you just set
> dev->name_assign_type =3D NET_NAME_UNKNOWN in alloc_netdev() and chan=
ged
> it only in the few places where you actually *know* the name_assign_t=
ype?

This is what David Herrmann's initial patch-set did. I do tend to
agree with David Miller that changing the alloc_netdev() API makes it
easier to review which cases we have covered, and which remain.

I agree that we should absolutely leave NET_NAME_UNKNOWN in the places
where we are not certain though.

> My fear wrt this pathset is that the 'name_assign_type' will end up a=
s
> yet another useless field like 'addr_assign_type' and 'type'. There i=
s
> no way the kernel will be able to set these with 100% confidence, and
> the value is therefore next to nothing.  If userspace is stupid enoug=
h
> to trust them, then you end up with extremely hard to fix errors in t=
he
> cases where the driver/kernel guesswork is wrong.

Well, if the kernel doesn't know, then userspace certainly does not.
So I think the best thing we can do is to expose this information as
best we can from the kernel, and make userspace follow. That said, I'm
absolutely ok with the kernel exposing "don't know", and let userspace
deal with that as best they can (which probably means it will assume
the kernel name (or hwaddr) is useless and assign its own).

> Just one example of this, affecting the 'type': Huawei happens to use
> the same device IDs for modems requiring userspace management (should
> have a wwan_type) and modems with built-in management (should have a
> default type).  So which 'type' should we choose for this device?
> userspace can figure out by careful probing, but if it trusts the 'ty=
pe'
> set by the driver then it will get it wrong. The field provides no va=
lue
> at all.

Sounds to me the kernel in this case should simply set some other type
indicating "don't know"?

> But if you limit the scope of the 'name_assign_type' patches to only
> those cases where you actually have some information, then I guess it
> might provide some value for userspace.

What I suggest to do is:

Leave NET_NAME_UNKNOWN in alloc_etherdev() (and any similar
constructs), but in the cases where we know that the final name set
before netdev_register() is some template, I'd still set this to
NET_NAME_ENUM as we do now to make it clear which cases have been
reviewed. So the patchset does not change much, but it would eliminate
any risk of false positives.

Does that sound reasonable to you?

Cheers,

Tom
