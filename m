From: "George B." <georgeb@gmail.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 14:06:21 -0700
Message-ID: <AANLkTimhlsqL5IVc4OwrmNITdU_VSNpxhBQHpAf-EfMl@mail.gmail.com>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
	 <1274040928.2299.17.camel@edumazet-laptop> <4BF056F0.8010008@ans.pl>
	 <1274042826.2299.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Krzysztof_Ol=EAdzki?= <ole@ans.pl>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33024 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab0EPVGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 17:06:23 -0400
Received: by fxm6 with SMTP id 6so3167079fxm.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 14:06:21 -0700 (PDT)
In-Reply-To: <1274042826.2299.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/5/16 Eric Dumazet <eric.dumazet@gmail.com>:
> Le dimanche 16 mai 2010 =C3=A0 22:34 +0200, Krzysztof Ol=C4=99dzki a =
=C3=A9crit :
>> On 2010-05-16 22:15, Eric Dumazet wrote:
>
>> > All tx packets through bonding will use txqueue 0, since bnx2 does=
nt
>> > provide a ndo_select_queue() function.
>>
>> OK, that explains everything. Thank you Eric. I assume it may take s=
ome
>> time for bonding to become multiqueue aware and/or bnx2x to provide
>> ndo_select_queue?
>>
>
> bonding might become multiqueue aware, there are several patches
> floating around.
>
> But with your ping tests, it wont change the selected txqueue anyway =
(it
> will be the same for any targets, because skb_tx_hash() wont hash the
> destination address, only the skb->protocol.
>
>> BTW: With a normal router workload, should I expect big performance =
drop
>> when receiving and forwarding the same packet using different CPUs?
>> Bonding provides very important functionality, I'm not able to drop =
it. :(
>>
>
> Not sure what you mean by forwarding same packet using different CPUs=
=2E
> You probably meant different queues, because in normal case, only one
> cpu is involved (the one receiving the packet is also the one
> transmitting it, unless you have congestion or trafic shaping)
>
> If you have 4 cpus, you can use following patch and have a transparen=
t
> bonding against multiqueue. Still bonding xmit path hits a global
> rwlock, so performance is not what you can get without bonding.
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 5e12462..2c257f7 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *na=
me)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_lock();
>
> - =C2=A0 =C2=A0 =C2=A0 bond_dev =3D alloc_netdev(sizeof(struct bondin=
g), name ? name : "",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bond_setup);
> + =C2=A0 =C2=A0 =C2=A0 bond_dev =3D alloc_netdev_mq(sizeof(struct bon=
ding), name ? name : "",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bond_setup, 4);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!bond_dev) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: ee=
k! can't alloc netdev!\n", name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rtnl_unlock();
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>

=46WIW, I will be comparing VLANs on bonded ethernet interfaces compare=
d
to bonded to vlan interfaces (create a vlan on two interfaces and bond
them together) later this week to see if I can notice any performance
difference. I am expecting I will when two or more vlans are
experiencing heavy traffic.  What concerns me is if one ethernet goes
away, will the bond interface see the ethernet underlying the vlan
interface has gone down?

So in summary, rather than bonding ethernet interfaces and then
applying vlans to the bond, I intend to create vlans on the ethernet
interfaces and bond them. So one bond interface per vlan plus one for
the "raw" interfaces.  I am hoping that will allow better throughput
with multiple processors (and less head-of-line blocking for vlans
with low traffic rates).  Note: that configuration doesn't work with
2.6.32, I haven't tried with 2.6.33, and it allows me to configure it
with 2.6.34-rc7 though I haven't tested it yet on a multiqueue
ethernet with multiple processors.  I should have some systems to test
with later this week.
