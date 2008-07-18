From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 20:04:44 +0300
Message-ID: <200807182004.44664.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807181850.07393.opurdila@ixiacom.com> <20080718160009.GA29740@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3504 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760553AbYGRRHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 13:07:16 -0400
In-Reply-To: <20080718160009.GA29740@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 July 2008, Evgeniy Polyakov wrote:

> > It will take 17 because this is what the user requested. And when trying
> > to push the 17th on the pipe, it will block. I base this both on
> > experiments and on my understanding of the tcp splice receive
> > implementation.
>
> Seems like we do not understand each other. How it can take 17 if there
> are only 16 pages? By 'push' you mean splice-into-pipe or 
> splice-out-of-pipe-into-other-fd? Where exactly will it block?
>

Suppose we have 20 packets in the socket queue and the pipe is empty and the 
application calls splice(sock, pipe, 17, flags=0).

Then, tcp_splice_read will be called, which in turn calls tcp_read_sock. 

tcp_read_sock will loop until all the 17 bytes will be read from the socket. 
tcp_read_sock calls skb_splice_bits which calls splice_to_pipe.

Now while skb_splice_bits is carefull to only put a maximum of PIPE_BUFFERS 
during its iteration, due to the looping in tcp_read_sock, we will end up 
with 17 calls to splice_to_pipe. Thus on the 17th call, splice_to_pipe will 
block.

Does this make sense?

Thanks,
tavi
