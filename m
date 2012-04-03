From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: allow splice() to build full TSO packets
Date: Tue, 03 Apr 2012 21:37:01 +0200
Message-ID: <1333481821.18626.322.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50837 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273Ab2DCThG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 15:37:06 -0400
Received: by wgbdr13 with SMTP id dr13so56663wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 12:37:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmsplice()/splice(pipe, socket) call do_tcp_sendpages() one page at a
time, adding at most 4096 bytes to an skb. (assuming PAGE_SIZE=3D4096)

The call to tcp_push() at the end of do_tcp_sendpages() forces an
immediate xmit when pipe is not already filled, and tso_fragment() try
to split these skb to MSS multiples.

4096 bytes are usually split in a skb with 2 MSS, and a remaining
sub-mss skb (assuming MTU=3D1500)

This makes slow start suboptimal because many small frames are sent to
qdisc/driver layers instead of big ones (constrained by cwnd and packet=
s
in flight of course)

In fact, applications using sendmsg() (adding an additional memory copy=
)
instead of vmsplice()/splice()/sendfile() are a bit faster because of
this anomaly, especially if serving small files in environments with
large initial [c]wnd.

Call tcp_push() only if MSG_MORE is not set in the flags parameter.

This bit is automatically provided by splice() internals but for the
last page, or on all pages if user specified SPLICE_F_MORE splice()
flag.

In some workloads, this can reduce number of sent logical packets by an
order of magnitude, making zero-copy TCP actually faster than
one-copy :)

Reported-by: Tom Herbert <therbert@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail>com>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cfd7edd..2ff6f45 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -860,7 +860,7 @@ wait_for_memory:
 	}
=20
 out:
-	if (copied)
+	if (copied && !(flags & MSG_MORE))
 		tcp_push(sk, flags, mss_now, tp->nonagle);
 	return copied;
=20
