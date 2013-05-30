From: Chen Gang <gang.chen@asianux.com>
Subject: [Regression net-next] include/linux/skbuff.h: "1a37e41 net: Use 16bits
 for *_headers fields of struct skbuff"
Date: Thu, 30 May 2013 19:21:17 +0800
Message-ID: <51A7362D.4070501@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:12839 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968151Ab3E3LWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

When not define NET_SKBUFF_DATA_USES_OFFSET, 'sk_buff_data_t' will be a
pointer, then the last parameter of memmove() in mangle_contents() will
be a pointer in "net/netfilter/nf_nat_helper.c".

The reason is from the patch "1a37e41 net: Use 16bits for *_headers
fields of struct skbuff", it changed the type of 'skb->network_header'
for saving size, it needs additional improvement.

The related warning (make EXTRA_CFLAGS=3D-W ARCH=3Dm68k allmodconfig):
  arch/m68k/include/asm/string.h:61:14: note: expected =91__kernel_size=
_t=92 but argument is of type =91sk_buff_data_t=92


in "net/netfilter/nf_nat_helper.c"

 91 /* Frobs data inside this packet, which is linear. */
 92 static void mangle_contents(struct sk_buff *skb,
 93                             unsigned int dataoff,
 94                             unsigned int match_offset,
 95                             unsigned int match_len,
 96                             const char *rep_buffer,
 97                             unsigned int rep_len)
 98 {
 99         unsigned char *data;
100=20
101         BUG_ON(skb_is_nonlinear(skb));
102         data =3D skb_network_header(skb) + dataoff;
103=20
104         /* move post-replacement */
105         memmove(data + match_offset + rep_len,
106                 data + match_offset + match_len,
107                 skb->tail - (skb->network_header + dataoff +
108                              match_offset + match_len));
109=20


in "include/linux/skbuff.h":

 409 struct sk_buff {
 410         /* These two members must be first. */
 411         struct sk_buff          *next;
 412         struct sk_buff          *prev;
 413=20
 414         ktime_t                 tstamp;
 415=20
 416         struct sock             *sk;
 417         struct net_device       *dev;
 418=20
 ...
 515         __be16                  inner_protocol;
 516         __u16                   inner_transport_header;
 517         __u16                   inner_network_header;
 518         __u16                   inner_mac_header;
 519         __u16                   transport_header;
 520         __u16                   network_header;
 521         __u16                   mac_header;
 522         /* These elements must be at the end, see alloc_skb() for =
details.  */
 523         sk_buff_data_t          tail;
 524         sk_buff_data_t          end;
 525         unsigned char           *head,
 526                                 *data;
 527         unsigned int            truesize;
 528         atomic_t                users;
 529 };
 530=20
