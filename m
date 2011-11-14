From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc: deleting single entry from filter hashtable
Date: Mon, 14 Nov 2011 17:15:25 +0100
Message-ID: <1321287325.2272.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAO0uZ+9N9zwt07EdQzz6KjGcpRT7rdmpaBvHoE0TLDXe-0kxMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59128 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab1KNQPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 11:15:30 -0500
Received: by fagn18 with SMTP id n18so3163878fag.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 08:15:29 -0800 (PST)
In-Reply-To: <CAO0uZ+9N9zwt07EdQzz6KjGcpRT7rdmpaBvHoE0TLDXe-0kxMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 novembre 2011 =C3=A0 22:19 +0100, Miroslav Kratochvil a
=C3=A9crit :
> Hello,
>=20
> I have following problem: For performance reasons I've been using a
> setup known from LARTC as 'hashing filters', just like here:
>=20
> http://lartc.org/howto/lartc.adv-filter.hashing.html
>=20
> For the same performance reasons, I'd like to be able to delete or
> change a _single_ entry from the hash table, so I don't need to refil=
l
> the whole table on every change I need to do (which can get pretty
> slow for amount of entries over 10k, even when using a C program that
> pushes the commands right into 'tc -batch')
>=20
> Question: Is the single deletion/modification possible? If not --
> judging from the lack of the documentation on given subject I kindof
> expect that it's not possible -- is there any other possibility to
> delete at least some reasonably small subset of the hash table that
> could be modified and recreated quickly?
>=20
> Also, here's my (failed) approach: I tried to assign different prio's
> to all hashtable entries so they could be deleted by reference to tha=
t
> prio, but after passing through TC they got created with the same pri=
o
> anyway..
>=20
> Thanks for any help with this problem,

Not sure I understand the exact problem, but it is possible to delete a
single filter, and add a new one.

Be careful, since adding a new one really adds a new filter : duplicate=
s
are not detected.

$ tc filter add dev eth0 parent 8001:0 protocol ip prio 100 u32 match i=
p src  1.2.0.0 classid 1:3
$ tc -s -d filter show dev eth0
filter parent 8001: protocol ip pref 100 u32=20
filter parent 8001: protocol ip pref 100 u32 fh 800: ht divisor 1=20
filter parent 8001: protocol ip pref 100 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0 flowid 1:3  (rule hit 4 success 0)
  match 01020000/ffffffff at 12 (success 0 )=20
$ tc filter add dev eth0 parent 8001:0 protocol ip prio 100 u32 match i=
p src  1.2.0.0 classid 1:3
$ tc -s -d filter show dev eth0
filter parent 8001: protocol ip pref 100 u32=20
filter parent 8001: protocol ip pref 100 u32 fh 800: ht divisor 1=20
filter parent 8001: protocol ip pref 100 u32 fh 800::800 order 2048 key=
 ht 800 bkt 0 flowid 1:3  (rule hit 4 success 0)
  match 01020000/ffffffff at 12 (success 0 )=20
filter parent 8001: protocol ip pref 100 u32 fh 800::801 order 2049 key=
 ht 800 bkt 0 flowid 1:3  (rule hit 0 success 0)
  match 01020000/ffffffff at 12 (success 0 )=20
