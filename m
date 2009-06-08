From: mail@saschahlusiak.de
Subject: Re: [PATCH 2/3] sit: handle ICMPv4 for tunnels with no remote
Date: Mon, 08 Jun 2009 16:13:52 +0200
Message-ID: <20090608161352.152078nqk5d89e8s@www.domaingo-webmail.de>
References: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
 <1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
 <20090608.024024.236334849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: contact@saschahlusiak.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay10.ispgateway.de ([80.67.29.24]:41626 "EHLO
	smtprelay10.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbZFHOTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 10:19:42 -0400
In-Reply-To: <20090608.024024.236334849.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Zitat von David Miller <davem@davemloft.net>:

> From: Sascha Hlusiak <contact@saschahlusiak.de>
> Date: Sat,  6 Jun 2009 16:02:51 +0200
>
>> Don't drop ICMPv4 packages, if tunnel has no remote endpoint, like
>> 6to4 or isatap tunnels.
>>
>> Also don't drop it if tunnel inherits ttl and icmp_time_exceeded.
>> Don't really see the usecase here.
>>
>> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
>
> You're going to have to describe this change a bit more.
My primacy concern with the patchset is in the usecase of ISATAP or
6to4, but I know this might heavily affect static tunnels as well.

In case an ISATAP neighbour is unreachable, an ICMPv4 error will be
sent to the tunnel and without my patches it will be discarded. The
3rd patch will re-add the code to treat ICMPv4 errors as link errors
and send ICMPv6 errors back to the sending application so it can be
handled. Without it, the application won't get any ICMPv6 messages
and it will timeout in case of link(=IPv4) errors. An ICMPv4
unreachable should result in an ICMPv6 unreachable in the case of ISATAP.

> What in the world is wrong with dropping an ICMP time exceeded if the
> TTL in the template header is zero?  Someone wrote that code and had
> some reason to put it there.   Until you know the reason or can prove
> without a shadow of doubt that it's pointless, you can't just remove
> it.
If iph.ttl == 0, it means that the ttl of the ipv4 package is inherited
from the ipv6 package to be sent. In case the ipv4 ttl of the path
expires, the ipv6 ttl would expire too. While the link does send a
time_exceeded, I believe that the application should receive an ICMPv6
time_exceeded as well, even if the package died right on the tunnel
endpoint.

In case we cannot find the application, we can discard it because it's
not a link failure. That case should still be handled, you are right.

> You other two changes need more verbose commit messages as well.
> I can't tell what the point or benefit are of your changes.
If we receive enough payload in the ICMPv4 error, I think
it's a good idea to pass the error on as an ICMPv6 to the sender. The
current implementation is to mark the whole link faulty for 30 seconds,
if it's a directed tunnel (iph.daddr != 0).

> So I'm dropping your patches until all of this is resolved, and
> the commit messages are more verbose and explain why you're doing
> all of these things.
I basically want to partly revert 071f92d05967a0c8422f1c8587ce0b4d90a8b447
which removed the desired behaviour that was activated with
I_WISH_WORLD_WERE_PERFECT. In case you agree that it's a good idea, I'll
prepare a new patchset.

Thanks,
Sascha


