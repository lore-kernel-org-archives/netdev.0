From: Josh Snyder <josh@code406.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 18 Dec 2015 08:33:45 -0800
Message-ID: <CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
References: <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com>
	<1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215161456.GA3182@1wt.eu>
	<1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215174346.GA3187@1wt.eu>
	<1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215194410.GB3187@1wt.eu>
	<1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151216073814.GA3373@1wt.eu>
	<20151216161514.GA3476@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36548 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbbLRQdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 11:33:46 -0500
Received: by mail-oi0-f52.google.com with SMTP id o62so57494748oif.3
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 08:33:45 -0800 (PST)
In-Reply-To: <20151216161514.GA3476@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was also puzzled that binding succeeded. Looking into the code paths
involved, in inet_csk_get_port, we quickly goto have_snum. From there, we end
up dropping into tb_found. Since !hlist_empty(&tb->owners), we end up checking
that (tb->fastreuseport > 0 && sk->sk_reuseport && uid_eq(tb->fastuid, uid)).
This test passes, so we goto success and bind.

Crucially, we are checking the fastreuseport field on the inet_bind_bucket, and
not the sk_reuseport variable on the other sockets in the bucket. Since this
bit is set based on sk_reuseport at the time the first socket binds (see
tb_not_found), I can see no reason why sockets need to keep SO_REUSEPORT set
beyond initial binding.

Given this, I believe Willy's patch elegantly solves the problem at hand.

Josh

On Wed, Dec 16, 2015 at 8:15 AM, Willy Tarreau <w@1wt.eu> wrote:
> Hi Eric,
>
> On Wed, Dec 16, 2015 at 08:38:14AM +0100, Willy Tarreau wrote:
>> On Tue, Dec 15, 2015 at 01:21:15PM -0800, Eric Dumazet wrote:
>> > On Tue, 2015-12-15 at 20:44 +0100, Willy Tarreau wrote:
>> >
>> > > Thus do you think it's worth adding a new option as Tolga proposed ?
>> >
>> >
>> > I thought we tried hard to avoid adding the option but determined
>> > we could not avoid it ;)
>>
>> Not yet, your other proposal of disabling SO_REUSEPORT makes sense if
>> we combine it with the proposal to change the score in my patch. If
>> we say that a socket which has SO_REUSEPORT scores higher, then the
>> connections which don't want to accept new connections anymore will
>> simply have to drop it an not be elected. I find this even cleaner
>> since the sole purpose of the loop is to find the best socket in case
>> of SO_REUSEPORT.
>
> So I tried this and am pretty satisfied with the results, as I couldn't
> see any single reset on 4.4-rc5 with it. On 4.1 I got a few very rare
> resets at the exact moment the new process binds to the socket, because
> I suspect some ACKs end up in the wrong queue exactly there. But
> apparently the changes you did in 4.4 totally got rid of this, which is
> great!
>
> I suspected that I could enter a situation where a new process could
> fail to bind if generations n-1 and n-2 were still present, because
> n-2 would be running without SO_REUSEPORT and that should make this
> test fail in inet_csk_bind_conflict(), but it never failed for me :
>
>                         if ((!reuse || !sk2->sk_reuse ||
>                             sk2->sk_state == TCP_LISTEN) &&
>                             (!reuseport || !sk2->sk_reuseport ||
>                             (sk2->sk_state != TCP_TIME_WAIT &&
>                              !uid_eq(uid, sock_i_uid(sk2))))) {
> ...
>
> So I'm clearly missing something and can't spot what. I mean, I'd
> prefer to see my patch occasionally fail than not understanding why
> it always works! If anyone has an suggestion I'm interested.
>
> Here's the updated patch.
>
> Best regards,
> Willy
>
