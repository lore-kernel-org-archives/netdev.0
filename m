From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: 'tcp: bind() fix when many ports are bound' problem
Date: Wed, 5 Jan 2011 11:00:20 +0200
Message-ID: <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
	<AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
	<1294140172.3579.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44596 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab1AEJAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 04:00:20 -0500
Received: by pva4 with SMTP id 4so2710612pva.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 01:00:20 -0800 (PST)
In-Reply-To: <1294140172.3579.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 4, 2011 at 1:22 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 04 janvier 2011 =E0 13:12 +0400, Gaspar Chilingarov a =E9cri=
t :
>> Hi there!
>>
>> Well, that looks strange.
>>
>> On my own side I've just put workaround (manually binding to all por=
ts
>> in sequence :)
>> and moved production code to FreeBSD as it has better scalable netwo=
rk stack.
>>
>> I can see the potential problem with that bind() problem on highly
>> loaded DNS servers/resolvers which establish tons of outgoing UDP
>> connections.
>>
>> In some cases that connections could fail and as not receiving the
>> answer it is normal condition for DNS this will go totally unnoticed=
=2E
>>
>> I don't think anyone will hit this bug in production environment
>> except the very high load applications.
>
> Dont mix TCP and UDP, they are not the same.
>
> Problem with TCP is you can have TIME_WAIT sockets, disallowing a por=
t
> to be reused. Not with UDP.

Isn't SO_REUSEADDR supposed to fix this problem?

Anyhow, inet_csk_get_port the function used by bind(0) performs bad.

Short reminder:
100 IP addr  - 70K sockets created =3D> 700 sockets per IP.
bind(0) for all sockets will results in a large number of
(port, addr) duplicates although there are more than 30000 ports availa=
ble.

This wouldn't be so bad if you won't try to connect duplicates to the s=
ame
remote (addr, port) which will result in a connect failure.

Eric's patch introduced the restriction 'forbid two reuse enabled socke=
ts
to bind on same (addr, port) tuple with a (non ANY addr)'.

Well, I think this will break rule #2 from inet_hastable.h:
"
If all sockets have sk->sk_reuse set, and none of them are in
TCP_LISTEN state, the port may be shared.
"
and also caused problem ([1]), don't really know if they are the same.

An attempt, to fix this was to "always allow a reuse listen if
no other listen is already active on the same IP".

The problem with this fix, is that at the moment of bind() we
don't know what will be the usage of this socket. It can be,
bind -> connect or bind -> listen.
>
> The connect() [without a previous bind()], or a sendto() [without a
> previous bind()] problem is more an API problem.

Can you share your thoughts on this?

Going back to my first email, are there any follow ups on your
"tcp: bind() fix when many ports are bound" patch. I've searched
netdev archives but no luck. I might have missed something.

I really appreciate your help.

thanks,
Daniel.
