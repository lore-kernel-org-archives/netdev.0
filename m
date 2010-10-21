From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [PATCH v2] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 22:01:18 +0300
Message-ID: <4CC08DFE.7070400@iki.fi>
References: <4CC02ABF.8090008@iki.fi>	 <1287666383-17615-1-git-send-email-timo.teras@iki.fi> <1287670228.6871.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:52563 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757445Ab0JUTBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 15:01:20 -0400
Received: by ewy7 with SMTP id 7so560564ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 12:01:19 -0700 (PDT)
In-Reply-To: <1287670228.6871.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 05:10 PM, Eric Dumazet wrote:
> Le jeudi 21 octobre 2010 =C3=A0 16:06 +0300, Timo Ter=C3=A4s a =C3=A9=
crit :
>> Otherwise we have race condition to user land:
>>  1. process A: changes IP address
>>  2. process A: kernel sends RTM_NEWADDR (and schedules out)
>>  3. process B: gets notification
>>  4. process B: tries to bind() to new IP, but fails with EADDRNOTAVA=
IL
>>       because FIB is not yet updated and inet_addr_type() in inet_bi=
nd()
>>       does not recognize the IP as local
>>  5. process A: calls inetaddr_chain notifiers which updates FIB
>>
>> Fix the error path to synchronize with configuration changes and ret=
ry
>> the address type check.
>>
>> IPv6 side seems to handle the notifications properly: bind() immedia=
tely
>> after RTM_NEWADDR succeeds as expected.  This is because ipv6_chk_ad=
dr()
>> uses inet6_addr_lst which is updated before address notification.
>>
>> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
>> ---
>> Since there was no reply to my question if this is ok, I interpreted=
 it
>> as "maybe". So here's the code for review. Hopefully this helps dete=
rmining
>> if this is an acceptable fix.
>=20
> Just say : no
>=20
> Really Timo, this problem must get another fix.
>=20
> I understand you need an urgent fix, you can use your patch in the
> meantime, of course ;)

=46ine. I figured you might feel this way. My final idea to fix this, i=
s
to modify inet_addr_type() do the address type check using the ifa
lists. This probably involves making ifa lists rcu (did not take close
look on how ifa lists work in current ipv4 code). This is basically how
ipv6 side works. I'm not too sure how to go on with this, so I'll wait
up until someone more qualified gets the time to look at this.

I think for my immediate needs I might be able to get away with using
the kludge patch, enabling non-local binding or fixing my userland code
to listen RTM_NEWROUTE/RTN_LOCAL events (though, IPv6 link-local
addresses are special and would need RTM_NEWADDR handling still to get
the real device's ifindex).

Btw. why do IPv6 RTN_LOCAL routes have loopback interface as dst instea=
d
of the real device? IPv4 RTN_LOCAL routes seem to have the real device
so this looks inconsistent at first sight. I guess IPv6 requires this
for a bunch of other things. This way it's just not really possible to
get link-local IPv6 routes.
