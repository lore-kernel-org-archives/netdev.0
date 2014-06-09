From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Mon, 09 Jun 2014 14:37:57 -0400
Message-ID: <5395FF05.90101@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:53714 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbaFISiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 14:38:01 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so9438511qgd.1
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 11:38:00 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2014 08:49 AM, David Laight wrote:
> I think I have now reproduced the problem.
> 
>> From: David Laight
>>> I've been looking at an ethernet trace from one of our customers.
>>> They seem to have got an SCTP socket into a rather confused state.
>>>
>>> There seem to be a significant number of transmit ethernet frames
>>> that don't read the far end.
>>> This shouldn't cause a real problem, but we end up with the following:
>>> This trace was taken on the linux system:
>>>
>>> 39964   0.304473        ->      SCTP    INIT
>>> 39965   0.292669        <-      SCTP    INIT  (I think this has an invalid checksum)
>>> 39968   0.467935        <-      SCTP    INIT
>>> 39969   0.000093        ->      SCTP    INIT_ACK
>>> 39970   0.003947        <-      SCTP    COOKIE_ECHO
>>> 39971   0.000072        ->      SCTP    COOKIE_ACK
>>> 39972   0.000337        ->      M3UA    ASPUP
>>> 39979   0.809659        <-      SCTP    COOKIE_ECHO
>>> 39980   0.000058        ->      SCTP    COOKIE_ACK
>>> shutdown() called here - seems to be ignored
>>> 39983   0.949471        <-      SCTP    COOKIE_ECHO
>>> 39984   0.000053        ->      SCTP    COOKIE_ACK
>>> 39986   0.730072        ->      M3UA    ASPUP           Same TSN as above
>>> 40002   0.270589        ->      M3UA    ASPUP           Same TSN as above
>>> 40008   3.689088        <-      SCTP    HEARTBEAT
>>> 40009   0.000027        ->      SCTP    HEARTBEAT_ACK
>>> 40014   0.261152        <-      SCTP    HEARTBEAT
>>> 40015   0.000033        ->      SCTP    HEARTBEAT_ACK
>>> 40026   0.123048        <-      SCTP    HEARTBEAT
>>> 40027   0.000030        ->      SCTP    HEARTBEAT_ACK
>>> 40036   1.615048        ->      M3UA    ASPUP           Same TSN as above
>>>
>>> There are no signs of any SACKs for the ASPUP, I think they have the
>>> correct TSN (the same value as in the INIT_ACK).
>>> No signs of any shutdowns or aborts from either system.
>>>
>>> As seems to be typical for M3UA the source and destination ports are
>>> the same. No additional IP addresses appear in the INIT (etc) messages.
>>
>> I think I've reproduced this on a 3.14.0 kernel.
>>
>> System A: Bind to port 1234, connect to B:1234.
>>           If the connect fails, retry 10 seconds later.
>>           When the connection completes send some data.
>>           Disconnect if the reflected data isn't received within 2 seconds.
>> System B: Bind to port 1234, connect to A:1234.
>>           If the connect fails, retry 10 seconds later.
>>           Reflect any received data.
> 
> Add here, setsockopt(sock, SO_LINGER, { 1, 0 }, ...);
> If no data is received with a few seconds, close() the socket
> (do not call shutdown()), and retry.
> 
> Initially the INIT chunks generate ABORTs (no listener) so both
> programs just retry every 10 seconds.
> 
> On B run:
>     iptables -A OUPUT -p sctp --chunk-types any ABORT -j DROP
>     iptables -A INPUT -p sctp --chunk-types any DATA -j DROP
> The first allows the connection to complete, and then drops the
> ABORT sent by close().
> The second stops B acking the data.

Not only that, but the second entry stops B from accepting DATA.
So, now system B is is guaranteed to destroy it's association after
it hasn't heard anything for a while, but ABORT is dropped so A
doesn't learn about it.

> 
> System A now receives a new INIT (with a different TSN) and responds with
> an INIT_ACK (followed by a COOKIE_ECHO and COOKIE_ACK) even though
> it doesn't have a socket in a suitable state for the connection.

It still has an association in a SHUTDOWN-PENDING state.
This is collision case A where one end has restarted while the other
remains open.

The troubling spot here is the ULP has closed the socket already, but
the association is still around waiting for DATA to be acked.

This appears to be a hole in the spec.  I think that the correct
sequence here would be to send a COOKIE-ACK followed by SHUTDOWN
so that the remote comes correctly configures an association and
immediately enters statefull close.

> 
> I think the INIT should act as a received ABORT on the old connection,
> and then be processed as a new connection - in this case generating
> an ABORT because there is no listening socket.

No.  The INIT almost never causes the ABORT itself.

> 
> With the code I'm running the INIT is repeated every 30 seconds.
> No sign of any DATA retransmits after the first INIT (for over 20 minutes now).
> 
> I suspect that a simpler test of forcing a disconnect to use an ABORT and
> using iptables to discard the ABORT would be enough to show the problem.
> 

The other solution would be to change the sending application to send
an ABORT if the data hasn't been reflected back.

I'll dig through the specs and see if I can come up with the proper
solution.

-vlad

> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
