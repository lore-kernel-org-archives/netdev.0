From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Thu, 19 Jun 2008 18:10:29 -0500
Message-ID: <1213917029.9245.86.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <20080618062857.GA3598@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:51729 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbYFSXMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 19:12:33 -0400
In-Reply-To: <20080618062857.GA3598@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 10:28 +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Jun 17, 2008 at 05:58:26PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> > I understand that there is no guarantee of anything with UDP, but it
> > seems to me that if there is a packet in the buffer (it shows up after
> > another packet comes in behind it) the system should know about it,
> > right?
> 
> Did you run wireshark on receiver or sender?
> Check MIB stats if packet was dropped because of low mem or incorrect
> checksumm or some other problematic fields in UDP header. Sending part
> can see it perfectly correct, which will not be the issue on the
> receiver. If packet was delivered to receiving host, udp input path is
> rather simple so there are no places which can race with something and
> thus lost the packet.
> 

Initially, I had run wireshark on my PC and connected it to one of the
embedded boards (the issue still shows up in this case). I did some more
testing today where I ran tcpdump on both of the boards connected with a
cross-over cable until the application froze. What I was able to find
was that the first 1 or 2 hangups are corrected after 4 or 5 seconds
because the boards send an ARP request when data communication stops.
This causes communication to start up again. No packets are ever lost or
corrupted, they just don't appear to the application until something
else happens on the network.

Here is a snippet of the packet trace surrounding the hangup (these are
from the same session, but the clocks on the two boards were not set to
the same time):
(On the "server" -- sbc41):
22:53:57.763656 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
22:53:57.764000 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
22:53:57.764229 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
22:53:57.764387 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
22:54:01.034522 arp who-has sbc041.emacinc.com tell sbc042.emacinc.com
22:54:01.034642 arp reply sbc041.emacinc.com is-at 00:50:c2:0d:6e:00 (oui Unknown)
22:54:01.035585 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
22:54:01.035736 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
22:54:01.036095 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
22:54:01.036263 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
22:54:01.036793 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
--
22:54:01.803384 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
22:54:01.803773 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
22:54:01.803916 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
22:54:01.804274 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
22:54:01.804440 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
22:54:06.034670 arp who-has sbc042.emacinc.com tell sbc041.emacinc.com
22:54:06.034995 arp reply sbc042.emacinc.com is-at 00:50:c2:0e:0b:ac (oui Unknown)
22:54:06.035597 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
22:54:06.035750 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
22:54:06.036088 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
22:54:06.036249 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
22:54:06.036790 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4

(On the "client" -- sbc42):
17:18:03.141864 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
17:18:03.142195 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
17:18:03.142627 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
17:18:06.412741 arp who-has sbc041.emacinc.com tell sbc042.emacinc.com
17:18:06.413035 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
17:18:06.413122 arp reply sbc041.emacinc.com is-at 00:50:c2:0d:6e:00 (oui Unknown)
17:18:06.413793 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
17:18:06.413955 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
17:18:06.414500 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
17:18:06.414656 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
17:18:06.415001 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
--
17:18:07.181787 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
17:18:07.181995 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
17:18:07.182136 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
17:18:07.182676 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
17:18:11.413067 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
17:18:11.413160 arp who-has sbc042.emacinc.com tell sbc041.emacinc.com
17:18:11.413221 arp reply sbc042.emacinc.com is-at 00:50:c2:0e:0b:ac (oui Unknown)
17:18:11.413813 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4
17:18:11.413973 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 127
17:18:11.414493 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 4
17:18:11.414642 IP sbc041.emacinc.com.3072 > sbc042.emacinc.com.9005: UDP, length 127
17:18:11.414998 IP sbc042.emacinc.com.3072 > sbc041.emacinc.com.9003: UDP, length 4

Thanks,

Travis


