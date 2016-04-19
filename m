From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Tue, 19 Apr 2016 05:19:04 -0700
Message-ID: <1461068344.10638.167.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
	 <1461019569-3037369-5-git-send-email-kafai@fb.com>
	 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4A53D7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32894 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbcDSMTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 08:19:06 -0400
Received: by mail-pf0-f170.google.com with SMTP id 184so6522004pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 05:19:05 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4A53D7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 09:47 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 19 April 2016 00:18
> ...
> > MSG_EOR should not depend on SKBTX_ANY_TSTAMP
> > 
> > Really, simply using send(fd, ..., len, MSG_EOR) should instruct TCP to
> > mark the cooked skb as a non candidate for future coalescing.
> 
> Isn't that very similar to the inverse of MSG_MORE?

Yes. But not specifying MSG_MORE does not mean we want to force send
tiny packets. TCP is allowed to aggregate since it is a stream protocol,
since it reduces overhead.

> Or a send with Nagle disabled?

No.  tcp_sendmsg() still can coalesce/aggregate data to the last packet
in write queue, if it was not yet sent, regardless of Nagle.

If you enable or disable Nagle, following command will only send first
packets with 724 bytes, but following ones will be very big.

netperf -t TCP_STREAM -- -m 724

05:16:53.707778 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [S], seq 711876787, win 29200, options [mss 1460,sackOK,TS val 320048472 ecr 0,nop,wscale 7], length 0
05:16:53.707908 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [S.], seq 2592965917, ack 711876788, win 28960, options [mss 1460,sackOK,TS val 23660532 ecr 320048472,nop,wscale 7], length 0
05:16:53.708001 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 0
05:16:53.708045 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 1:725, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 724
05:16:53.708053 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 725, win 238, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708083 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 725:2173, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 1448
05:16:53.708097 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 2173, win 261, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708094 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 2173:3621, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 1448
05:16:53.708107 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 3621, win 283, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708132 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 3621:6517, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 2896
05:16:53.708133 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 6517:7965, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 1448
05:16:53.708148 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 6517, win 329, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708152 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 7965, win 351, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708157 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 7965:10861, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 2896
05:16:53.708165 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 10861, win 396, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708168 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 10861:12309, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 1448
05:16:53.708177 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 12309, win 419, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708220 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], seq 12309:16653, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 4344
05:16:53.708240 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 16653, win 487, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708335 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 16653:28237, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 11584
05:16:53.708378 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 28237, win 668, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708453 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 28237:42717, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 14480
05:16:53.708496 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 42717, win 894, options [nop,nop,TS val 23660532 ecr 320048473], length 0
05:16:53.708537 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], seq 42717:49957, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 7240
05:16:53.708585 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 49957:57197, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 7240
05:16:53.708641 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 49957, win 1007, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.708651 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 57197, win 1120, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.708806 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 57197:83261, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660532], length 26064
05:16:53.708836 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 83261, win 1528, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.708944 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], seq 83261:97741, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660533], length 14480
05:16:53.708967 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 97741, win 1754, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.709005 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], seq 97741:104981, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660533], length 7240
05:16:53.709036 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 104981:109325, ack 1, win 229, options [nop,nop,TS val 320048473 ecr 23660533], length 4344
05:16:53.709058 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 104981, win 1867, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.709065 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 109325, win 1924, options [nop,nop,TS val 23660533 ecr 320048473], length 0
05:16:53.709251 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 109325:135389, ack 1, win 229, options [nop,nop,TS val 320048474 ecr 23660533], length 26064
05:16:53.709332 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [.], seq 135389:141181, ack 1, win 229, options [nop,nop,TS val 320048474 ecr 23660533], length 5792
05:16:53.709423 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 135389, win 1924, options [nop,nop,TS val 23660533 ecr 320048474], length 0
05:16:53.709434 IP 10.246.7.151.42681 > 10.246.7.133.37427: Flags [.], ack 141181, win 1924, options [nop,nop,TS val 23660533 ecr 320048474], length 0
05:16:53.709730 IP 10.246.7.133.37427 > 10.246.7.151.42681: Flags [P.], seq 141181:191861, ack 1, win 229, options [nop,nop,TS val 320048474 ecr 23660533], length 50680

Using MSG_EOR on the send(fd, buffer, 724, MSG_EOR) would force TCP to
send tiny datagrams and not big GSO/TSO packets.
