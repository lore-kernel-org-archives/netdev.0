From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Wed, 28 May 2014 16:18:54 -0400
Message-ID: <538644AE.90807@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:57717 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaE1US6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 16:18:58 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so19300116qga.20
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 13:18:57 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2014 11:10 AM, David Laight wrote:
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

cookie_ack was dropped for some reason?

> 39980   0.000058        ->      SCTP    COOKIE_ACK
> shutdown() called here - seems to be ignored
> 39983   0.949471        <-      SCTP    COOKIE_ECHO

Cookie timer fired and resent the cookie_echo.

> 39984   0.000053        ->      SCTP    COOKIE_ACK
> 39986   0.730072        ->      M3UA    ASPUP           Same TSN as above
> 40002   0.270589        ->      M3UA    ASPUP           Same TSN as above

Hmm.. look like more retransmissions.

> 40008   3.689088        <-      SCTP    HEARTBEAT

This probably means that cookie_ack was finally accepted and
we are not heart-beating...

output of 'cat /proc/net/sctp/assocs' might help.  If the local
is running a recent enough kernel, then turning on dynamic debug
in sctp will also help.

> 40009   0.000027        ->      SCTP    HEARTBEAT_ACK
> 40014   0.261152        <-      SCTP    HEARTBEAT
> 40015   0.000033        ->      SCTP    HEARTBEAT_ACK
> 40026   0.123048        <-      SCTP    HEARTBEAT
> 40027   0.000030        ->      SCTP    HEARTBEAT_ACK
> 40036   1.615048        ->      M3UA    ASPUP           Same TSN as above
> 
> There are no signs of any SACKs for the ASPUP, I think they have the
> correct TSN (the same value as in the INIT_ACK).

Make sure that verification tags match what was negotiated in
init/init_ack, and the SSN starts at 0.


> No signs of any shutdowns or aborts from either system.
> 

What's strange is that some frames are simply not accepted.
Are the nics by any chance ixgbe that has checksum offload and
the checksums are corrupt for some reason?

-vlad

> As seems to be typical for M3UA the source and destination ports are
> the same. No additional IP addresses appear in the INIT (etc) messages.
> 
> Some 80 seconds after the start of the above the remote sends us another INIT.
> This is responded to (with new verification tags from both ends), but only
> SCTP heartbeats get sent/received (both ways).
> 
> The remote sends a few heartbeats with the old verification tag they are
> ignored.
> 
> The application is repeatedly trying to connect() - but the requests fail
> immediately (errno unknown).
> I think the system is RHEL 6.4, kernel: 2.6.32-358.el6.x86_64.
> 
> Does this 'ring any bells' ?
> I think I've asked a similar question before - and 2.6.32 was thought
> to be a late enough kernel.
> It is, of course, possible they are running RHEL 5 on this system.
> 
> I can't think of an easy way to repeat the above sequence to verify
> on a much more recent kernel.
> 
> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
