From: Olaf Kirch <okir@suse.de>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Tue, 27 Jul 2004 14:38:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727123842.GF27188@suse.de>
References: <20040715092715.GA23131@wotan.suse.de> <OF97127705.C0C08B6A-ON88256ED2.004DB9A5-88256ED2.005146DA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com,
        "Rusty Russell (IBM)" <rusty@au1.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF97127705.C0C08B6A-ON88256ED2.004DB9A5-88256ED2.005146DA@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> you'll reassemble garbage when the IP ID wraps (well before the frag queue
> expires). And the checksum will pass anyway on average about 1/64K of the
> time. If you send at full rate and drop, say, 100 frags a second, it
> doesn't take too long to get a Frankenpacket-- reassembled from parts of
> others. :-)

In the scenarios we were looking at, packet loss rate was fairly low.
What compounded the problem was that the NFS payload wasn't very varied,
so the UDP checksum distribution was far from even.

When we looked into the problem, we considered implementing a per-route
parameter where the admin can set lower reassembly timeouts. I think this
is a solution that both addresses the problem, and does not interfere
with WAN traffic. The user space tools could even select reasonable
defaults based on the hardware type when setting up the device.

(We did not implement this because we decided to go for NFS over TCP by
default instead).

> > In general handling a link where the RTT increases would seem
> > tricky with your scheme. Unlike TCP there is no retransmit
> > to save the day.
> 
> In the particular case (NFS over UDP), there is both a retransmit (done
> by RPC) and significant loss rate to start with. As long as the time-out
> is conservative, I don't think this has to affect other cases
> significantly.

NFS isn't the only application making heavy use of UDP.  Video and
audio do so too, and these don't have retransmits. Granted, these should
choose a paket size that is below the path MTU, but not all applications
always do.

IMO an estimator such as you describe would need to be very sensitive
to jitter in fragment latencies, and it may be fairly hard to find a
solution that works from 802.11 up to 10GE. A per-route reassembly
timeout is probably a lot less of a headache.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 
