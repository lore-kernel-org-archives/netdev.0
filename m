From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO prevents cwnd growth on 2.6 kernels
Date: Fri, 25 Mar 2005 11:40:38 -0800
Message-ID: <20050325114038.3076be29.davem@davemloft.net>
References: <20050325181804.GA11633@visi.com>
	<20050325104000.713229be.davem@davemloft.net>
	<20050325193458.GA15645@visi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sferris@acm.org, netdev@oss.sgi.com
To: "Scott M. Ferris" <sferris@acm.org>
In-Reply-To: <20050325193458.GA15645@visi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Mar 2005 13:34:59 -0600
"Scott M. Ferris" <sferris@acm.org> wrote:

> > Are you suggesting to let it go past tp->snd_cwnd?  We can't
> > ever do that.  tp->snd_cwnd is a hard limit on the number
> > of frames we may have outstanding on the network at one time,
> > TSO or not.
> 
> No, I think we all agree that exceeding cwnd is a bad idea.  I'm just
> saying that failing to reach cwnd is also broken, especially if it
> results in tcp_write_xmit() sending nothing at all when cwnd is small.

But if we only have a TSO frame at the head,  which would make us
exceed tp->snd_cwnd, the only option is to chop up the TSO frame.
So I guess that's your idea?

It's similar to the real fix for all of this, which I posted a detailed
description of about 1 or 2 months ago.  Check the netdev archives.
Basically, we don't build the TSO frames until transmit time thus:

1) We always fill the CWND
2) We size the TSO based upon the CWND at send time not at
   the time we are sucking in the data from userspace
3) No more multi-packet TSO frames in the send queue, thus no
   more disabling of TSO during packet loss and no more weird
   packet counting stuff
