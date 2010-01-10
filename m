From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: redundant tcp header length checks?
Date: Sun, 10 Jan 2010 08:02:57 -0500
Message-ID: <4B49D001.4000302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752858Ab0AJNDF@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a related note, back on Nov 10th, Ilpo brought to my attention --
*hidden* inside the pskb_may_pull() -- the tcp header length is range
checked for being too short (skb->len < th->doff * 4).

tcp_v4_rcv()
...
1585         if (!pskb_may_pull(skb, th->doff * 4))
1586                 goto discard_it;
1587

But the next comment in tcp_ipv4.c (missing from tcp_ipv6.c) says:

1588         /* An explanation is required here, I think.
1589          * Packet length and doff are validated by header prediction,
1590          * provided case of th->doff==0 is eliminated.
1591          * So, we defer the checks. */

That's not correct anymore, as the checks aren't deferred!  But the
redundant deferred checks _are_ still present in tcp_input.c:

tcp_rcv_established()
...
5210                 if (len <= tcp_header_len) {
5211                         /* Bulk data transfer: sender */
5212                         if (len == tcp_header_len) {
...
5229                         } else { /* Header too small */
5230                                 TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
5231                                 goto discard;
5232                         }

Also:

5325 slow_path:
5326         if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
5327                 goto csum_error;

Apparently tcp_rcv_established() might be called through some other path
that requires this extra header length checking?

Its callers also have another reference, for example in tcp_ipv4.c:

2432         .backlog_rcv            = tcp_v4_do_rcv,

And tcp_ipv6.c:

213                 sk->sk_backlog_rcv = tcp_v4_do_rcv;

223                         sk->sk_backlog_rcv = tcp_v6_do_rcv;

1302                 newsk->sk_backlog_rcv = tcp_v4_do_rcv;

2073         .backlog_rcv            = tcp_v6_do_rcv,

Can anybody explain these?
