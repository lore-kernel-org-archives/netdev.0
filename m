From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 00:23:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4159117A.4010904@us.ibm.com>
References: <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner wrote:

> On Thu, 23 Sep 2004, David S. Miller wrote:
> 
> 
>>I think I know what may be going on here.
>>
>>Let's say that we even get the congestion window openned up
>>so that we can build 64K TSO frames, that's around 43 or 44
>>1500 mtu frames.
>>
>>That means as the window fills up, we have to see 44 ACKs
>>before we are able to send the next TSO frame.  Needless to
>>say that breaks ACK clocking completely.
> 
> 
> 
> More specifically, I think it is an interaction with delayed ack (acking
> less than 1 virtual segment), and the small cwnd.  This works for me, but
> I'm not sure that aren't some lurking problems still.

In terms of what goes out over the wire from the
sender, there is (or should be) no difference between
the TSO and non-TSO case. The sequence of regular sized
packets should be the same, and the only difference
might be the delays between the frames, at most.

So the sequence of acks coming back from the
receiver should be the same, TSO and non-TSO case.
If we've sent out say 44 1500MTU frames, we should
probably see 22 acks back, roughly (acking every
second packet if delayed acks are on) in both
the TSO and non-TSO case.

In terms of overall throughput, assuming we were doing
no other work other than this connection, we would see
a gain in the TSO case only if by the time the
congestion window opened fully for us to send another
virtual MTU frame, the application had written another
frame's worth of data (minus the extra delta
that would take for driver handoff and send at that
point). In the non-TSO case, the finer granularity is
helping us to utilize the channel more efficiently,
(although not the path down the stack or the CPU)..
actually, I think - although that is just another way
to say ack clocking is bumpy.

But I guess my question is - don't we need some
heuristics to figure out when we should send partial
(i.e. abandoning waiting for full TSO)?

thanks,
Nivedita
