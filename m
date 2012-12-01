From: Willy Tarreau <w@1wt.eu>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Sat, 1 Dec 2012 21:52:27 +0100
Message-ID: <20121201205227.GA28390@1wt.eu>
References: <20121115222812.GA647@1wt.eu> <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:36370 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674Ab2LAUwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 15:52:34 -0500
Content-Disposition: inline
In-Reply-To: <20121201194304.GI25450@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

OK now I have a simple and reliable reproducer for the bug. It
just creates 2 TCP sockets connected to each other and splices
from one to the other. It looks 100% reliable, I'm attaching it
hoping it can help, it's much easier and more reliable than
starting haproxy with clients and servers!

I'm noting that it only crashes when I send more than one page
of data. 4096 bytes and below are OK, 4097 and above do crash.

I have added a few printk() and it dies in get_page() called from
do_tcp_sendpages() :

  888                  i = skb_shinfo(skb)->nr_frags;
  889  printk(KERN_DEBUG "%d: page=%p i=%d skb=%p offset=%d\n", __LINE__, page, i, skb, offset);
  890                  can_coalesce = skb_can_coalesce(skb, i, page, offset);
  891  printk(KERN_DEBUG "%d: can_coalesce=%d\n", __LINE__, can_coalesce);
  892                  if (!can_coalesce && i >= MAX_SKB_FRAGS) {
  893  printk(KERN_DEBUG "%d\n", __LINE__);
  894                          tcp_mark_push(tp, skb);
  895                          goto new_segment;
  896                  }
  897                  if (!sk_wmem_schedule(sk, copy)) {
  898  printk(KERN_DEBUG "%d\n", __LINE__);
  899                          goto wait_for_memory;
  900                  }
  901
  902                  if (can_coalesce) {
  903  printk(KERN_DEBUG "%d\n", __LINE__);
  904                          skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
  905                  } else {
  906  printk(KERN_DEBUG "%d\n", __LINE__);
  907                          get_page(page);
  908  printk(KERN_DEBUG "%d\n", __LINE__);
  909                          skb_fill_page_desc(skb, i, page, offset, copy);
  910                  }
  911
  912  printk(KERN_DEBUG "%d\n", __LINE__);
  913                  skb->len += copy;
  914                  skb->data_len += copy;

dmesg starts with :

  889: page=f77b9ca0 i=0 skb=f5b91540 offset=0
  891: can_coalesce=0
  906
  908
  912
  871
  875
  880
  889: page=f6e7a300 i=0 skb=f46f5c80 offset=2513
  891: can_coalesce=0
  906
  908
  912
  889: page=0000fb80 i=1 skb=f46f5c80 offset=0
  891: can_coalesce=0
  906
  BUG: unable to handle kernel paging request at 0000fb80
IP: [<c13b4878>] tcp_sendpage+0x568/0x6d0

If that can help, I also noticed this one once with a
page that could look valid, so the error was propagated
further (the send() was 64kB) :

  ...
  906
  908
  912
  889: page=f6e79f80 i=6 skb=f37a1c80 offset=0
  891: can_coalesce=0
  906
  908
  912
  889: page=c13d58a7 i=7 skb=f37a1c80 offset=927
  891: can_coalesce=0
  906
  908
  912
  889: page=c13b4310 i=8 skb=f37a1c80 offset=3877
  891: can_coalesce=0
  906
  BUG: unable to handle kernel paging request at 8b31752a
  IP: [<c1094371>] __get_page_tail+0x31/0x90
  *pde = 00000000 

Now I'm really at loss, so do not hesitate to ask me for more
info, because I don't know where to look.

Cheers,
Willy


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="splice-bug.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void fail(const char *e)
{
	perror(e);
	exit(1);
}

int main(int argc, char **argv)
{
	struct sockaddr sa;
	socklen_t sl;
	int p[2];
	int l, s, r;
	char buffer[4097];

	l = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (l < 0)
		fail("L: socket()");

	if (listen(l, 1) < 0)
		fail("L: listen()");

	sl = sizeof(sa);
	if (getsockname(l, &sa, &sl) < 0)
		fail("L: getsockname()");

	if ((s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
		fail("S: socket()");

	if (connect(s, &sa, sl) < 0)
		fail("S: connect()");

	sl = sizeof(sa);
	if ((r = accept(l, &sa, &sl)) < 0)
		fail("R: accept()");

	pipe(p);

	send(s, buffer, sizeof(buffer), MSG_DONTWAIT);

	l = splice(r, NULL, p[1], NULL, 1048576, 3);
	splice(p[0], NULL, s, NULL, l, 3);

	exit(0);
}

--mYCpIKhGyMATD0i+--
