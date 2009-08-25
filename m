From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 12:11:03 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com>
 <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:40425 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751690AbZHYQLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:11:38 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7B5D582CE23
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:12:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HPotGJu2fZlC for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 12:12:33 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F0B7282CFE0
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:12:08 -0400 (EDT)
In-Reply-To: <4A940A10.60607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Eric Dumazet wrote:

> It wont be very nice, because it'll add yet another 32bits counter in each socket
> structure, for a unlikely use. While rx_drops can happen if application is slow.

tx_drops happen if the application sends too fast.

TX drop tracking is important due to the braindamaged throttling logic
during send. If SO_SNDBUF is less than what happens to fit in the TX ring then the
application will be throttled and no packet loss happens. If SO_SNDBUF is
set high then the TX ring will overflow and packets are dropped.

We need some way to diagnose TX drops per socket as long as we have
that mind boggling issue. TX drops means that one should reduce the size
of the sendbuffer in order to get better throttling which reduces packet
loss.

> Also, tx_drops might be done later and not noticed.
>
> Please read this old (and usefull) thread, with Alexey words...
>
> http://oss.sgi.com/archives/netdev/2002-10/msg00612.html
>
> http://oss.sgi.com/archives/netdev/2002-10/msg00617.html
>
>
> So I bet your best choice is to set IP_RECVERR, as mentioned in 2002 by Jamal and Alexey :)

I read this just yesterday. IP_RECVERR means that the application wants to
see details on each loss. We just want some counters that give us accurate
statistics to gauge where packet loss is occurring. Applications are
usually not interested in tracking the fate of each packet.

