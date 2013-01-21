From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Sun, 20 Jan 2013 20:50:59 -0500
Message-ID: <50FC9F03.5000102@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com> <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com> <50FC307A.5090003@redhat.com> <20130120113825.759b4a58@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com,
	shmulik.ladkani@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528Ab3AUBvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2013 20:51:07 -0500
In-Reply-To: <20130120113825.759b4a58@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2013 02:38 PM, Stephen Hemminger wrote:
> On Sun, 20 Jan 2013 12:59:22 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> On 01/17/2013 08:57 PM, Micha=B3 Miros=B3aw wrote:
>>> 2013/1/16 Vlad Yasevich <vyasevic@redhat.com>:
>>> [...]
>>>> --- /dev/null
>>>> +++ b/net/bridge/br_vlan.c
>>> [...]
>>>> +struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *=
v, u16 vid)
>>>> +{
>>>> +       struct net_port_vlan *pve;
>>>> +
>>>> +       /* Must be done either in rcu critical section or with RTN=
L held */
>>>> +       WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
>>>> +
>>>> +       list_for_each_entry_rcu(pve, &v->vlan_list, list) {
>>>> +               if (pve->vid =3D=3D vid)
>>>> +                       return pve;
>>>> +       }
>>>> +
>>>> +       return NULL;
>>>> +}
>>>
>>> This looks expensive - it's O(n) with n =3D number of configured VL=
ANs on a port.
>>> And this is called for every packet. The bridge already has a hash =
of VLAN
>>> structures found by br_vlan_find(). You could add a second bitmap t=
here
>>> (eg. ingres_ports[]) and check port's bit instead of walking the li=
st.
>>> You would use a bit more memory (64 bytes minus the removed list-he=
ad)
>>> per configured VLAN but save some cycles in hot path.
>>>
>>
>> Technically wouldn't even need another bitmap as an existing members=
hip
>> bitmap would cover this case.  I did some profiling and the list is
>> faster for 3 vlans per port.  Hash is faster for more then 3 vlans.
>>
>> I can easily switch to hash if that is what others think.
>>
>> -vlad
>
> Let's assume the people that really want this feature are using a lot
> of vlan's. i.e n =3D 1000 or so. A bitmap is O(1). Any hash list woul=
d
> incur a just a big memory penalty for the list head. In other words
> a full bitmap is 4096 bits =3D 512 bytes.  If you use hash list,
> then the equivalent memory size would be only 64 list heads, therefor=
e
> a bitmap is a better choice than a hlist.
>
>

This was the approach taken in the RFC v1 of this series.  What I found=
=20
was that while it worked very well as far as speed goes, it was a bit=20
cumbersome to extend it to support pvids and it would completely fall
on its face for egress policy that Shmulik is suggesting.  So any kinds=
=20
of extensions to it were tough to do.

This is why I went with the list.  Interestingly enough, VLAN=20
implementation in the kernel is a list and noone is complaining that it=
=20
is really slow on the fast path.

-vlad
