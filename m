From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tcp: Replace infinite loop on recvmsg bug with proper
 crash
Date: Tue, 6 Nov 2012 20:39:07 -0500
Message-ID: <20121107013907.GA31185@redhat.com>
References: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Eric Dumazet <edumazet@chromium.org>
To: Julius Werner <jwerner@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab2KGBkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 20:40:16 -0500
Content-Disposition: inline
In-Reply-To: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 06, 2012 at 04:15:35PM -0800, Julius Werner wrote:
 > tcp_recvmsg contains a sanity check that WARNs when there is a gap
 > between the socket's copied_seq and the first buffer in the
 > sk_receive_queue. In theory, the TCP stack makes sure that This Should
 > Never Happen (TM)... however, practice shows that there are still a few
 > bug reports from it out there (and one in my inbox).
 > 
 > Unfortunately, when it does happen for whatever reason, the situation
 > is not handled very well: the kernel logs a warning and breaks out of
 > the loop that walks the receive queue. It proceeds to find nothing else
 > to do on the socket and hits sk_wait_data, which cannot block because
 > the receive queue is not empty. As no data was read, the outer while
 > loop repeats (logging the same warning again) ad infinitum until the
 > system's syslog exhausts all available hard drive capacity.
 > 
 > This patch improves that behavior by going straight to a proper kernel
 > crash. The cause of the error can be identified right away and the
 > system's hard drive is not unnecessarily strained.
 > 
 > Signed-off-by: Julius Werner <jwerner@chromium.org>
 > ---
 >  net/ipv4/tcp.c |    2 +-
 >  1 files changed, 1 insertions(+), 1 deletions(-)
 > 
 > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
 > index 197c000..fcb0927 100644
 > --- a/net/ipv4/tcp.c
 > +++ b/net/ipv4/tcp.c
 > @@ -1628,7 +1628,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 >  				 "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
 >  				 *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
 >  				 flags))
 > -				break;
 > +				BUG();
 >  
 >  			offset = *seq - TCP_SKB_CB(skb)->seq;
 >  			if (tcp_hdr(skb)->syn)

We've had reports of this WARN against the Fedora kernel for a while.
Had this been immediately followed by a BUG(), we'd have never seen those traces at all,
and just got "my machine just locked up" reports instead.

The proper fix here is to find out why we're getting into this state.

	Dave
