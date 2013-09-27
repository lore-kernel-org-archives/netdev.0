From: "Steinar H. Gunderson" <sesse@google.com>
Subject: Re: [PATCH net-next] net: introduce SO_MAX_PACING_RATE
Date: Fri, 27 Sep 2013 23:16:08 +0200
Message-ID: <20130927211604.GA929@imap.gmail.com>
References: <1379949014.3165.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:65085 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab3I0XUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 19:20:48 -0400
Received: by mail-wg0-f74.google.com with SMTP id k14so159205wgh.3
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 16:20:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1379949014.3165.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 08:10:14AM -0700, Eric Dumazet wrote:
> SO_MAX_PACING_RATE offers the application the ability to cap the
> rate computed by transport layer. Value is in bytes per second.

I tried this (the first version) on top of 3.12-rc2, but it doesn't actually
appear to work.

The setsockopt goes through:

  [pid 30501] setsockopt(11, SOL_SOCKET, 0x2f /* SO_??? */, [1920000], 4) = 0

And the fq scheduler is active on the machine:

  pannekake:~> sudo tc qdisc
  qdisc fq 8001: dev eth0 root refcnt 2 limit 10000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140 

Yet the packets come out way too close on the wire, as measured by tcpdump
(I have tso/gso off):  

  23:11:13.687773 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 706316:707764, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687787 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 707764:709212, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687793 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 709212:710660, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687799 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 710660:712108, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687804 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 712108:713556, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687809 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 713556:715004, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687814 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 715004:716452, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687819 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 716452:717900, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687825 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 717900:719348, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687830 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 719348:720796, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687835 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 720796:722244, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687840 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 722244:723692, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687845 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 723692:725140, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687850 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 725140:726588, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687855 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 726588:728036, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687860 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 728036:729484, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687864 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 729484:730932, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687869 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 730932:732380, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687874 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 732380:733828, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687878 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 733828:735276, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687883 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 735276:736724, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687888 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 736724:738172, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687893 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 738172:739620, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687902 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 739620:741068, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.687921 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 741068:742516, ack 1, win 114, options [nop,nop,TS val 5666415 ecr 46581981], length 1448
  23:11:13.688818 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 742516:743964, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.688833 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 743964:745412, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.689780 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 745412:746860, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.689794 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 746860:748308, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.690647 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 748308:749756, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.690660 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 749756:751204, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.691493 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 751204:752652, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.691505 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 752652:754100, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448
  23:11:13.692299 IP 193.35.52.50.9094 > 178.83.234.79.51249: Flags [.], seq 754100:755548, ack 1, win 114, options [nop,nop,TS val 5666416 ecr 46581981], length 1448

/* Steinar */
-- 
Software Engineer, Google Switzerland
