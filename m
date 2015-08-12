From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Wed, 12 Aug 2015 15:33:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB7979F@AcuExch.aculab.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
 <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
 <55CB4729.2060203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>,
	"tan.hu@zte.com.cn" <tan.hu@zte.com.cn>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	"cluster-devel@redhat.com" <cluster-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:53214 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbbHLPgS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 11:36:18 -0400
In-Reply-To: <55CB4729.2060203@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 12 August 2015 14:16
> Em 12-08-2015 07:23, David Laight escreveu:
> > From: Marcelo Ricardo Leitner
> >> Sent: 11 August 2015 23:22
> >> DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
> >> needed but this causes it to use sctp_do_peeloff() to mimic an
> >> kernel_accept() and this causes a symbol dependency on sctp module.
> >>
> >> By switching it to 1-to-1 API we can avoid this dependency and also
> >> reduce quite a lot of SCTP-specific code in lowcomms.c.
> > ...
> >
> > You still need to enable sctp notifications (I think the patch deleted
> > that code).
> > Otherwise you don't get any kind of indication if the remote system
> > 'resets' (ie sends an new INIT chunk) on an existing connection.
> 
> Right, it would miss the restart event and could generate a corrupted
> tx/rx buffers by glueing parts of old messages with new ones.

Except that it is SCTP so you'd expect DATA chunks to contain entire
messages and so get unexpected message sequences rather than corrupt
messages.
The problem is that the recovery is likely to be another reset.
(Particularly with M3UA where the source and destination port numbers
are likely to be the same and fixed.)

> > It is probably enough to treat the MSG_NOTIFICATION as a fatal error
> > and close the socket.
> 
> Just so we are on the same page, you mean that after accepting the new
> association and enabling notifications on it, any further notification
> on it can be treated as fatal errors, right? Seems reasonable to me.

That's what I had to do.
The far end will probably see an additional disconnect, but it shouldn't
matter.

> > This is probably a bug in the sctp stack - if a connection is reset
> > but the user hasn't requested notifications then it should be
> > converted to a disconnect indication and a new incoming connection.
> 
> Maybe in such case resets shouldn't be allowed at all? Because unless it
> happens on a moment of silence it will always lead to application buffer
> corruption. Checked the RFCs now but couldn't find anything restricting
> them to some condition.

I certainly expected the 'reset' to cause an inwards abortive disconnect
on the old socket and a new indication on the listening socket.
I think (hope) that is what you get for a TCP SYN that matches an existing
connection.

In our case I think they were happening when the remote system was power
cycled.

	David
