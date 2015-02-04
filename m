From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of
 thousands of packets / sec)
Date: Wed, 04 Feb 2015 04:20:31 -0800
Message-ID: <1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	 <1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Avery Fay <avery@mixpanel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:56882 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964947AbbBDMUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 07:20:32 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so1436443ier.10
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 04:20:32 -0800 (PST)
In-Reply-To: <CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 00:35 -0800, Avery Fay wrote:
> Sure, https://dl.dropboxusercontent.com/u/9777748/loop.pcap.gz

Nice, something is really broken on this peer (not a linux one for
sure), or some really buggy middlebox.

The strange [P.] frame with no payload has a wrong sequence number
anyway, so we send back a duplicate ack.

  1   0.000000 128.61.57.205 -> 174.36.240.86 TCP 74 34574 > https [SYN] Seq=0 Win=65535 Len=0 MSS=1380 SACK_PERM=1 TSval=3985707 TSecr=0 WS=256
  2   0.000008 174.36.240.86 -> 128.61.57.205 TCP 74 https > 34574 [SYN, ACK] Seq=0 Ack=1 Win=28960 Len=0 MSS=1460 SACK_PERM=1 TSval=3311875276 TSecr=3985707 WS=128
  3   0.019057 128.61.57.205 -> 174.36.240.86 TCP 66 34574 > https [ACK] Seq=1 Ack=1 Win=87808 Len=0 TSval=3985710 TSecr=3311875276
  4   0.019111 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 3#1] 34574 > https [ACK] Seq=1 Ack=1 Win=87808 Len=0 TSval=3985710 TSecr=3311875276
  5   0.037637 128.61.57.205 -> 174.36.240.86 SSL 292 Client Hello
  6   0.037644 174.36.240.86 -> 128.61.57.205 TCP 66 https > 34574 [ACK] Seq=1 Ack=227 Win=30080 Len=0 TSval=3311875285 TSecr=3985712
  7   0.037699 174.36.240.86 -> 128.61.57.205 TLSv1.2 2802 Server Hello
  8   0.037706 174.36.240.86 -> 128.61.57.205 TLSv1.2 585 Certificate
  9   0.074710 174.36.240.86 -> 128.61.57.205 TCP 585 [TCP Retransmission] https > 34574 [PSH, ACK] Seq=2737 Ack=227 Win=30080 Len=519 TSval=3311875295 TSecr=3985712[Reassembly error, protocol TCP: New fragment overlaps ol
d data (retransmission?)]
 10   0.294707 174.36.240.86 -> 128.61.57.205 TLSv1.2 1434 [TCP Retransmission] Server Hello
 11   0.734711 174.36.240.86 -> 128.61.57.205 TLSv1.2 1434 [TCP Retransmission] Server Hello
 12   1.614707 174.36.240.86 -> 128.61.57.205 TLSv1.2 1434 [TCP Retransmission] Server Hello
 13   3.378705 174.36.240.86 -> 128.61.57.205 TLSv1.2 1434 [TCP Retransmission] Server Hello
 14   6.910707 174.36.240.86 -> 128.61.57.205 TLSv1.2 1434 [TCP Retransmission] Server Hello
 15  10.097427 128.61.57.205 -> 174.36.240.86 TCP 66 34574 > https [FIN, ACK] Seq=227 Ack=1 Win=87808 Len=0 TSval=3986717 TSecr=3311875285
 16  10.097456 174.36.240.86 -> 128.61.57.205 TCP 66 https > 34574 [FIN, ACK] Seq=3256 Ack=228 Win=30080 Len=0 TSval=3311877800 TSecr=3986717
 17  10.111945 128.61.57.205 -> 174.36.240.86 TCP 78 [TCP Dup ACK 15#1] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276 SLE=3256 SRE=3256
 18  10.111950 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#1] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877804 TSecr=3986717
 19  10.111952 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 15#2] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276
 20  10.111955 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#2] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877804 TSecr=3986717
 21  10.126312 128.61.57.205 -> 174.36.240.86 TCP 86 [TCP Dup ACK 15#3] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276 SLE=3257 SRE=3257 SLE=3256 SRE=3256
 22  10.126317 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#3] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877807 TSecr=3986717
 23  10.126360 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 15#4] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276
 24  10.126362 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#4] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877807 TSecr=3986717
 25  10.126364 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 15#5] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276
 26  10.126365 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#5] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877807 TSecr=3986717
 27  10.126366 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 15#6] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276
 28  10.126367 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#6] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877807 TSecr=3986717
 29  10.140709 128.61.57.205 -> 174.36.240.86 TCP 66 [TCP Dup ACK 15#7] 34574 > https [PSH, ACK] Seq=228 Ack=1 Win=87808 Len=0 TSval=3985712 TSecr=3311875276
 30  10.140714 174.36.240.86 -> 128.61.57.205 TCP 66 [TCP Dup ACK 16#7] https > 34574 [ACK] Seq=3257 Ack=228 Win=30080 Len=0 TSval=3311877811 TSecr=3986717

Neal patches definitely would solve this issue.
