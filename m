From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Mon, 11 Jul 2016 10:02:53 +0200
Message-ID: <1468224173.30694.72.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
	 <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CADVnQym7nL8AekOFYFH3pcnLerHBAC4BrYv5hY6Z5HN7kGkVkQ@mail.gmail.com>
	 <CAPzkZjwS9Kabtg0g==QrTUmyR0PUfy8C76XueanNivYSDLZZGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yue Cao <ycao009@ucr.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33151 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030318AbcGKIC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 04:02:58 -0400
Received: by mail-io0-f181.google.com with SMTP id t74so92461144ioi.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 01:02:58 -0700 (PDT)
In-Reply-To: <CAPzkZjwS9Kabtg0g==QrTUmyR0PUfy8C76XueanNivYSDLZZGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-07-10 at 11:28 -0700, Yue Cao wrote:
> This second patch does make our attack much harder but it's still
> possible to do such off-path attack with enough network bandwidth.
> Here is our modified attack for this second patch.
> 
> Modified Attack:
> Main idea of our attack is to send multiple same spoofed packets in 1
> second so attacker can confirm if it's a right guess or wrong guess.
> In more detail, attacker sends more than 1000 (e.g. 1500) spoofed
> packets for a same guessed value at beginning. After that, attacker
> sends 1500 packets during the same second to determine whether
> previous guess is right or wrong, by using following rules:
> If attacker receives less than 500 Challenge ACKs, it's a right guess.
> For a example, if 1500 spoofed packets are sent with a correct
> value(right guess), all Challenge ACKs will be sent to victim client
> in that second and attacker receives nothing. Otherwise, it's a wrong
> guess.
> 
> Since this global rate limit always leaks some information as a
> side-channel, we are wondering if eliminating it completely would be a
> good idea. In fact, according to our latest test, FreeBSD and Windows
> do not have any such rate limit implemented. Looking forward to your
> replies.

Are you sure Windows is implementing RFC 5961 ? Linux got in in 3.6.

We do want RFC 5961, compared to the small nuisance of the attack you
describe.

Nuisance of having a way for hackers to send a RST packet after
consuming thousands of probe packets is nothing, compared to the
nuisance of ACK storms we had before rate limiting was added in 3.6 (and
refined in 4.0). This was a serious problem for real servers, because of
buggy firewalls and appliances.

You probably know that if someone worries about TCP flows being
compromised, it should use SSL, so that traffic injection is less likely
to happen.

Most TCP flows in the Internet are short lived (less than 1 minute).

Having to establish about 500 flows to the victim is already a
challenge, since the victim would already be in trouble if it was
allowing so many idle flows.

So the 'solution' would be to backport
f2b2c582e82429270d5818fbabe653f4359d7024
("tcp: mitigate ACK loops for connections as tcp_sock")

Then apply the v2 patch so that the limit is randomized.

Then set the default limit to 2^31
