From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Sat, 16 Apr 2011 11:07:03 +0200
Message-ID: <4DA95C37.2010304@gmail.com>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com> <10227.1302893590@death> <4DA89ADC.7040808@gmail.com> <16422.1302903932@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>,
	netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36503 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab1DPJHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 05:07:07 -0400
Received: by wya21 with SMTP id 21so2783443wya.19
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2011 02:07:06 -0700 (PDT)
In-Reply-To: <16422.1302903932@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2011 23:45, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:
>
>> Agreed.
>>
>>> 	Is there some race window there between the register and the
>>> netif_carrier_off?
>>
>> It might be that dhcpd does not wait for link to be up before starti=
ng to send DHCP requests.
>
> 	It looks like it's not related to carrier state at all:
>
> #212: dhcpcd requires restart to get an IP address for bonded interfa=
ce
> -----------------------+-----------------
>    Reporter:  mgorny@=E2=80=A6  |      Owner:  roy
>        Type:  defect    |     Status:  new
>    Priority:  major     |  Milestone:
>   Component:  dhcpcd    |    Version:  5.1
> Resolution:            |   Keywords:
> -----------------------+-----------------
>
> Comment (by roy):
>
>   Sorry, the above isn't too clear.
>
>   dhcpcd will read the hardware address when the interface is marked =
IFF_UP
>   or when given RTM_NEWLINK with ifi->ifi_change =3D ~0U, the latter =
being
>   sent by some drivers to tell userland that an interface characteris=
tic has
>   changed - like say a hardware address - if the driver supports such=
 a
>   change whilst still up. Normal behaviour is to mark device as DOWN =
before
>   changing hardware address. bonding does this whilst marked UP, henc=
e this
>   issue.
>
>   carrier going up / down is just that, it's not a signal to re-read =
the
>   interface characteristics.
>
>
> 	Now this confuses me again; I thought that running the dhcp
> client (dhcpcd) over bonding has worked for years, although I've not
> personally tried it recently.  Perhaps it varies by distro.  In any
> event, this behavior of bonding (setting the bond's MAC without a
> down/up flip) has never been different in my memory.

I use dhcpcd over bonding everyday on my laptop (debian/testing), for s=
everal years.

bond0 uses eth0 and wlan0 as slaves. The time to get a DHCP reply vary,=
 mostly because the time to=20
register to the wifi AP is not perfectly stable. Sometimes (not very of=
ten), I need to ifdown/ifup=20
to get a DHCP reply. This might be due to dhcpcd reading the MAC too ea=
rly and getting an all zero=20
MAC. I need to try and double check this, but as it happen early in the=
 boot process and not very=20
often, it will be hard to diagnose.

That being said, sending a DHCP request with an all zero source MAC sou=
nds very strange to me.

The RFC for DHCP (RFC2131) states that a DHCP server must be prepared t=
o broadcast the reply if the=20
client hardware address is null.

    If 'giaddr' is zero and 'ciaddr' is zero, and the broadcast bit is
    set, then the server broadcasts DHCPOFFER and DHCPACK messages to
    0xffffffff. If the broadcast bit is not set and 'giaddr' is zero an=
d
    'ciaddr' is zero, then the server unicasts DHCPOFFER and DHCPACK
    messages to the client's hardware address and 'yiaddr' address.  In
    all cases, when 'giaddr' is zero, the server broadcasts any DHCPNAK
    messages to 0xffffffff.

But a DHCP server must store a client identifier associated with a give=
n dynamic IP address for the=20
duration of the lease, to be able to give the same IP address to the sa=
me client if this client=20
restarts while the lease is still valid.

If the client hardware address is all zero and the client configuration=
 does not provide some other=20
user defined identifier, then the client identifier is not unique and t=
he DHCP server should - I=20
think - ignore the request.

So, except if the local dhcpcd configuration contains an user defined i=
dentifier, I think dhcpcd=20
should wait for the MAC address to be not null before sending any reque=
sts.

	Nicolas.

> 	I've not yet dug down to see if NETDEV_CHANGEADDR will result in
> an RTM_NEWLINK to user space.  At first glance it doesn't look like i=
t.
>
> 	When bonding goes link up, however, I think linkwatch_do_dev
> will issue an RTM_NEWLINK (via a call to netdev_state_change), or,
> alternately, dev_change_flags will do it at IFF_UP time.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>

