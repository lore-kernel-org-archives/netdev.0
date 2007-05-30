From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 21:48:22 +0200
Message-ID: <465DD506.4000503@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465DC4CD.9080801@hartkopp.net> <465DCD90.9070103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:58901 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536AbXE3Tsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 15:48:39 -0400
In-Reply-To: <465DCD90.9070103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>
>>> (..)
>>> Qdiscs might change skb->cb. Maybe use skb->sk?
>>>
>>>       
>> The loopback functionality in CAN is a bit tricky (maybe you can take a
>> look into the Documentation patch [7/7] at chapter 3.2 and 4.1.4).
>>
>> The problem is, that we need a per socket(!) option that enables the
>> loopback for the sent CAN-Frames or not, so the information about
>> loopback a skb content or not is contained inside the skb sent down to
>> the CAN netdevice. If the CAN networkdevice is not capable to perform a
>> loopback itself (see dev->flags, chapter 6) the CAN core has to do the
>> loopback as a fallback.
>>     
>
>
> skb->sk should work fine for a per socket option. In fact the
> CAN core patch simply sets skb->cb to skb->sk.
>
>   
>> The use of skb->cb is also needed in the receive path to recognize and
>> trash loopback'ed CAN-frames inside the *originating* socket (see
>> chapter 4.1.4).
>>     
>
>
> skb->sk should work here as well since you detect these frames
> before queueing to the receiving socket.
>   

Hm - this would indeed be much nicer than using skb->cb.

I think we just had some concerns to use skb->sk for our own
functionality, as it might be used and dereferenced by other layers
between the socket and the network driver ... so setting skb->sk to NULL
(to indicate 'no loopback') smells bad if you don't really know who ever
dereferences skb->sk.

Btw. it's really worth to look at it again. I just had the idea to
access the loopback flag via skb->sk->opt->loopback (argpfl!) on the TX
path and skb->sk on the RX path. This would avoid skb->sk to be set to
NULL but need to have this loopback flag to be implemented in each CAN
socket opt.

I'll discuss this with Urs tomorrow morning, which change would be the
best and also the 'safest' solution here.

Thanks for your contribution!

Oliver


