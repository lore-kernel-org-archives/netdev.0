From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 14:45:48 -0800
Message-ID: <1356129948.21834.8002.camel@edumazet-glaptop>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	 <1356114663.21834.7697.camel@edumazet-glaptop>
	 <CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	 <1356118052.21834.7793.camel@edumazet-glaptop>
	 <CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhiyun Qian <zhiyunq@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:46792 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2LUWpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 17:45:51 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so2312818dak.28
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 14:45:51 -0800 (PST)
In-Reply-To: <CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 14:49 -0500, Zhiyun Qian wrote:

> If I am not mistaken, line 6142 in kernel v3.7.1 corresponds to
> tcp_rcv_state_process(). According to the comments, "This function
> implements the receiving procedure of RFC 793 for all states except
> ESTABLISHED and TIME_WAIT." Are you referring to a different kernel
> version?

You are not mistaken, it seems code is too permissive.

We should reject a frame without ACK flag while in ESTABLISHED state.

Thats explicitly stated in RFC 973.

Then we should make all possible safety checks before even sending a
frame or changing socket variables.

(For instance the tests done in tcp_ack() should be done before calling
tcp_validate_incoming())

John Dykstra in commit 96e0bf4b5193d0 (tcp: Discard segments that ack
data not yet sent) did a step into right direction, but missed this.

Current code assumes the incoming frame is mostly legitimate.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a136925..2ea4937 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5551,7 +5551,7 @@ slow_path:
 		return 0;
 
 step5:
-	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
+	if (!th->ack || tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
 		goto discard;
 
 	/* ts_recent update must be made after we are sure that the packet
