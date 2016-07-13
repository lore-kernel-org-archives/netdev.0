From: Yue Cao <ycao009@ucr.edu>
Subject: Re: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Wed, 13 Jul 2016 11:54:17 -0700
Message-ID: <CAPzkZjwuYWzkE19ReVJKWeY__62tQvLUZF2keca_9f680WVNFA@mail.gmail.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
 <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
 <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADVnQym7nL8AekOFYFH3pcnLerHBAC4BrYv5hY6Z5HN7kGkVkQ@mail.gmail.com>
 <CAPzkZjwS9Kabtg0g==QrTUmyR0PUfy8C76XueanNivYSDLZZGg@mail.gmail.com> <1468224173.30694.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.ucr.edu ([138.23.62.3]:3456 "EHLO mx2.ucr.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbcGMSyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:54:41 -0400
Received: by mail-it0-f72.google.com with SMTP id f6so98195750ith.3
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 11:54:18 -0700 (PDT)
In-Reply-To: <1468224173.30694.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see your point and I agree with you that SSL protects victims from
this hijacking attack, especially with full HSTS.

For Windows case, since Windows is a black box for us, we tested its
Challenge ACK mechanism with Windows Server 2012 R2 Base and Windows
Server 2008 R2 from Amazon EC2. The results show that Windows also add
some strategies to mitigate blind in-window attack problem, but the
mitigated results are not as same as what mentioned in RFC 5961.

Please let me know if I said something wrong. Thanks for the fix!

Best,
Yue

On Mon, Jul 11, 2016 at 1:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-07-10 at 11:28 -0700, Yue Cao wrote:
>> This second patch does make our attack much harder but it's still
>> possible to do such off-path attack with enough network bandwidth.
>> Here is our modified attack for this second patch.
>>
>> Modified Attack:
>> Main idea of our attack is to send multiple same spoofed packets in 1
>> second so attacker can confirm if it's a right guess or wrong guess.
>> In more detail, attacker sends more than 1000 (e.g. 1500) spoofed
>> packets for a same guessed value at beginning. After that, attacker
>> sends 1500 packets during the same second to determine whether
>> previous guess is right or wrong, by using following rules:
>> If attacker receives less than 500 Challenge ACKs, it's a right guess.
>> For a example, if 1500 spoofed packets are sent with a correct
>> value(right guess), all Challenge ACKs will be sent to victim client
>> in that second and attacker receives nothing. Otherwise, it's a wrong
>> guess.
>>
>> Since this global rate limit always leaks some information as a
>> side-channel, we are wondering if eliminating it completely would be a
>> good idea. In fact, according to our latest test, FreeBSD and Windows
>> do not have any such rate limit implemented. Looking forward to your
>> replies.
>
> Are you sure Windows is implementing RFC 5961 ? Linux got in in 3.6.
>
> We do want RFC 5961, compared to the small nuisance of the attack you
> describe.
>
> Nuisance of having a way for hackers to send a RST packet after
> consuming thousands of probe packets is nothing, compared to the
> nuisance of ACK storms we had before rate limiting was added in 3.6 (and
> refined in 4.0). This was a serious problem for real servers, because of
> buggy firewalls and appliances.
>
> You probably know that if someone worries about TCP flows being
> compromised, it should use SSL, so that traffic injection is less likely
> to happen.
>
> Most TCP flows in the Internet are short lived (less than 1 minute).
>
> Having to establish about 500 flows to the victim is already a
> challenge, since the victim would already be in trouble if it was
> allowing so many idle flows.
>
> So the 'solution' would be to backport
> f2b2c582e82429270d5818fbabe653f4359d7024
> ("tcp: mitigate ACK loops for connections as tcp_sock")
>
> Then apply the v2 patch so that the limit is randomized.
>
> Then set the default limit to 2^31
>
>
>
