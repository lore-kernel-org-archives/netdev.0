From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BUG: dst underflow (again)
Date: Thu, 4 Nov 2004 22:18:01 -0800
Message-ID: <20041104221801.584c8f11.davem@davemloft.net>
References: <4178AB0D.6060107@pobox.com>
	<20041022.155159.98771450.yoshfuji@linux-ipv6.org>
	<20041022075947.GA15795@xi.wantstofly.org>
	<1099577717.1039.155.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, yoshfuji@linux-ipv6.org, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099577717.1039.155.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 04 Nov 2004 09:15:17 -0500
jamal <hadi@cyberus.ca> wrote:

> Could you turn off netfilter and see if this continues to happen?

That's one possible angle, but let's look at the tracepoints
more closely.

BTW Lennert, the decoded addresses are extremely helpful. Thanks.

Jeff, could you similarly decode the ones that you seem to get?
That would be an incredibly useful datapoint.  If you've provided
this already, my bad and please point me at where you posted that.

> > BUG: dst underflow -1: 3bcf9a80 at 42350024
> > BUG: dst underflow 0: 3bcf9a80 at 423486d2
> > BUG: dst underflow 0: 3bcf9a80 at 4235823d
 ...
> > 0x42350024 - 0x42345000 = 0xb024, corresponds to:
> > 	0000affa <ip6_dst_check>
> > 
> > 0x423486d2 - 0x42345000 = 0x36d2, corresponds to:
> > 	0000339d <ip6_push_pending_frames>
> > 
> > 0x4235823d - 0x42345000 = 0x1323d, corresponds to:
> > 	00012c0d <udpv6_sendmsg>	(god, that's one big function btw)

The last one is the most interesting.  The only dst_release() call
that occurs in udpv6_sendmsg() is when xfrm_lookup() returns
an error.  The semantics of that function are a complete mess
(when it errors, it sometimes releases the DST, sometimes does not)
and I'll fix that up.

But let me ask, do you have any IPSEC policies in the kernel
when these BUGs trigger?  If so, I'm pretty sure I know what
the problem may be.
