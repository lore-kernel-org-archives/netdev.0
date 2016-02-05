From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] flowi: add concept of "not_oif"
Date: Fri, 5 Feb 2016 19:38:05 +0100
Message-ID: <CAHmME9rF83ir0Hf9wsAoyu2aYPffu+WmOonc0nC6ZQqO8R_SyA@mail.gmail.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
	<1454521595-6721-1-git-send-email-Jason@zx2c4.com>
	<alpine.LFD.2.11.1602032149170.1802@ja.home.ssi.bg>
	<CAHmME9qqCZYvuskSQMA0F2d2E+5fHsRk=ydDOV=Nq5D7xemtaw@mail.gmail.com>
	<1454557445.7627.288.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julian Anastasov <ja@ssi.bg>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Ahern <dsa@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:36878 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbcBESiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 13:38:11 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 7193293e
	for <netdev@vger.kernel.org>;
	Fri, 5 Feb 2016 18:37:00 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 7d382aaf
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Fri, 5 Feb 2016 18:36:58 +0000 (UTC)
Received: by mail-wm0-f46.google.com with SMTP id p63so38802266wmp.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 10:38:06 -0800 (PST)
In-Reply-To: <1454557445.7627.288.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 4:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-02-03 at 22:02 +0100, Jason A. Donenfeld wrote:
>
>>
>> >         I don't know about the particular problems with
>> > tunnels but the scripts can use the route metric to order
>> > the routes in a table.
>>
>> This unfortunately does not cut it with tunnels.
>
> ip rule show
>
> ip route show table 10
>
> I am pretty sure that you could select/change skb mark when packets
> traverse the tunnel : The second route lookup can then select a
> completely different table.

This doesn't work. Not to mention the fact that ip-rules aren't
cleaned up when the interface is removed and the issues with having
multiple routing tables, the following only works for very narrow
cases:

(212.47.239.81 is the IP of a VPN endpoint, for example below)

$ ip rule add to 212.47.239.81 lookup main pref 30
$ ip rule add to all lookup 80 pref 40
$ ip route add default dev tun0 table 80

The problem is -- what happens when you have particular routes that
you'd like specifically to go over your original network connection,
not the tunnel? I am now not able to do this:

$ ip route add 1.2.3.4/32 dev eth0

Because it will examine the second rule. Moving everything to the
second routing table obviously isn't a solution either for all the
reasons listed in my first email. Everything is complicated, partially
broken, and all together unrobust this way.

Sorry, but the current routing facilities of Linux are woefully
insufficient for extremely common place modern day tunneling. The
solution I've offered here is extremely simple, easy, and
non-intrusive to implement. You will be the best friend of many
network administrators and ordinary daily users alike.

Just imagine if authors of userspace tunneling utilities could write
things like:

    setsockopt(fd, SO_NOTOIF, tun0_idx);

Or kernel tunneling utilities being able to write:

   .flowi4_not_oif = geneve0_idx;

And then never have to worry about routing loops or bizarre
situations? And have everything nicely cleaned up when the interface
goes away? And be able to continue using all the same old routing
tools and schemes as before, with no need for enormous
reimplementations and daemons and endless bloat?

This is a simple feature that will go a very long way. There is no
current solution that comes anywhere close to solving the real
problem. Please consider it.

Thanks,
Jason
