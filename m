From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 10:31:57 -0600
Message-ID: <20150527163157.GA15041@obsidianresearch.com>
References: <20150526233017.GB22391@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
 <55658F9D.6030404@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
 <20150527153226.GA9909@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40D32@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60234 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbbE0QcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 12:32:17 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB40D32@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 04:16:44PM +0000, David Laight wrote:
> From: Jason Gunthorpe
> > Sent: 27 May 2015 16:32
> > On Wed, May 27, 2015 at 10:11:22AM +0000, David Laight wrote:
> > 
> > > In any case it looks like I can escape by turning off
> > > SCTP_I_WANT_MAPPED_V4_ADDR for kernels 3.17 through 4.0.
> > 
> > Just be aware that option is unusable on kernels without 299ee.
> > 
> > I fixed everything wrong I saw, but that doesn't mean it works
> > 100%. Honestly, I don't think anyone has ever used it.
> 
> I'm now confused.
> 
> I've just done a test using a 4.0.0-rc1 kernel.
> I'm binding an IPv6 listening socket and then connecting to it
> from 127.0.0.1.
> I don't know it I'm being given an IPv4 format address or a
> v6mapped one (I shorten the latter before tracing it) - but
> it contains 127.0.0.1 (not 0.0.0.0).
> (That is without changing any socket options.)

I don't know what your test does, but I used the same basic idea with
loopback to find this issue. You should confirm the kernel is
returning a AF_INET6 socket type, if it is AF_INET then there is a
path I missed in 299ee and I should fix it..

Specifically, the corruption I confirmed was from a recvmsg call with
MSG_NOTIFICATION set indicating a new connection has happened on a
many to many socket.

strace sayth:

socket(PF_INET6, SOCK_SEQPACKET|SOCK_CLOEXEC, IPPROTO_SCTP) = 7
recvmsg(7, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(9090), inet_pton(AF_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\1\200\0\0\24\0\0\0\4\0\0\0\0\0\0\0\17%\0\0", 1024}], msg_controllen=0, msg_flags=MSG_EOR|MSG_MORE}, MSG_DONTWAIT) = 20

Jason
