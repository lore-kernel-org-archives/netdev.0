From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] truesize lies
Date: Sun, 09 Oct 2011 21:02:28 +0200
Message-ID: <1318186948.5276.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54724 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab1JITCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 15:02:34 -0400
Received: by wyg34 with SMTP id 34so5282900wyg.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 12:02:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed on my laptop a difference if I use wifi or wired internet
connectivity.

On wifi mode, I can see netstat -s giving sign of bad rcvbuf tuning :

   371 packets collapsed in receive queue due to low socket buffer

After some analysis, I found full sized tcp skbs (len=1440) had a 2864
bytes truesize on my wifi adapter. Ouch...

On tg3 adapter, truesize is MTU + NET_SKB_PAD + sizeof(sk_buff).

On some devices (say... NIU, but other drivers have same problem :
bnx2x, ), truesize is sizeof(sk_buff) + frame_length.

So if 'truesize' really means to account exact memory cost of frames
(including the empty space after used part), I would say :

1) NIU is lying (it should account in niu_rx_skb_append() not the used
part of the page, but reserved part : PAGE_SIZE/rbr_blocks_per_page)

2) Autotuning is a bit pessimistic : It works only if truesize is MSS +
sizeof(sk_buff) + 16 + MAX_TCP_HEADER


I guess most driver writers adjust truesize to please TCP stack and get
nice performance numbers.

skb->truesize = frame_len + sizeof(sk_buff);

What should we do exactly ?
