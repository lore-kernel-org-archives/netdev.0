From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Tue, 28 Sep 2010 11:26:52 +0200
Message-ID: <20100928092652.GA28378@1wt.eu>
References: <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net> <20100927073443.GR12373@1wt.eu> <alpine.LFD.2.00.1009271159070.2191@u.domain.uli> <20100927192450.GU12373@1wt.eu> <alpine.LFD.2.00.1009281139430.1506@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45762 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab0I1J07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 05:26:59 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1009281139430.1506@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

On Tue, Sep 28, 2010 at 12:01:42PM +0300, Julian Anastasov wrote:
> 	I think for another option but I don't know the TCP details
> well:
> 
> - If SO_RCVBUF=0 really closes RX window

I've been wondering what happens to an incoming data after the RX window
is closed. Is the packet just dropped or may it still be queued. In fact,
my concerns are : if SO_RCVBUF=0 just advertises a zero window, we can
only be sure about the flush after an RTT. However, if it really prevents
the receive side from accepting new data, then I agree we're safe.

> and
> 
> - while (read() > 0) {} gets all unread data

During my tests on other products, I found that squid does that without
the zero window, possibly resulting in an infinite loop when the sender
is faster than the receiver. In our case, if the zero window works, it
should not be an issue.

> - just call close() to convert socket to orphan without a risk
> of RST
> 
> 	Now when we are orphan socket I'm not sure what has
> priority:
> 
> - if new DATA is flying to us, is it considered out of window,
> do we send RST in FIN_WAIT1/CLOSING/LAST_ACK state in this case?
> If we do not send RST then our goal is achieved: send everything
> reliably without accepting data that needs RST. And we do not
> need to keep fd in user space.

>From what I have observed, the issue is only for data present before
the close. Upon FIN_WAIT1/CLOSING/LAST_ACK, we get the expected reset
once the ACK acknowledges the last data sent, but I've not observed
it for new data.

Best regards,
Willy

