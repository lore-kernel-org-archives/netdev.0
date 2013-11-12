From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Tue, 12 Nov 2013 09:59:16 +0100
Message-ID: <5281EDE4.3080704@6wind.com>
References: <20131105205744.GK8832@order.stressinduktion.org> <1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com> <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com> <alpine.LFD.2.03.1311091610090.1411@ssi.bg>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	davem@davemloft.net, David.Laight@ACULAB.COM, jiri@resnulli.us,
	vyasevich@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:60727 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3KLI7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 03:59:19 -0500
Received: by mail-wi0-f173.google.com with SMTP id ey11so3327182wid.12
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 00:59:18 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1311091610090.1411@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/11/2013 15:46, Julian Anastasov a =E9crit :
>
> 	Hello,
>
> On Sat, 9 Nov 2013, Nicolas Dichtel wrote:
>
>> This feature allows to a send packets with address source set to 0.0=
=2E0.0 even if
>> an ip address is available on another interface.
>>
>> It's useful for DHCP client, to allow them to use UDP sockets and be=
 compliant
>> with the RFC2131, Section 4.1:
>>
>> 4.1 Constructing and sending DHCP messages
>> ...
>>     DHCP messages broadcast by a client prior to that client obtaini=
ng
>>     its IP address must have the source address field in the IP head=
er
>>     set to 0.
>>
>> Based on a previous work from
>> Guillaume Gaudonville <guillaume.gaudonville@6wind.com>.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> ...
>
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 89909dd730dd..f58945187dbd 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>
> ...
>
>> +	if (up->src_any && sk->sk_bound_dev_if) {
>> +		struct net_device *dev;
>> +		struct in_device *in_dev;
>> +
>> +		rcu_read_lock();
>> +		dev =3D dev_get_by_index_rcu(sock_net(sk), sk->sk_bound_dev_if);
>> +		in_dev =3D dev ? __in_dev_get_rcu(dev) : NULL;
>> +		if (!inet_confirm_addr(sock_net(sk), in_dev, 0, 0,
>> +				       RT_SCOPE_HOST))
>
> 	I don't have an opinion about UDP_SRC_ANY, just some
> comments...
>
> 	Can a simple !in_dev->ifa_list check replace the
> !inet_confirm_addr call? Looking at __inet_insert_ifa()
> it seems only 0.0.0.0 does not add an ifa. Long ago
> adding 0.0.0.0 was a way to create in_dev for dev but
> now in_dev is created on device registration, i.e. even
> before addresses are added.
>
> 	For the first patch, may be it is not needed.
> We have two choices:
>
> 1. Do not change args and just fix comments. Of course,
> it is tricky to use this function by using scope instead
> of in_dev as a key for device-specific matching because
> such interface is confusing.
I hesitated to take this choice, but I think that keeping the
original behavior is better.

>
> 2. Add 'net' arg and use in_dev as explained in my
> previous email. Not sure if changing args of exported
> function is acceptable.
=46WIK, it's not a problem.


Regards,
Nicolas
