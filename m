From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 01 May 2007 13:54:03 -0400
Message-ID: <46377EBB.6080604@psc.edu>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:61924 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185AbXEAR7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 13:59:09 -0400
In-Reply-To: <20070501164935.GC1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise wrote:
>> According to your patch, several packets with fin bit might be sent,
>> including one with data. If another host does not receive fin
>> retransmit, then that logic is broken, and it can not be fixed by
>> duplicating fins, I would even say, that remote box should drop second
>> packet with fin, while it can carry data, which will break higher
>> connection logic.
> 
> The FIN hasn't been ack'd by the other side, though and yet Linux is no 
> longer transmitting packets with it sent.  Read the beginning of the trace.

I agree completely with Evgeniy.  The patch you sent would cause bad 
breakage by sending the FIN bit on segments with different sequence numbers.

Looking at your trace, it seems like the behavior of the test system 
192.168.2.2 is broken in two ways.  First, like you said it has broken 
state in that it has forgotten that it sent the FIN.  Once you do that, 
the connection state is corrupt and all bets are off.  It's sending an 
out-of-window segment that's getting tossed by Linux, and Linux 
generates an ack in response.  This is in direct RFC compliance.  The 
second problem is that the other system is generating these broken acks 
in response to the legitimate acks Linux is sending, causing the ack 
war.  I can't really guess why it's doing that...

You might be able to change Linux to prevent this ack war, but doing so 
would break RFC compliance, and given the buggy nature of the other end, 
it sounds to me like a bad idea.

   -John
