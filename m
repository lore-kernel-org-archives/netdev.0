From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: ARP response with link local IP, why not broadcast
Date: Wed, 22 Jul 2015 10:29:25 +0200
Message-ID: <CACP96tS3LH9Uqr-YeYZ=EF893=T-YsjdDELq7v0uXSzzwyOL7Q@mail.gmail.com>
References: <55AE5958.3020009@gmx.de>
	<CACP96tRrCzFwTC-fSMxGTWr+zFSkid=Bd6JkGZA822HbEjk4_Q@mail.gmail.com>
	<55AF4B1D.4030208@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian Fett <db_extern@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36182 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063AbbGVI31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 04:29:27 -0400
Received: by wicgb10 with SMTP id gb10so87113153wic.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 01:29:26 -0700 (PDT)
In-Reply-To: <55AF4B1D.4030208@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 9:49 AM, Sebastian Fett <db_extern@gmx.de> wrote:

>> what is your use case?
>>
>
> My problem ist a local network of audio devices. It is a valid possibility
> that two halfs of the setup are set up individually (Stage left and stage
> right). Both local networks will auto configure themselves via link local
> and will be stable. But there always can be two devices with the same IP in
> both networks.
> At one point those two networks will be connected. With the current
> behaviour the conflicting devices will never know of each other and the
> address conflict.

Ah yes, this is a valid problem (Partition-Join tolerance) and one that is
being discussed in the Ipv6 context on 6man:
http://www.ietf.org/mail-archive/web/ipv6/current/msg22712.html

FWIW, when Solaris implemented ACD (rfc 5227) the compromise
that was made between bcasting *every* ARP response whle solving
the type or issue that you describe was to use a periodic ARP "announce",
advertising the IP address (a Grat ARP) with exponential backoff.
If a duplicate address is triggered (as would happen in the scenario
that you describe) the system would fall into the aggressive defend mode.

ARP announcemnts were bcast, but the noise is mitigated by tunable
exponential backoff.

Of course, all of this only helps to *detect* the duplicate- eventually
some other entity has to jump in and arbitrate on which one should
"own" the address.

> The devices are controlled by a central PC using avahi/bonjour. It will know
> of all conflicting devices, but will only be able to talk to the one that
> happens to be in it's ARP cache. And renewing that cache will not change
> anything, because it will happen with unicast messages.
>
> I looked at a Dante Controller (an audio data streaming device). And here
> all ARP messages are answered with broadcasts.
>
> I think that behaviour is acceptable because it only happens in local
> networks. Waking up sleeping devices will not be a concern there.

I dont know if a short term solution that makes sense here is to have
a tunable for this.

But even the "always bcast arp response" will fail if you have a silent
rejoin of the partitioned network- there is a reliance on the owner
of an address bcasting their ARP resp at some point right?

(there's also a DoS vector here- I can create a lot of bcast traffic
by arping for an address..)
>
> That brings me to another question. When I react to an ARP packet in a
> userspace program, can I keep that packet from reaching the kernel as well?
> I would like to avoid to completely handle ARP in userspace.
>
