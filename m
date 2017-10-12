From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [RFC] Support for UNARP (RFC 1868)
Date: Thu, 12 Oct 2017 16:06:34 -0700
Message-ID: <c75c04fe-46d6-8ec3-844d-fe379710496b@oracle.com>
References: <1507782977-2443-1-git-send-email-girish.moodalbail@oracle.com>
 <1507820236.31614.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24742 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751657AbdJLXHG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 19:07:06 -0400
In-Reply-To: <1507820236.31614.50.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

The basic idea is to mark the ARP entry either FAILED or STALE as soon as we can 
so that the subsequent packets that depend on that ARP entry will take the slow 
path (neigh_resolve_output()).

Say, if base_reachable_time is 30 seconds, then an ARP entry will be in 
reachable state somewhere between 15 to 45 seconds. Assuming the worst case, the 
ARP entry will be in REACHABLE state for 45 seconds and the packets continue to 
traverse the network towards the source machine and gets dropped their since the 
VM has moved to destination machine.

Instead, based on the received UNARP packet if we mark the ARP entry

(a) FAILED
    - we move to INCOMPLETE state and start the address resolution by sending
      out ARP packets (up to allowed maximum number) until we get ARP response
      back at which point we move the ARP entry state to reachable.

(b) STALE
    - we move to DELAY state and set the next timer to DELAY_PROBE_TIME
      (1 second) and continue to send queued packets in arp_queue.
    - After 1 sec we move to PROBE state and start the address resolution like
      in the case(a) above.

I was leaning towards (a). Please see in-line..

<snip>

> 
> Hi Girish
> 
> Your description (or patch title) is misleading. You apparently
> implement the receive side of the RFC.

You are right, it implements only the receive side of the RFC. If this RFC is 
accepted, then we can change arping(8) to generate UNARP requests. We could also 
add an option to ip-address(8) delete subcommand to generate UNARP whenever an 
address is deleted from the interface.

> And the RFC had Proxy ARP in mind.
> 
> What about security implications ? 

Yes, this feature will extend the attack surface for L2 networks. However, the 
attack vectors for this feature should be same as that of the gratuitous ARP, 
right? The same attack mitigation techniques for gratuitous ARPs is equally 
applicable here.

> Will TCP flows be terminated, instead
> of being smoothly migrated (TCP_REPAIR)

The TCP flows will not be terminated. Upon receiving UNARP packet, the ARP entry 
will be marked FAILED. The subsequent TCP packets from the client (towards that 
IP) will be queued (the first 3 packets in arp_queue and then other packets get 
dropped) until the IP address is resolved again through the slow path 
neigh_resolve_output().

The slow path marks the entry as INCOMPLETE and will start sending several ARP 
requests (ucast_solicit + app_solicit + mcast_solicit) to resolve the IP. If the 
resolution is successful, then the TCP packets will be sent out. If not, we will 
invalidate the ARP entry and call arp_error_report() on the queued packets 
(which will end up sending ICMP_HOST_UNREACH error). This behavior is same as 
what will occur if TCP server disappears in the middle of a connection.

> 
> What about IPv6 ? Or maybe more abruptly, do we still need to add
> features to IPv4 in 2017,  22 years after this RFC came ? ;)

Legit question :). Well one thing I have seen in Networking is that an old idea 
circles back around later and turns out to be useful in new contexts and use 
cases. Like I enumerated in my initial email there are certain use cases in 
Cloud that might benefit from UNARP.

regards,
~Girish

> 
> Thanks.
> 
> 
