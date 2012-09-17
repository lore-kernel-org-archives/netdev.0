From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Mon, 17 Sep 2012 09:49:04 +0200
Message-ID: <1347868144.26523.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48002 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2IQHtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 03:49:09 -0400
Received: by bkwj10 with SMTP id j10so2300606bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 00:49:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use per socket page reserve for tcp_sendmsg() operations.

Its done to raise the probability of coalescing small write() in to
single segments in the skbs.

But it wastes a lot of memory for applications handling a lot of mostly
idle sockets, since each socket holds one page in sk->sk_sndmsg_page

I did a small experiment to use order-3 pages and it gave me a 10% boost
of performance, because each TSO skb can use only two frags of 32KB,
instead of 16 frags of 4KB, so we spend less time in ndo_start_xmit() to
setup the tx descriptor and TX completion path to unmap the frags and
free them.

We also spend less time in tcp_sendmsg(), because we call page allocator
8x less often.

Now back to the per socket page, what about trying to factorize it ?

Since we can sleep (or/and do a cpu migration) in tcp_sendmsg(), we cant
really use a percpu page reserve as we do in __netdev_alloc_frag()

We could instead use a per thread reserve, at the cost of adding a test
in task exit handler.

Recap :

1) Use a per thread page reserve instead of a per socket one
2) Use order-3 pages (or order-0 pages if page size is >= 32768)
