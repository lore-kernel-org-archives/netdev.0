From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Tue, 28 Sep 2010 12:01:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1009281139430.1506@ja.ssi.bg>
References: <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net> <20100927073443.GR12373@1wt.eu> <alpine.LFD.2.00.1009271159070.2191@u.domain.uli>
 <20100927192450.GU12373@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57498 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753707Ab0I1JCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 05:02:16 -0400
In-Reply-To: <20100927192450.GU12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Mon, 27 Sep 2010, Willy Tarreau wrote:

>> - add this FD in some list for monitoring instead of keeping
>> large connection state
>> - use shutdown SHUT_WR to add FIN after response
>> - use setsockopt SO_RCVBUF with some low value to close the
>> RX window, we do not want the body
>> - wait for POLLHUP (FIN), not for POLLIN because we want to
>> ignore data, not to read it. Still, data can be read and
>> dropped if needed to release the socket memory
>> - use timer to limit the time we wait our data to be acked
>> - use SIOCOUTQ to know if everything is received in peer and
>> then close the fd
>
> Thanks very much for this suggestion. I was looking for something
> like this and even looked at the tcp_info struct, but it did not
> look very easy to use.
>
> Still, I think that polling on POLLIN and checking with SIOCOUTQ
> on every read to see if the out queue is now empty would do the
> trick, without forcing to read huge amounts of unnecessary data.
>
> I'll simply enclose that inside a #ifdef LINUX and that should be
> OK. It kinda sucks to be able to workaround low level issues at the
> application level but at least this workaround is acceptable.

 	I think for another option but I don't know the TCP details
well:

- If SO_RCVBUF=0 really closes RX window

and

- while (read() > 0) {} gets all unread data

- just call close() to convert socket to orphan without a risk
of RST

 	Now when we are orphan socket I'm not sure what has
priority:

- if new DATA is flying to us, is it considered out of window,
do we send RST in FIN_WAIT1/CLOSING/LAST_ACK state in this case?
If we do not send RST then our goal is achieved: send everything
reliably without accepting data that needs RST. And we do not
need to keep fd in user space.

Regards

--
Julian Anastasov <ja@ssi.bg>
