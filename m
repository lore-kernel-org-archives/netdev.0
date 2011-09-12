From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Mon, 12 Sep 2011 07:40:31 +0200
Message-ID: <1315806031.3174.16.camel@edumazet-laptop>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
	 <1315546223.5410.23.camel@edumazet-laptop>
	 <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>
	 <1315596786.2606.3.camel@edumazet-laptop>
	 <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
	 <1315604820.2606.13.camel@edumazet-laptop>
	 <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>
	 <1315606125.2606.19.camel@edumazet-laptop>
	 <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>
	 <20110910130416.GA2005@neilslaptop.think-freely.org>
	 <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42564 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab1ILFkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 01:40:41 -0400
Received: by wwf22 with SMTP id 22so883633wwf.1
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2011 22:40:39 -0700 (PDT)
In-Reply-To: <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 septembre 2011 =C3=A0 20:38 -0700, Kumar S a =C3=A9crit =
:

Please dont top post.

> Thanks Neil. I did try with prink(). I do see entries getting aged
> out, but they are not getting deallocated. This seems to be happening
> because of "ref_cnt". When the route entries are added the ref_cnt is
> set to 1. Looks this is causing trouble clearing the entries
> completely. If I set the ref_cnt to 0, I can see it working. Now I'm
> trying to understand whether this is right. Please let me know if you
> have any thoughts on it.

I believe I already explained what was happening.

A tcp socket has a pointer to a dst, so it holds a reference on it, to
make sure no freeing of dst can happen while at least some socket still
can reference dst. (It could reference freed memory and crash)

As soon as the tcp socket will try to transmit some data, the dst will
be checked and we notice its obsolete : We then release the refcount an=
d
dst pointer.

Later, the garbage collector can notice dst refcount is zero and can
free dst.

If you have dormant tcp sockets (no trafic at all), they hold their dst=
=2E

A dormant tcp socket has a pretty more expensive memory cost than its
dst. (Socket structure, dentry, inode, and probably in user land a
thread or process, and data)
