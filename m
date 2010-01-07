From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 19:36:08 -0800 (PST)
Message-ID: <20100106.193608.193693425.davem@davemloft.net>
References: <20100106.150453.186399201.davem@davemloft.net>
	<20100106.161454.193705075.davem@davemloft.net>
	<20100106.192131.193700514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756708Ab0AGDgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 22:36:01 -0500
In-Reply-To: <20100106.192131.193700514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Jan 2010 19:21:31 -0800 (PST)

> And maybe that's a clue, because with this upstream Linux does ACK the
> probe.

Here's an example trace, note the DSACK blocks:

19:26:51.966289 IP A.34376 > B.330: . ack 22738433 win 0 <nop,nop,timestamp 4294964458 375470>
19:26:52.185946 IP B.330 > A.34376: . 22738432:22738433(1) ack 10753 win 127 <nop,nop,timestamp 375492 4294964458>
19:26:52.207848 IP A.34376 > B.330: . ack 22738433 win 0 <nop,nop,timestamp 4294964480 375492,nop,nop,sack 1 {22738432:22738433}>
19:26:52.645946 IP B.330 > A.34376: . 22738432:22738433(1) ack 10753 win 127 <nop,nop,timestamp 375538 4294964480>
19:26:52.668386 IP A.34376 > B.330: . ack 22738433 win 0 <nop,nop,timestamp 4294964526 375538,nop,nop,sack 1 {22738432:22738433}>
19:26:53.545949 IP B.330 > A.34376: . 22738432:22738433(1) ack 10753 win 127 <nop,nop,timestamp 375628 4294964526>
19:26:53.568955 IP A.34376 > B.330: . ack 22738433 win 0 <nop,nop,timestamp 4294964616 375628,nop,nop,sack 1 {22738432:22738433}>
19:26:55.328448 IP B.330 > A.34376: . 22738432:22738433(1) ack 10753 win 127 <nop,nop,timestamp 375806 4294964616>
19:26:55.351998 IP A.34376 > B.330: . ack 22738433 win 0 <nop,nop,timestamp 4294964794 375806,nop,nop,sack 1 {22738432:22738433}>

I added diagnostics to tcp_data_queue() to validate which conditional
triggers:

[  662.808884] TCP: HIT SYN[0] FIN[0] ACK[1] SEQ[a018c50f:a018c510] rcv_nxt[a018c510] rcv_wup[a018c510] window[00000000]
[  662.822532] TCP: tcp_data_queue() !after(end_seq, rcv_nxt)

Which is what I said should trigger for these things.
