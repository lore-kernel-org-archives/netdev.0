From: YANG Zhe <yangzhe1990@gmail.com>
Subject: sched: scatter-gathering and generic-receiving-offloading features in
 network driver break the rate limiting/shaping.
Date: Thu, 9 Aug 2012 21:56:05 +0800
Message-ID: <CANvbpLSdECzm+C1fZ4UBmQQvG+ocncqaTAWasKhruKvttBZEfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56744 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262Ab2HIN4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 09:56:05 -0400
Received: by pbbrr13 with SMTP id rr13so949532pbb.19
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 06:56:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

When these options is on, kernel sends/receives skb with length
greater than normal (1500 + link-layer overhead). It's because several
consecutive TCP segments is merged into a single large skb, and the
network card is responsible for splitting/merging it. For example:
http://i.imgur.com/wnv98.png , http://i.imgur.com/WPwjE.png .

Some scheduler my drop the packet because its qdisc_skb_len() is large
than its max_size(buffer/tokens), which implies that the scheduler
can't send this packet at once, so that it must be dropped on
enqueue()ing. The qdisc_rate_table used in calculation of consumed
time also fails because of its small size (u32[256]). Since the only
limit of the skb is the 64k limitation on ip_totlen, if we keep using
the u32[256] table, the cell_log would be quite large hence the time
calculation would be quite inaccurate.

Also, when calculating the time to send the merged skb, it's better to
calculate how many packets it will break into, however it may not be
accurate because of different MSS in different stream. Some weird
packet which should be fragmented on the IP layer may also have larger
size than normal and it's total size after breaking down is also
different.

I would recommend that token based scheduler should allow deficit, and
redesign the rate table, maybe leave some information in the skb to
indicate whether it is a gathered packet.

Thanks!

-- 
Sincerely,
    Yang Zhe
