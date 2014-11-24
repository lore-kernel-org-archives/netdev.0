From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Mon, 24 Nov 2014 11:05:39 +0800
Message-ID: <5472A083.9020801@oracle.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com> <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com> <546C4022.5010509@oracle.com> <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com> <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com> <1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com> <1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com> <23563.1416523985@famine> <CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com> <29850.1416596051@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26054 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaKXDEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 22:04:21 -0500
In-Reply-To: <29850.1416596051@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B411=E6=9C=8822=E6=97=A5 02:54, Jay Vosburgh =E5=86=
=99=E9=81=93:
> Cong Wang <cwang@twopensource.com> wrote:
>
>> On Thu, Nov 20, 2014 at 2:53 PM, Jay Vosburgh
>> <jay.vosburgh@canonical.com> wrote:
>>> Cong Wang <cwang@twopensource.com> wrote:
>>>
>>>> Also, no one seems to care about my previous question:
>>>> why only bonding has the problem?
>>>          Bonding has the problem because it stashes a pointer to a =
data
>>> structure (the header_ops) from another module, and when that modul=
e is
>>> unloaded the dangling pointer may be dereferenced if it's not eithe=
r
>>> cleared or made to never go away.
>> I knew, please re-read my question, I was asking why ONLY bonding
>> has the problem, i.e. why not neigh or whatever else calling
>> header_ops->foo()? :)
>>
>> As I said, I may miss some try_get_module() somewhere of course.
>> Needs more digging.
> 	My explanation is why only bonding has the problem; it's keeping
> a pointer (in bond_dev->header_ops) that is copied from the slave
> device's ->header_ops, and clearing that stashed pointer is (a) not
> correctly synchronized with the removal of the slave device, and (b)
> trying to simply clear the pointer has a check then use race in
> dev_hard_header.
>
> 	8021q, for example, uses a "passthru" header_ops to call the
> underlying device's header_ops, but 8021q is only for ethernet, and t=
he
> eth_header_ops are static in vmlinux, so it won't see these problems.
>
> 	Actually, now that I think about it, when the last ipoib slave
> is released, the bonding master device is theoretically supposed to b=
e
> removed to avoid the sort of problem we're discussing here.
>
> 	That apparently isn't happening, unless Wengang is running
> pktgen and simultaneously removing the ipoib module (racing the trans=
mit
> against the removal), or maybe something else is going on (perhaps
> pktgen holds a reference to the bonding master, preventing its remova=
l).
>
> 	Also, curiously, looking at pkgten, pktgen_setup_dev appears to
> only accept devices of type ARPHRD_ETHER, but bonding with an ipoib
> slave would be ARPHRD_INFINIBAND.  I'm therefore not sure how Wengang
> configured pktgen over an ipoib bond.
>
> 	Wengang, what kernel are you using, and is your kernel modified
> to change pktgen_setup_dev?
>
> 	-J

It's a 2.6.39 kernel.
code is like this:

static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifn=
ame)
{
         struct net_device *odev;
         int err;

         /* Clean old setups */
         if (pkt_dev->odev) {
                 dev_put(pkt_dev->odev);
                 pkt_dev->odev =3D NULL;
         }

         odev =3D pktgen_dev_get_by_name(pkt_dev, ifname);
         if (!odev) {
                 pr_err("no such netdevice: \"%s\"\n", ifname);
                 return -ENODEV;
         }

         if (odev->type !=3D ARPHRD_ETHER) {
                 pr_err("not an ethernet device: \"%s\"\n", ifname);
                 err =3D -EINVAL;
         } else if (!netif_running(odev)) {
                 pr_err("device is down: \"%s\"\n", ifname);
                 err =3D -ENETDOWN;
         } else {
                 pkt_dev->odev =3D odev;
                 return 0;
         }

         dev_put(odev);
         return err;
}

No change done to it.

This problem is a side product when I was working with another area. I=20
am so far not very clear about the setup(no env to check now either).

thanks,
wengang
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
