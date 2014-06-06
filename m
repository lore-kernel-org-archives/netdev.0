From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP seems to lose its socket state.
Date: Fri, 6 Jun 2014 15:14:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44433 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751646AbaFFPPP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:15:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23074-06 for <netdev@vger.kernel.org>;
 Fri,  6 Jun 2014 16:15:06 +0100 (BST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight
> I've been looking at an ethernet trace from one of our customers.
> They seem to have got an SCTP socket into a rather confused state.
> 
> There seem to be a significant number of transmit ethernet frames
> that don't read the far end.
> This shouldn't cause a real problem, but we end up with the following:
> This trace was taken on the linux system:
> 
> 39964   0.304473        ->      SCTP    INIT
> 39965   0.292669        <-      SCTP    INIT  (I think this has an invalid checksum)
> 39968   0.467935        <-      SCTP    INIT
> 39969   0.000093        ->      SCTP    INIT_ACK
> 39970   0.003947        <-      SCTP    COOKIE_ECHO
> 39971   0.000072        ->      SCTP    COOKIE_ACK
> 39972   0.000337        ->      M3UA    ASPUP
> 39979   0.809659        <-      SCTP    COOKIE_ECHO
> 39980   0.000058        ->      SCTP    COOKIE_ACK
> shutdown() called here - seems to be ignored
> 39983   0.949471        <-      SCTP    COOKIE_ECHO
> 39984   0.000053        ->      SCTP    COOKIE_ACK
> 39986   0.730072        ->      M3UA    ASPUP           Same TSN as above
> 40002   0.270589        ->      M3UA    ASPUP           Same TSN as above
> 40008   3.689088        <-      SCTP    HEARTBEAT
> 40009   0.000027        ->      SCTP    HEARTBEAT_ACK
> 40014   0.261152        <-      SCTP    HEARTBEAT
> 40015   0.000033        ->      SCTP    HEARTBEAT_ACK
> 40026   0.123048        <-      SCTP    HEARTBEAT
> 40027   0.000030        ->      SCTP    HEARTBEAT_ACK
> 40036   1.615048        ->      M3UA    ASPUP           Same TSN as above
> 
> There are no signs of any SACKs for the ASPUP, I think they have the
> correct TSN (the same value as in the INIT_ACK).
> No signs of any shutdowns or aborts from either system.
> 
> As seems to be typical for M3UA the source and destination ports are
> the same. No additional IP addresses appear in the INIT (etc) messages.

I think I've reproduced this on a 3.14.0 kernel.

System A: Bind to port 1234, connect to B:1234.
          If the connect fails, retry 10 seconds later.
          When the connection completes send some data.
          Disconnect if the reflected data isn't received within 2 seconds.
System B: Bind to port 1234, connect to A:1234.
          If the connect fails, retry 10 seconds later.
          Reflect any received data.

Initially the INIT chunks generate ABORTs (no listener) so both
programs just retry every 10 seconds.

On B run:
    iptables -A INPUT -p sctp --chunk-types any INIT -j DROP
    iptables -A INPUT -p sctp --chunk-types any DATA -j DROP
The first allows the connection to complete.
The second stops B acking the data.
The data is resent on timeout, and the systems exchange HBs.

I'd expect that a SHUTDOWN or ABORT be sent reasonably quickly.
But the systems just exchange HBs for over 5 minutes.
(I'm seeing an ABORT because B gives up waiting for the message.)

If I discard the COOKIE_ECHO then I do see an outwards disconnect
after a few retries.

I'm testing with sockets created by our M3UA kernel driver,
and system B is running a much older kernel (2.6.26).
Neither should make any difference.

	David
