From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 13:55:50 +0400
Message-ID: <20070802095550.GA27226@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: john@screen.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47361 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262AbXHBJ4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 05:56:31 -0400
Content-Disposition: inline
In-Reply-To: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 09:19:06AM +0300, john@screen.lv (john@screen.lv) wrote:
> 1186035057.207629    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [SYN]
> Seq=0 Len=0
> 1186035057.207632    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [SYN, ACK]
> Seq=0 Ack=1 Win=32792 Len=0 MSS=16396
> 1186035057.207666    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [ACK]
> Seq=1 Ack=1 Win=1500 Len=0
> 1186035057.207699    127.0.0.1 -> 127.0.0.1    SMTP Command: EHLO localhost
> 1186035057.207718    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [ACK]
> Seq=1 Ack=17 Win=32792 Len=0
> 1186035057.207736    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [RST]
> Seq=17 Len=0
> 1186035057.223934    127.0.0.1 -> 127.0.0.1    TCP 33787 > 50000 [RST,
> ACK] Seq=0 Ack=0 Win=32792 Len=0
> 
> Can someone please comment as to why, tcp  stack sends rst packet from the
> wrong source port in this situation.

Besides the fact, that test applications do not run if started not as
root, I got this:

13:51:12.180241 IP localhost.localdomain.50000 > localhost.localdomain.10250: S 906222067:906222067(0) win 1500
13:51:12.180279 IP localhost.localdomain.10250 > localhost.localdomain.50000: S 2011233747:2011233747(0) ack 906222068
win 32792 <mss 16396>
13:51:12.180293 IP localhost.localdomain.50000 > localhost.localdomain.10250: R 906222068:906222068(0) win 0
13:51:12.180320 IP localhost.localdomain.50000 > localhost.localdomain.10250: . ack 1 win 1500
13:51:12.180329 IP localhost.localdomain.10250 > localhost.localdomain.50000: R 2011233748:2011233748(0) win 0
13:51:12.180341 IP localhost.localdomain.50000 > localhost.localdomain.10250: P 1:17(16) ack 1 win 1500
13:51:12.180349 IP localhost.localdomain.10250 > localhost.localdomain.50000: R 2011233748:2011233748(0) win 0
13:51:12.180361 IP localhost.localdomain.50000 > localhost.localdomain.10250: R 906222084:906222084(0) win 1500

I.e. there is no bug in this session.
FC7 2.6.22.1-27.fc7 kernel.

Here is vanilla (with my patches, unrelated to the problem though)
2.6.22-rc5:

09:33:37.650279 IP localhost.50000 > localhost.10250: S 1326688203:1326688203(0) win 1500
09:33:37.664391 IP localhost.10250 > localhost.50000: S 3637551175:3637551175(0) ack 1326688204 win 32792 <mss 16396>
09:33:37.664417 IP localhost.50000 > localhost.10250: R 1326688204:1326688204(0) win 0
09:33:37.650451 IP localhost.50000 > localhost.10250: . ack 1 win 1500
09:33:37.650467 IP localhost.10250 > localhost.50000: R 3637551176:3637551176(0) win 0
09:33:37.650481 IP localhost.50000 > localhost.10250: P 1:17(16) ack 1 win 1500
09:33:37.650493 IP localhost.10250 > localhost.50000: R 3637551176:3637551176(0) win 0
09:33:37.650507 IP localhost.50000 > localhost.10250: R 1326688220:1326688220(0) win 1500


Is it possible that your tcpdump is screwed?

-- 
	Evgeniy Polyakov
