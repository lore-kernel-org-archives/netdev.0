From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH] net: remove sock_iocb
Date: Thu, 29 Jan 2015 12:13:46 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C3687B8@eusaamb103.ericsson.se>
References: <1422464693-7827-1-git-send-email-hch@lst.de>
	<20150128.232211.1157376728217761804.davem@davemloft.net>
	<20150129075721.GD29656@ZenIV.linux.org.uk>
 <20150129.000125.1532086382063848714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hch@lst.de" <hch@lst.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:59147 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbbA2MOC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 07:14:02 -0500
In-Reply-To: <20150129.000125.1532086382063848714.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: January-29-15 3:01 AM
> To: viro@ZenIV.linux.org.uk
> Cc: hch@lst.de; netdev@vger.kernel.org
> Subject: Re: [PATCH] net: remove sock_iocb
> 
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Thu, 29 Jan 2015 07:57:21 +0000
> 
> > You know, that's getting _really_ interesting.  The thing is, now
> > there's only one ->sendmsg() instance using iocb argument at all, and
> > it's a really weird one.  TIPC.  Which only compares it with NULL, and
> > that - to tell the normal calls (== done by sock_sendmsg()
> > et.al.) from tipc_{accept,connect}()-generated ones.  And the way it's
> > used is
> >         if (iocb)
> >                 lock_sock(sk);
> > in tipc_send_stream().  IOW, "tipc_accept() and tipc_connect() would
> > like to use the guts of tipc_send_stream(), but they are already
> > holding the socket locked; let's just pass NULL iocb (which
> > net/socket.c never does) to tell it to leave the fucking lock alone, thank you
> very much".
> >
> > And no ->recvmsg() are using iocb at all now.  How about we take the
> > guts of tipc_send_stream() into a helper function and have
> > tipc_accept/connect use _that_? 

Sounds reasonable. We'll look into this.

///jon

 Then we could drop iocb argument
> > completely and for ->sendmsg() it would be the difference between 4
> > and 3 arguments, which has interesting effects on certain register-starved
> architectures...
> >
> > While we are at it, size (both for sendmsg and recvmsg) is always
> > equal to iov_iter_count(&msg->msg_iter), so that's not the only
> > redundant argument there...
> 
> No objections from me.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
