From: "George B." <georgeb@gmail.com>
Subject: Re: Question about vlans, bonding, etc.
Date: Thu, 13 May 2010 18:10:33 -0700
Message-ID: <AANLkTikVJqN6m5nsJsFSNHS_HbOFyt0hGr_8MHu6tWDR@mail.gmail.com>
References: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
	 <1272948506.2407.174.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:49652 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab0ENBKe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:10:34 -0400
Received: by pzk42 with SMTP id 42so1068224pzk.4
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 18:10:33 -0700 (PDT)
In-Reply-To: <1272948506.2407.174.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 3, 2010 at 9:48 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 03 mai 2010 =E0 17:06 -0700, George B. a =E9crit :
>> Watching the "Receive issues with bonding and vlans" thread brought =
a
>> question to mind. =A0In what order should things be done for best
>> performance?
>>
>> For example, say I have a pair of ethernet interfaces. =A0Do I slave=
 the
>> ethernet interfaces to the bond device and then make the vlans on th=
e
>> bond devices?
>> Or do I make the vlans on the ethernet devices and then bond the vla=
n
>> interfaces?
>>
>> In the first case I would have:
>>
>>
>>
>> bond0.3--| =A0 =A0 |------eth0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0
>> bond0.5--| =A0 =A0 |------eth1
>>
>> The second case would be:
>>
>> =A0 =A0 =A0 |------------------eth0.5-----|
>> =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|-------eth0.3---eth0
>> bond0 =A0bond1
>> =A0 =A0 =A0 | =A0 =A0 =A0 =A0 =A0|-------eth1.3---eth1
>> =A0 =A0 =A0 |------------------eth1.5-----|
>>
>> I am using he first method currently as it seemed more intuitive to =
me
>> at the time to bond the ethernets and then put the vlans on the bond=
s
>> but it seems life might be easier for the vlan driver if it is bound
>> directly to the hardware. =A0I am using Intel NICs (igb driver) with=
 4
>> queues per NIC.
>>
>> Would there be a performance difference expected between the two
>> configurations? =A0Can the vlan driver "see through" the bond interf=
ace
>> to the
>> hardware and take advantage of multiple queues if the hardware
>> supports it in the first configuration?
>
> Unfortunatly, first combination is not multiqueue aware yet.
>
> You'll need to patch bonding driver like this if your nics have 4
> queues :
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 85e813c..98cc3c0 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4915,8 +4915,8 @@ int bond_create(struct net *net, const char *na=
me)
>
> =A0 =A0 =A0 =A0rtnl_lock();
>
> - =A0 =A0 =A0 bond_dev =3D alloc_netdev(sizeof(struct bonding), name =
? name : "",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_se=
tup);
> + =A0 =A0 =A0 bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), na=
me ? name : "",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_se=
tup, 4);
> =A0 =A0 =A0 =A0if (!bond_dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("%s: eek! can't alloc netdev!\n=
", name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rtnl_unlock();
>
>
>

I just got around to fooling with this some.  It would seem to me that
I should be able to get better performance if I could create the vlans
on the ethernet interfaces and then bond them together.  For example,
it seems intuitive that I should be able to create vlan eth0.5 and
eth1.5 and then enslave them.  Problem is that when I try to create
vlan5 on the second interface, vconfig balks that it already exists.
Yes, I know it exists, but I want vlan5 on two interfaces and I want
to use ifenslave to bond them together into a bond interface.  So if I
have 10 vlans, I would have 10 vlans on each ethernet interface and 10
bond interfaces.  The way it seems I am forced to do it now is bond
the two NICs together and add all the vlans to the single bond
interface.  It seems that the bond interface would then become a
bottleneck for all the vlans.

Is there some physical reason why it is not possible to create the
same vlan on multiple interfaces as long as the naming convention
keeps them named separately so they can be distinguished from each
other?
