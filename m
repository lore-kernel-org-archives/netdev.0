From: Jesse Gross <jesse@nicira.com>
Subject: Re: bnx2 vlan issue
Date: Tue, 22 Mar 2011 16:19:03 -0700
Message-ID: <AANLkTi=D9Qw+Tw7wHb2T7UG_o9zkZcr2meHE3fwcMwvF@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
 <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
 <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
 <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com> <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Seblu <seblu@seblu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37682 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828Ab1CVXTY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 19:19:24 -0400
Received: by vxi39 with SMTP id 39so5985378vxi.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 16:19:23 -0700 (PDT)
In-Reply-To: <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 3:59 AM, Seblu <seblu@seblu.net> wrote:
> On Tue, Mar 22, 2011 at 3:05 AM, Jesse Gross <jesse@nicira.com> wrote=
:
>> On Thu, Mar 17, 2011 at 4:22 PM, Seblu <seblu@seblu.net> wrote:
>>> On Thu, Mar 17, 2011 at 8:16 PM, Jesse Gross <jesse@nicira.com> wro=
te:
>>>> On Thu, Mar 17, 2011 at 11:02 AM, Seblu <seblu@seblu.net> wrote:
>>>>> On Thu, Mar 17, 2011 at 3:51 PM, Seblu <seblu@seblu.net> wrote:
>>> How can I create a bridge with the untagged vlan from an interface?
>>>
>>>> * bridge on interface, vlans on bridge device. =A0This gives you a
>>>> bridge with all packets and vlan devices can give you specific vla=
ns.
>>> I cannot use this schema, i used bridge to bring together vnet
>>> interface and vlan interface.
>>
>> I'm not sure I understand why you say you can't use this. =A0You can
>> combine vlans and bridging pretty much arbitrarily, including stacki=
ng
>> multiple layers.
> I don't see _how I can bridge an interface with an untagged vlan from
> another interface_.
>
> I little example is maybe more clear:
> My dekstop have 2 NIC (eth0, eth1). I receive from network admin 2
> vlans. 20 untag and 21 tagged. My laptop is plugged to eth1.
> I want "export" untagged vlan 20 to eth1.
> Before 2.6.37, i do something like br0 =3D (eth0 + eth1). I put an ip=
 on
> br0 and on eth0.21. And br0 just have untagged frame from eth0 which
> was transmitted to eth1. eth0.21 have only tagged frame from vlan 21.
> eth1 did not receive tagged vlan 21.
> After 2.6.37, i can do a bridge like before (br0 =3D eth0 + eth1) but=
 i
> must use br0.21 to have access to vlan 21 network in my desktop. But,
> my laptop can also access to tagged vlan 21, and i don't want this.
>
> A lot of old xen based setup use this behaviour.
> About my kvm test, I'm looking to the pci passtrough and macvtap, but
> this requires configuration that supports it.
> Why cannot have a eth0.U with only untagged frames?
>
>>
>>>
>>>> * Use ebtables rules in the bridge to accept/reject certain packet=
s as desired.
>>> I don't see how use ebtables to push untagged frame to a dedicated
>>> iface which can be added in a bridge.
>>
>> You could have a bridge on the raw interface and connect all of the
>> VMs that need untagged traffic. =A0If you add an ebtables rule to re=
ject
>> tagged traffic then vlan devices on the interface will continue to
>> work as before.
>>
> If I ignores the fact that the name of the card is not fixed, i see.
> But performance will follow? I don't believe this kind of config will
> allow ~7/8Gbit/s of traffic.
> Traversing ebtables rules is not free. And starting filtering traffic
> is a really different job than just bridge cards together.

I don't necessarily disagree that there should be a better way to do
this, though as of the moment the above is probably your best bet.

To me, the most important thing is to have consistent behavior across
different cards.  In 2.6.37 that behavior was standardized on the way
non-accelerated NICs used to do but the other way is more common and
perhaps better.  Eric B. posted a patch yesterday that better unifies
the code paths.  This would be the first step to such a change because
it would make it easier to move the handling logic for both at the
same time.
