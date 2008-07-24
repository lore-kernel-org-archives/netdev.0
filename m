From: Willy Tarreau <w@1wt.eu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 09:33:14 +0200
Message-ID: <20080724073313.GA16604@1wt.eu>
References: <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com> <20080722135723.GA23077@elte.hu> <4885F496.3010305@davidnewall.com> <20080722153443.GB18757@elte.hu> <20080722211256.GB29189@1wt.eu> <20080723082643.GA992@elte.hu> <20080724060448.GA10203@elte.hu> <20080724063242.GA9051@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	David Newall <davidn@davidnewall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1940 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883AbYGXHem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 03:34:42 -0400
Content-Disposition: inline
In-Reply-To: <20080724063242.GA9051@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 08:32:42AM +0200, Ingo Molnar wrote:
> 
> here's a longer log from the server, with sequences, flags, etc:

good. The sequence numbers from dione to phoenix are bouncing back and
forth because a big data chunk was lost, so dione is alternatively
sending and old segment (retransmit) which, when ACKed, allows it to
slide the window forward and send one more chunk from the window tip.

> 08:06:47.809947 IP (tos 0x0, ttl 64, id 13998, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234555110:234555646(536) ack 2272574194 win 5840
> 08:06:47.809974 IP (tos 0x0, ttl 64, id 27389, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x9900 (correct), 2272574194:2272574194(0) ack 234555646 win 65535
> 08:06:47.810051 IP (tos 0x0, ttl 64, id 13999, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234620645:234621181(536) ack 2272574194 win 5840
> 08:06:47.810065 IP (tos 0x0, ttl 64, id 27390, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x9900 (correct), 2272574194:2272574194(0) ack 234555646 win 65535
> 08:08:47.829813 IP (tos 0x0, ttl 64, id 14000, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234555646:234556182(536) ack 2272574194 win 5840
> 08:08:47.829909 IP (tos 0x0, ttl 64, id 27391, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x96e8 (correct), 2272574194:2272574194(0) ack 234556182 win 65535
> 08:08:47.830009 IP (tos 0x0, ttl 64, id 14001, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234621181:234621717(536) ack 2272574194 win 5840
(...)
> 08:30:48.049167 IP (tos 0x0, ttl 64, id 14022, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234561256:234561792(536) ack 2272574194 win 5840
> 08:30:48.049223 IP (tos 0x0, ttl 64, id 27413, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> 08:30:48.049341 IP (tos 0x0, ttl 64, id 14023, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234626648:234627184(536) ack 2272574194 win 5840
> 08:30:48.049348 IP (tos 0x0, ttl 64, id 14024, offset 0, flags [DF], proto TCP (6), length 183) dione.39201 > phoenix.distcc: . 234627184:234627327(143) ack 2272574194 win 5840

here it looks like dione believes it does not have the chunk starting
at 234561792. Maybe it moved its window too far ? It only sends the
tip of the window.

> 08:30:48.049354 IP (tos 0x0, ttl 64, id 27414, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> 08:30:48.049359 IP (tos 0x0, ttl 64, id 27415, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535

And phoenix insists on getting what is missing from the window.

So dione is wrong here.

Regards,
Willy

