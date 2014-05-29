From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP seems to lose its socket state.
Date: Thu, 29 May 2014 09:03:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724FA96@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
 <538644AE.90807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34398 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934055AbaE2JEv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 05:04:51 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24847-06 for <netdev@vger.kernel.org>;
 Thu, 29 May 2014 10:04:42 +0100 (BST)
In-Reply-To: <538644AE.90807@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 05/27/2014 11:10 AM, David Laight wrote:
> > I've been looking at an ethernet trace from one of our customers.
> > They seem to have got an SCTP socket into a rather confused state.
> >
> > There seem to be a significant number of transmit ethernet frames
> > that don't read the far end.
> > This shouldn't cause a real problem, but we end up with the following:
> > This trace was taken on the linux system:
> >
> > 39964   0.304473        ->      SCTP    INIT
> > 39965   0.292669        <-      SCTP    INIT  (I think this has an invalid checksum)
> > 39968   0.467935        <-      SCTP    INIT
> > 39969   0.000093        ->      SCTP    INIT_ACK
> > 39970   0.003947        <-      SCTP    COOKIE_ECHO
> > 39971   0.000072        ->      SCTP    COOKIE_ACK
> > 39972   0.000337        ->      M3UA    ASPUP
> > 39979   0.809659        <-      SCTP    COOKIE_ECHO
> 
> cookie_ack was dropped for some reason?

Most likely, as I said a moderate number of ethernet transmit are not
being received by the far end.
I think this is a 'real' network and they are 'real' discards somewhere
between the two systems.
Other parts of the trace show all sorts of retransmissions.

> > 39980   0.000058        ->      SCTP    COOKIE_ACK
> > shutdown() called here - seems to be ignored
> > 39983   0.949471        <-      SCTP    COOKIE_ECHO
> 
> Cookie timer fired and resent the cookie_echo.
> 
> > 39984   0.000053        ->      SCTP    COOKIE_ACK
> > 39986   0.730072        ->      M3UA    ASPUP           Same TSN as above
> > 40002   0.270589        ->      M3UA    ASPUP           Same TSN as above
> 
> Hmm.. look like more retransmissions.
> 
> > 40008   3.689088        <-      SCTP    HEARTBEAT
> 
> This probably means that cookie_ack was finally accepted and
> we are not heart-beating...
> 
> output of 'cat /proc/net/sctp/assocs' might help.  If the local
> is running a recent enough kernel, then turning on dynamic debug
> in sctp will also help.

This is a customer system, I think it is RHEL6 (2.6.32-358) so
running a newer kernel is a little tricky to arrange.
We have asked to double check the kernel version, it might be
RHEL5 (2.6.18 + patches) - which is likely to have a lot of bugs.

> > 40009   0.000027        ->      SCTP    HEARTBEAT_ACK
> > 40014   0.261152        <-      SCTP    HEARTBEAT
> > 40015   0.000033        ->      SCTP    HEARTBEAT_ACK
> > 40026   0.123048        <-      SCTP    HEARTBEAT
> > 40027   0.000030        ->      SCTP    HEARTBEAT_ACK
> > 40036   1.615048        ->      M3UA    ASPUP           Same TSN as above
> >
> > There are no signs of any SACKs for the ASPUP, I think they have the
> > correct TSN (the same value as in the INIT_ACK).
> 
> Make sure that verification tags match what was negotiated in
> init/init_ack, and the SSN starts at 0.

The tags match, SSN is zero.
I think the lack of SACK for the data is a bug in the remote system.
It shouldn't stop the outward disconnect.

> > No signs of any shutdowns or aborts from either system.
> >
> 
> What's strange is that some frames are simply not accepted.
> Are the nics by any chance ixgbe that has checksum offload and
> the checksums are corrupt for some reason?

The wireshark trace does show zero for all the transmitted SCTP
checksums. But the system works fine for hours, so I don't really
believe that is causing the packets to be lost.

I think the packet loss is caused by serious network congestion.

Not the least of the problems is that it seems to take a system
reboot to revover.

	David
