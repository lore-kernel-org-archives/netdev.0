From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 05 Nov 2009 14:37:08 +0100
Message-ID: <4AF2D504.5040804@simula.no>
References: <6980f83370cc081eb82dc2e0bd65bcf4.squirrel@webmail.uio.no> <4AEB2362.5060601@hp.com> <4AEB2C55.7040208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:53494 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521AbZKENhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 08:37:14 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N62Wc-00009B-EV
	for netdev@vger.kernel.org; Thu, 05 Nov 2009 14:37:18 +0100
In-Reply-To: <4AEB2C55.7040208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
>> Further blue-skying...
>>
>> If SACK were also enabled, it would seem that only loss of the last
>> segment in the "thin train" would be an issue?  Presumably, the thin
>> stream receiver would be in a position to detect this, perhaps with an
>> application-level timeout. Whether then it would suffice to allow the
>> receiving app to make a setsockopt() call to force an extra ACK or two
>> I'm not sure.  Perhaps if the thin-stream had a semi-aggressive
>> "heartbeat" going...
>>
> Heartbeats are the usual solution for gaming.  Handles a host of
> issues, including detection of clients that have become unreachable.
> 
> (No, these are not the same as TCP keep-alives.)
>
> Beside my code in the field and widespread discussion, I know that Paul
> Francis had several related papers a decade or so ago.  My memory is that
> younger game coders weren't particularly avid readers....
>
>> But it does seem that it should be possible to deal with this sort of
>> thing without having to make wholesale changes to TCP's RTO policies
>> and whatnot?
>>
> Yep.

We recognise the possibility of increasing the aggressiveness of application 
send rate in order to counteract the effect of thin streams on retransmission 
latency. Applications are by nature uninformed about the state of the layers 
below. To work around the fast-retransmit latency problems, an application 
would have to keep a very aggressive heartbeat rate even though there is no 
data to send, thus spamming the network with unneeded traffic.

To exemplify this, let's choose an SSH session from this set of statistics:
http://folk.uio.no/apetlund/lktmp/thin_apps_table.pdf. This thin stream has 
an averge packet interarrival time of 323ms. The application developer would 
have to consider how many "duds" to send in order to ensure a low 
retransmission latency. Let's say he considers RTTs lower than 60ms harmless, 
he would need to send more than 4 packets per 60ms. This would mean a 
heartbeat rate of one packet each 15ms. Considering this, the aggressively 
heartbeated application would send 67 packets per second compared to 3 in 
the original stream.

By including thin-stream semantics into the TCP code, informed decisions 
can be made to minimise the overhead while still reducing the retransmission 
latency.

Best regards,
Andreas


