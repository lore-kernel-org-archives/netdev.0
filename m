From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC - VXLAN port range facility
Date: Thu, 30 May 2013 09:41:41 -0700
Message-ID: <20130530094141.7c125947@nehalam.linuxnetplumber.net>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:60275 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935566Ab3E3Qlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 12:41:46 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so667753pbc.31
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 09:41:45 -0700 (PDT)
In-Reply-To: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 May 2013 08:40:56 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> Stephen,
>         I think there are some issues with the port range facility in
> VXLAN. Currently, it picks a random port from a wide range (nearly half 
> the
> port space) and uses that random value as a source port for a generated
> UDP packet.
>         There are no checks to see if the port is in use by something 
> else.
> 
>         I can see the value of using a range of ports, but::
> 
> 1) VXLAN should use its listen port by default
> 2) VXLAN should actually bind to any source ports it uses, because...
> 3) VXLAN should never use a port already exclusively in use by something 
> else.

1. The receiver has to match based on src/dst port tuple anyway.
   So it doesn't matter a whole lot.

2. Current behaviour is in the RFC.

3. The choice of source port should follow same rules of other UDP
   send when port is not bound. I am worried that binding lots of ephemeral ports
   up will easily clog the space when there are lots of destinations.

4. The problem with binding for each destination used would be that
   it would mean having a socket for each destination, which would get
   resource intensive.


> As is, VXLAN is not playing well with other UDP users because, for 
> example,
> it can trigger ICMP errors which will be delivered to some unwitting 
> application
> whose port it has hijacked.

The source port is not related to what some application receives.
A RFC conforming VXLAN endpoint will never send traffic back tot the senders source
port. If VXLAN traffic got an ICMP response form an router like
DESTINATION_UNREACHABLE there should be a match on destination port as well.

> I think a port ranges may be useful in the context of a small number (say 
> 10)
> of ports that you are actually bound to, so then as part of multi-port 
> binding
> support. But then a default range of 32K-61K is too large. It then, at 
> least,
> has the potential to manage ICMP errors triggered by VXLAN.

Port ranges are critical to retaining scaling in multi-path infrastructure.
Otherwise all traffic will arrive on a single queue in NIC.

> 
> I think if you want to use port ranges like a range of empheremal ports, 
> it's
> less useful, but at a minimum it should be a port that you can legally 
> bind
> to at the time it's in use. Since actually binding/unbinding for each 
> packet
> would probably be too expensive, I think it'd be better to:

The normal source port range should be the (if not overriden)
is the UDP ephemeral port range.

> 1) use smaller ranges by default
> 2) actually bind to the entire range on start-up, to prevent other apps 
> from using them
> 3) fail if any in the range is already bound
> 4) then, with a range of bound ports, select as currently on sends
