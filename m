From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: Always cleanup skb before sending
Date: Wed, 01 Nov 2017 19:21:31 -0700
Message-ID: <1509589291.2849.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171101211001.57901-1-cpaasch@apple.com>
         <CANn89iLv+0+A79-pNu8HZ2kBbyNt2ini2Zjbm++s9TT7mtOamw@mail.gmail.com>
         <1509573218.3828.54.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171102001035.GR44287@da0602a-dhcp105.apple.com>
         <1509584410.3828.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:56802 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdKBCVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 22:21:33 -0400
Received: by mail-pf0-f182.google.com with SMTP id b85so3407427pfj.13
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 19:21:33 -0700 (PDT)
In-Reply-To: <1509584410.3828.64.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 18:00 -0700, Eric Dumazet wrote:
> On Wed, 2017-11-01 at 17:10 -0700, Christoph Paasch wrote:
> 
> > Yes, that looks good to me. Thanks!
> > 
> > But we still need to clean up the skb in tcp_v4_send_reset and
> > tcp_v4_send_ack, as the fields (e.g., tcp_skb_cb->seq) have been set when
> > coming from tcp_v4_rcv.
> 
> You might be confused : ip_send_unicast_reply() does not send back the
> incoming skb.
> 
> A fresh skb is allocated, then appended/sent.
> 
> And commit 24a2d43d8886f5a29c did the changes to provide to
> __ip_options_echo() the proper IPCB header location.
> 

More details :

Fields written by tcp_init_nondata_skb() on the synack packet :

->seq          (32bits) at offset 0 of skb->cb[]
->end_seq      (32bits) at offset 4 of skb->cb[]
->tcp_gso_segs (16bits) at offset 8
->tcp_flags    (8bits) at offset 12 value (TCPHDR_SYN | TCPHDR_ACK ->
0x12)
->sacked       (8bits) at offset 13

IPCB fields sharing these 14 bytes :

iif  /* 32bits, offset 0 */
opt.faddr    (32bits) offset 4
opt.nexthop  (32bits) offset 8 /* value 1 */
opt.optlen   (8bits) offset 12 /* value 0x12 */
opt.srr      (8bits) offset 13

IP6CB fields sharing these 14 bytes :

iif   /* 32bits, offset 0 */
ra    /* 16 bits, offset 4 */
dst0  /* 16 bits offset 6 */
srcrt /* 16 bits offset 8 */  -> 0x0001
dst1  /* 16 bits offset 10 */ (not mangled -> 0)
lastopt /* 16 bits offset 12 */  -> 0x12


At xmit :

IPV4 uses ip_build_and_send_pkt() to transmit the SYNACK, so skb->cb[]
is not used.

IPv6 uses other fields.

So I really wonder what exact issue you observed, please share your
drugs ;)

Thanks !
