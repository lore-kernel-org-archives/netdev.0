From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Enforce maximum retransmissions during shutdown
Date: Wed, 29 Jun 2011 10:58:41 -0400
Message-ID: <4E0B3DA1.9060200@hp.com>
References: <20110629135704.GB10085@canuck.infradead.org> <4E0B3491.1060603@hp.com> <20110629143649.GC10085@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:4656 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab1F2O6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:58:47 -0400
In-Reply-To: <20110629143649.GC10085@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2011 10:36 AM, Thomas Graf wrote:
> On Wed, Jun 29, 2011 at 10:20:01AM -0400, Vladislav Yasevich wrote:
>> I think in this particular case, the receiver has to terminate, not the sender.
>> Look at how tcp_close() handles this.
>>
>> As long as receiver is available, the sender should continue to try
>> sending data.
> 
> The receiver does not know that the sender wishes to shutdown the
> association. No shutdown request has been sent yet.
> 
> I don't think we should be relying on the behaviour of the sender for
> the receiver to be able to ever free its ressources. We will be
> retransmitting data and keeping an association alive _forever_ for no
> purpose.
> 
> If there is no reliable way of _ever_ doing a graceful shutdown then
> the only alternative is to just ABORT in the first place.
> 
> The difference in TCP is that we can close the connection half-way,
> something we can't do in sctp.
> 

But what you are proposing violates the protocol.  Zero-window probes do
not count against max retransmissions, even when you are in shutdown pending
state.

You'll come out of this one of 2 ways:
  1) receiver wakes up and processes data.  This will allow for graceful termination.
  2) receiver dies.  Since receive window is full, we have data queued, and this will
     trigger an ABORT to be sent to the sender.

What you patch is doing is taking a perfectly valid scenario and putting a time limit
on it in violation of the spec.

-vlad
