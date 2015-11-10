From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 4/4] net: af_unix: implement splice for stream
 af_unix sockets
Date: Tue, 10 Nov 2015 03:34:30 +0100
Message-ID: <1447122870.2543704.434523977.5DE1B39D@webmail.messagingengine.com>
References: <cover.1432220158.git.hannes@stressinduktion.org>
 <2608f83f33225b05eb8a4bf0275f05dce83edfd3.1432220158.git.hannes@stressinduktion.org>
 <1447117918.17135.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:57635 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561AbbKJCed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 21:34:33 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id E353E208A4
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 21:34:30 -0500 (EST)
In-Reply-To: <1447117918.17135.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo,

On Tue, Nov 10, 2015, at 02:11, Eric Dumazet wrote:
> On Thu, 2015-05-21 at 17:00 +0200, Hannes Frederic Sowa wrote:
> 
> > +
> > +static ssize_t skb_unix_socket_splice(struct sock *sk,
> > +				      struct pipe_inode_info *pipe,
> > +				      struct splice_pipe_desc *spd)
> > +{
> > +	int ret;
> > +	struct unix_sock *u = unix_sk(sk);
> > +
> > +	mutex_unlock(&u->readlock);
> > +	ret = splice_to_pipe(pipe, spd);
> > +	mutex_lock(&u->readlock);
> > +
> > +	return ret;
> > +}
> > +
> 
> Hi Hannes
> 
> Since we release u->readlock, what prevents another thread to read() the
> same af_unix socket and consume the skb while we splice it ?
> 
> TCP stack has special code to take care of this possibility.

Hm, I do see the problem, yes. I left a window open for races happening.

Without having a closer look what spontaneously comes to my mind:

increment skb->users before splice_to_pipe, re-peek the socket queue
after the splice, recheck if we have the same skb pointer in the front,
and then consume_skb the skb properly and indicating a short read.

Let me try tomorrow if that works, but I fear we can read data multiple
times with this fix, so I don't know if this is a proper fix. I have to
check the TCP code closer. Thanks for the hint!

Thanks for the report,
Hannes
