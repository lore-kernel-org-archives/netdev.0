From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Thu, 22 Feb 2007 15:14:27 +0300
Message-ID: <20070222121427.GA29455@2ka.mipt.ru>
References: <20070216161045.GA2371@2ka.mipt.ru> <20070216102914.7d4b34f0@freekitty> <20070216183426.GA3138@2ka.mipt.ru> <20070221.224543.95508003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45800 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945983AbXBVMPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 07:15:14 -0500
Content-Disposition: inline
In-Reply-To: <20070221.224543.95508003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 10:45:43PM -0800, David Miller (davem@davemloft.net) wrote:
> POLLHUP is a complete mess, because it means different things on
> different kinds of fds.  And exactly, because it is not maskable,
> this makes it totally useless for sockets.

POLLHUP does show that socket can not be used for transfer, that is what
select() expects to receive. Given select() semantic and the fact, that
socket error is cleared, there is no simple way to say that socket is
not suitable for output - actually not - all reset events ends up with
tcp_done() which marks socket as close, so if in polling time we have
closed socket, it can be considered as error and thus we can add POLLERR
into the mask - so we can extend following code in poll:

if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
	mask |= POLLHUP;

to

if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
	mask |= POLLHUP | (sk->sk_state == TCP_CLOSE)?POLLERR:0;


Thoughts?

-- 
	Evgeniy Polyakov
