From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] ipv6: Fix finding best source address in ipv6_dev_get_saddr().
Date: Tue, 14 Jul 2015 08:22:00 -0700
Message-ID: <CALx6S37ES1XotV4-Jtd8rLCBc+45mnyMObwtVdmNg=O8RE+OAQ@mail.gmail.com>
References: <55A3CAFA.3060404@miraclelinux.com>
	<CALx6S34Bj_YtRqqL5U0zJ9RKEu_Uvp9zYyNJLgvjEqX9jNrYqA@mail.gmail.com>
	<55A50414.6090407@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Erik Kline <ek@google.com>, Hajime Tazaki <thehajime@gmail.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36083 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbGNPWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 11:22:01 -0400
Received: by igbij6 with SMTP id ij6so48882661igb.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 08:22:00 -0700 (PDT)
In-Reply-To: <55A50414.6090407@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 5:44 AM, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=
=8B=B1=E6=98=8E
<hideaki.yoshifuji@miraclelinux.com> wrote:
> Hi,
>
> Tom Herbert wrote:
>> I am testing this patch which may be a little simpler. Also idev nee=
ds
>> to be checked after __in6_dev_get
>
> We have to select source address on *given* interface for link-local/
> multicast destinations.
>
I mean check that idev is not NULL.

>>
>> Tom
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 4ab74d5..d631ac3 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1363,9 +1363,10 @@ static void __ipv6_dev_get_saddr(struct net *=
net,
>>                                  unsigned int prefs,
>>                                  const struct in6_addr *saddr,
>>                                  struct inet6_dev *idev,
>> -                                struct ipv6_saddr_score *scores)
>> +                                struct ipv6_saddr_score **in_score,
>> +                                struct ipv6_saddr_score **in_hiscor=
e)
>>  {
>> -       struct ipv6_saddr_score *score =3D &scores[0], *hiscore =3D =
&scores[1];
>> +       struct ipv6_saddr_score *score =3D *in_score, *hiscore =3D *=
in_hiscore;
>>
>>         read_lock_bh(&idev->lock);
>>         list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
>> @@ -1434,13 +1435,16 @@ static void __ipv6_dev_get_saddr(struct net =
*net,
>>         }
>>  out:
>>         read_unlock_bh(&idev->lock);
>> +       *in_hiscore =3D hiscore;
>> +       *in_score =3D score;
>>  }
>>
>>  int ipv6_dev_get_saddr(struct net *net, const struct net_device *ds=
t_dev,
>>                        const struct in6_addr *daddr, unsigned int pr=
efs,
>>                        struct in6_addr *saddr)
>>  {
>> -       struct ipv6_saddr_score scores[2], *hiscore =3D &scores[1];
>> +       struct ipv6_saddr_score scores[2];
>> +       struct ipv6_saddr_score *score =3D &scores[0], *hiscore =3D =
&scores[1];
>>         struct ipv6_saddr_dst dst;
>>         struct inet6_dev *idev;
>>         struct net_device *dev;
>> @@ -1475,18 +1479,19 @@ int ipv6_dev_get_saddr(struct net *net, cons=
t
>> struct net_device *dst_dev,
>>                 if ((dst_type & IPV6_ADDR_MULTICAST) ||
>>                     dst.scope <=3D IPV6_ADDR_SCOPE_LINKLOCAL) {
>>                         idev =3D __in6_dev_get(dst_dev);
>> -                       use_oif_addr =3D true;
>> +                       if (idev)
>> +                               use_oif_addr =3D true;
>>                 }
>>         }
>>         if (use_oif_addr) {
>> -               __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, =
scores);
>> +               __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev,
>> &score, &hiscore);
>>         } else {
>>                 for_each_netdev_rcu(net, dev) {
>>                         idev =3D __in6_dev_get(dev);
>>                         if (!idev)
>>                                 continue;
>> -                       __ipv6_dev_get_saddr(net, &dst, prefs, saddr=
,
>> idev, scores);
>> +                       __ipv6_dev_get_saddr(net, &dst, prefs, saddr=
,
>> idev, &score, &hiscore);
>>                 }
>>         }
>>         rcu_read_unlock();
>>
>> On Mon, Jul 13, 2015 at 7:28 AM, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E
>> <hideaki.yoshifuji@miraclelinux.com> wrote:
>>> Commit 9131f3de2 ("ipv6: Do not iterate over all interfaces when
>>> finding source address on specific interface.") did not properly
>>> update best source address available.  Plus, it introduced
>>> possible NULL pointer dereference.
>>>
>>> Bug was reported by Erik Kline <ek@google.com>.
>>> Based on patch proposed by Hajime Tazaki <thehajime@gmail.com>.
>>>
>>> Fixes: 9131f3de24db4dc12199aede7d931e6703e97f3b ("ipv6: Do not
>>>         iterate over all interfaces when finding source address
>>>         on specific interface.")
>>> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.co=
m>
>>> ---
>>>  net/ipv6/addrconf.c | 30 ++++++++++++++++++------------
>>>  1 file changed, 18 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index 4ab74d5..4c9a024 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -1358,14 +1358,15 @@ out:
>>>         return ret;
>>>  }
>>>
>>> -static void __ipv6_dev_get_saddr(struct net *net,
>>> -                                struct ipv6_saddr_dst *dst,
>>> -                                unsigned int prefs,
>>> -                                const struct in6_addr *saddr,
>>> -                                struct inet6_dev *idev,
>>> -                                struct ipv6_saddr_score *scores)
>>> +static int __ipv6_dev_get_saddr(struct net *net,
>>> +                               struct ipv6_saddr_dst *dst,
>>> +                               unsigned int prefs,
>>> +                               const struct in6_addr *saddr,
>>> +                               struct inet6_dev *idev,
>>> +                               struct ipv6_saddr_score *scores,
>>> +                               int hiscore_idx)
>>>  {
>>> -       struct ipv6_saddr_score *score =3D &scores[0], *hiscore =3D=
 &scores[1];
>>> +       struct ipv6_saddr_score *score =3D &scores[1 - hiscore_idx]=
, *hiscore =3D &scores[hiscore_idx];
>>>
>>>         read_lock_bh(&idev->lock);
>>>         list_for_each_entry(score->ifa, &idev->addr_list, if_list) =
{
>>> @@ -1424,6 +1425,7 @@ static void __ipv6_dev_get_saddr(struct net *=
net,
>>>                                 in6_ifa_hold(score->ifa);
>>>
>>>                                 swap(hiscore, score);
>>> +                               hiscore_idx =3D 1 - hiscore_idx;
>>>
>>>                                 /* restore our iterator */
>>>                                 score->ifa =3D hiscore->ifa;
>>> @@ -1434,18 +1436,20 @@ static void __ipv6_dev_get_saddr(struct net=
 *net,
>>>         }
>>>  out:
>>>         read_unlock_bh(&idev->lock);
>>> +       return hiscore_idx;
>>>  }
>>>
>>>  int ipv6_dev_get_saddr(struct net *net, const struct net_device *d=
st_dev,
>>>                        const struct in6_addr *daddr, unsigned int p=
refs,
>>>                        struct in6_addr *saddr)
>>>  {
>>> -       struct ipv6_saddr_score scores[2], *hiscore =3D &scores[1];
>>> +       struct ipv6_saddr_score scores[2], *hiscore;
>>>         struct ipv6_saddr_dst dst;
>>>         struct inet6_dev *idev;
>>>         struct net_device *dev;
>>>         int dst_type;
>>>         bool use_oif_addr =3D false;
>>> +       int hiscore_idx =3D 0;
>>>
>>>         dst_type =3D __ipv6_addr_type(daddr);
>>>         dst.addr =3D daddr;
>>> @@ -1454,8 +1458,8 @@ int ipv6_dev_get_saddr(struct net *net, const=
 struct net_device *dst_dev,
>>>         dst.label =3D ipv6_addr_label(net, daddr, dst_type, dst.ifi=
ndex);
>>>         dst.prefs =3D prefs;
>>>
>>> -       hiscore->rule =3D -1;
>>> -       hiscore->ifa =3D NULL;
>>> +       scores[hiscore_idx].rule =3D -1;
>>> +       scores[hiscore_idx].ifa =3D NULL;
>>>
>>>         rcu_read_lock();
>>>
>>> @@ -1480,17 +1484,19 @@ int ipv6_dev_get_saddr(struct net *net, con=
st struct net_device *dst_dev,
>>>         }
>>>
>>>         if (use_oif_addr) {
>>> -               __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev,=
 scores);
>>> +               if (idev)
>>> +                       hiscore_idx =3D __ipv6_dev_get_saddr(net, &=
dst, prefs, saddr, idev, scores, hiscore_idx);
>>>         } else {
>>>                 for_each_netdev_rcu(net, dev) {
>>>                         idev =3D __in6_dev_get(dev);
>>>                         if (!idev)
>>>                                 continue;
>>> -                       __ipv6_dev_get_saddr(net, &dst, prefs, sadd=
r, idev, scores);
>>> +                       hiscore_idx =3D __ipv6_dev_get_saddr(net, &=
dst, prefs, saddr, idev, scores, hiscore_idx);
>>>                 }
>>>         }
>>>         rcu_read_unlock();
>>>
>>> +       hiscore =3D &scores[hiscore_idx];
>>>         if (!hiscore->ifa)
>>>                 return -EADDRNOTAVAIL;
>>>
>>> --
>>> 1.9.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.=
com>
> =E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=
=83=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=
=93=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8
