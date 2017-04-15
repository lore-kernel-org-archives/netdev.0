From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: TPACKET_V3 timeout bug?
Date: Sun, 16 Apr 2017 01:44:37 +0200
Message-ID: <20170415234437.GA21836@lunn.ch>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59467 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754683AbdDOXoj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 19:44:39 -0400
Content-Disposition: inline
In-Reply-To: <20170415224530.GA21010@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 15, 2017 at 06:45:36PM -0400, Sowmini Varadhan wrote:
> On (04/15/17 21:40), Andrew Lunn wrote:
> > 
> > In my case, lan3 is up and idle, there are no packets flying around to
> > be captured. So i would expect pcap_next_ex() to exit once a second,
> > with a return value of 0. But it is not, it blocks and stays blocked.
>    :
> > Looking at the libpcap source, the 1000ms timeout is being used as
> > part of the setsockopt(3, SOL_PACKET, PACKET_RX_RING, 0xbe9445c0, 28)
> > call, req.tp_retire_blk_tov is set to the timeoutval.
> 
> right, aiui, the retire_blk_tov will only kick in if we have at
> least one frame in a block, but the block is not filled up yet,
> before the req.tp_retire_blk_tov (1s in your case) expires.
> 
> If there are 0 frames pending, we should not be waking up the app,
> so everything seems to be behaving as it should?

Hi Sowmini 

Humm, i can see the logic of that, it puts an upper bound on the
latency for delivering a frame to user space, but does not wake user
space when there is nothing in the queue.

Yet i'm debugging an application which expects a timeout even when
there are 0 packets. The Ostinator drone. It is a multi thread
process, with a thread performing capture, and another thread doing
control stuff. When the control thread wants to stop the capturing, it
is setting a variable.  The next time the capture thread comes out of
pcap_next_en() it checks the variable and close the capture and the
thread exists. But if there is no network traffic, it never
exists. This scheme has worked before, but suddenly stopped when i
upgraded something. What i cannot say is if that is libpcap, or a
kernel, since i upgraded both at the same time.

But it does seem like a regression somewhere.

Looking at libpcap, it does seem to expect a timeout to happen even
when there are 0 packets available. Has there been a kernel change
with respect to this behaviour?

  Andrew
