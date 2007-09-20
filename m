From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT
 events get missed for TCP sockets
Date: Thu, 20 Sep 2007 10:42:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709201033120.8897@alien.or.mcafeemobile.com>
References: <130356.85796.qm@web53703.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:36065 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbXITRmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 13:42:21 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S24ECF8> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 20 Sep 2007 13:42:19 -0400
In-Reply-To: <130356.85796.qm@web53703.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, Nagendra Tomar wrote:

> The tcp_check_space() function calls tcp_new_space() only if the
> SOCK_NOSPACE bit is set in the socket flags. This is causing Edge Triggered
> EPOLLOUT events to be missed for TCP sockets, as the ep_poll_callback() 
> is not called from the wakeup routine.
> 
>         The SOCK_NOSPACE bit indicates the user's intent to perform writes
> on that socket (set in tcp_sendmsg and tcp_poll). I believe the idea 
> behind the SOCK_NOSPACE check is to optimize away the tcp_new_space call
> in cases when user is not interested in writing to the socket. These two
> take care of all possible scenarios in which a user can convey his intent
> to write on that socket.
> 
> Case 1: tcp_sendmsg detects lack of sndbuf space
> Case 2: tcp_poll returns not writable
> 
> This is fine if we do not deal with epoll's Edge Triggered events (EPOLLET).
> With ET events we can have a scenario where the SOCK_NOSPACE bit is not set,
> as the user has neither done a sendmsg nor a poll/epoll call that returned
> with the POLLOUT condition not set. 

Looking back at it, I think the current TCP code is right, once you look 
at the "event" to be a output buffer full->with_space transition.
If you drop an fd inside epoll with EPOLLOUT|EPOLLET and you get an event 
(free space on the output buffer), if you do not consume it (say a 
tcp_sendmsg that re-fill the buffer), you can't see other OUT event 
anymore since they happen on the full->with_space transition.
Yes, I know, the read size (EPOLLIN) works differently and you get an 
event for every packet you receive. And yes, I do not like asymmetric 
things. But that does not make the EPOLLOUT|EPOLLET wrong IMO.



- Davide


