From: Mahesh Kelkar <maheshkelkar@gmail.com>
Subject: Re: Last Ipv6 address removal causes "addrconf_sysctl_unregister",
	which inihibits from changing disable_ipv6 setting
Date: Mon, 26 Jul 2010 16:37:37 -0400
Message-ID: <AANLkTi=Yoi-gCfCimpyxjrE9idwqcYNGM5Fn22gEaorg@mail.gmail.com>
References: <AANLkTimnBssEeO_faqcAAzHCy8KxQo9FVcn7vu5fru4j@mail.gmail.com>
	<4C4DED5D.7090004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33745 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0GZUhj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:37:39 -0400
Received: by wwj40 with SMTP id 40so604431wwj.1
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 13:37:38 -0700 (PDT)
In-Reply-To: <4C4DED5D.7090004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Please see comments inline [mahesh]

On Mon, Jul 26, 2010 at 4:17 PM, Brian Haley <brian.haley@hp.com> wrote=
:
> On 07/26/2010 10:03 AM, Mahesh Kelkar wrote:
>> Odd behavior associated with the patch:
>> **Last address removal causes "addrconf_sysctl_unregister", which
>> inihibits from changing disable_ipv6 setting
>> (connected issue: With disable_ipv6 set to 1 on an interface, ff00:/=
8
>> and fe80::/64 are still added on device UP)
>
> This behavior doesn't seem specific to the patch that was accepted la=
st
> week to fix the disable_ipv6 behavior (64e724f6) as all of the sysctl
> values are gone for eth0.
>

[mahesh] Your are right. The behavior is not specific to the patch.
Actually I meant to say that the behavior can be observed with the
disable_ipv6 in general.

>> Current sysctl config:
>> net.ipv6.conf.all.disable_ipv6 =3D 1
>> net.ipv6.conf.default.disable_ipv6 =3D 1
>>
>> Steps:
>> - Remove last IPv6 address assigned to the "eth0" interface
>> - inet6_addr_del =3D> addrconf_ifdown(idev->dev, 1) =3D> does the de=
vice
>> sysctl unregister
>> ******Not sure why the addrconf_sysctl_unregister is necessary on la=
st
>> address removal*******
>> - Now, "sysctl -a" does not show "net.ipv6.conf.eth0.disable_ipv6"
>
> Do they get restored if you bring the link down and back up?
>

[mahesh] Yes. It does get restored on link down and back up.

>> Problem:
>> - If you WANT to assign IPv6 address to eth0,
>> -> Do it once, which fails due to "disable_ipv6" check in
>> addrconf_add_dev OR ipv6_add_addr
>> -> But, this process does "addrconf_sysctl_register" (addrconf_add_d=
ev
>> =3D> ipv6_find_idev =3D> ipv6_add_dev)
>> -> set net.ipv6.conf.eth0.disable_ipv6=3D0 and then successfully ass=
ign
>> ipv6-address to the eth0
>> (Another alternative is to change all or default to 1; but I wanted =
to
>> disable ipv6 by default)
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> Probable Solution:
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> @@ -1948,7 +1959,7 @@ static int inet6_addr_del(int ifindex, s
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0disable IPv6 on t=
his interface.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (idev->addr_list =3D=3D=
 NULL)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 addrconf_i=
fdown(idev->dev, 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 addrconf_i=
fdown(idev->dev, 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> I have tested the above solution and it seems to work fine - so far.
>
> This code has been this way forever in 2.6 (< 2005), changing it coul=
d break
> existing users. =A0I'm not sure why it was decided to do it this way =
as it
> was before my time.
>

[mahesh]  Can anyone on netdev list sheds light on this?

> Also, the full comment here is:
>
> =A0/* If the last address is deleted administratively,
> =A0 =A0disable IPv6 on this interface.
> =A0*/
>
> Which says that you're removing all the IPv6 addresses by hand using
> /sbin/ip, so you're forcing the removal. =A0If you want to disable IP=
v6
> on it and remove all the addresses, why don't you just set disable_ip=
v6=3D1?
>

[mahesh] I did not add the comment.

[mahesh] But, you are right. One of the alternative is to disable_ipv6
instead of removing last IP address.

[mahesh] But, if you or somebody else happen to touch this code in
future, please see if you could avoid
addrconf_sysctl_register/unregister.

> -Brian
>
