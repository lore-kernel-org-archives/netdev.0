From: James Carlson <carlson@workingcode.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Fri, 27 Jun 2003 09:19:26 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16124.17502.166892.539182@h006008986325.ne.client2.attbi.com>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
	<20030625.205941.41631020.davem@redhat.com>
	<16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
	<20030626190407.S87648@shell.cyberus.ca>
	<16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
	<16124.13469.944716.441016@nanango.paulus.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, "David S. Miller" <davem@redhat.com>,
   rusty@rustcorp.com.au, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: Paul Mackerras's message of 27 June 2003 22:12:13
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Mackerras writes:
> Rusty asked me today what protocols there were that coped with packet
> loss but couldn't cope with reordering.  I couldn't think of any.  Do
> you know of any examples?

Sure.  We've already pointed out MP (RFC 1990) and VJ (RFC 1144) --
both of which handle loss just fine, but fail miserably if packets are
misordered -- MP locks up and VJ will produce silent data corruption.

Regular PPP negotiation itself can have trouble with misordering.
Consider this example:

	Peer A		Peer B
	Req-1 -->
		    <-- Req-a
	Req-2 -->
		    <-- Ack-2
		    <-- Ack-1
		    <-- Req-a
	Ack-a -->

In this case, Peer A sent Configure-Request ID 1 with some set of
options (we'll call this set "1").  Peer B then sent Configure-Request
ID a with its own set of options.  Based on that Configure-Request,
peer A decided to start over (e.g., peer A originally offered ACCM 0
and then saw ACCM 0xa0000 from the peer and decided that, since the
peer may well be an idiot, changing peer A's ACCM to 0xa0000 would be
prudent) and it sends Configure-Request ID 2.

Because of reordering, Peer B sees Configure-Request ID 2 first.  It
responds.  Peer A sees the Ack and goes on to AckRcvd state.  Peer B
sees ID 1 next.  It discards the options it saw in ID 2 and keeps the
options from ID 1, and sends an Ack for that.  Peer A discards this
bogus Ack -- it doesn't match the current ID number.

Peer A finally gets Req-a and sends an Ack.

Now we're in a very bad state.  Peer A believes it has negotiated its
option set "2" with Peer B, and Peer B believes it has agreed to
option set "1."  Oops.

Some others that are known to be sensitive to ordering (cited in
802.1w) are LAT, LLC2, and NETBEUI.

Another is SNA.  Reordering SNA packets will cause the link to
reinitialize and cause a fault at the application level.  Doing this
causes everyone to have a bad day.

Still another is GARP.  This isn't a big deal if you're worrying about
bridging -- GARP doesn't get forwarded -- but it does matter if the
Ethernet driver itself mangles packet order.  If you can't maintain
order inside your own host, then GARP is dead.

Yet another is EAP.

There are probably others that haven't occurred to me.  The L2-wire-
preserves-order assumption turns out to be very easy to build into a
protocol.  All you have to do is pretend (as PPP does) that there's
only one outstanding request at a time, and treat all others as
invalid.  That builds in the ordering dependency -- and it's how many
lock-step protocols are designed.  In order to be tolerate of
misordering (and duplication), a protocol has to define some sort of
ID numbering window (as is done, for example, in the L2TP control
connection) with a logical sequence of ID numbers, so that the peer
can determine which received ID numbers are "before" or "after" a
given number.

Then finally there's ISO/IEC 15802-1, Clause 9.2 (MAC) that permits
only a "negligible" amount of reordering.  (The rate is exactly zero
on normal networks but could be nonzero for a "magically healed"
bridge connection -- if you don't know what that is, don't sweat it.
It requires accidents to occur.)

-- 
James Carlson                                  <carlson@workingcode.com>
