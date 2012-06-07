From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Wed, 06 Jun 2012 21:15:55 -0700
Message-ID: <4FD02AFB.7040004@candelatech.com>
References: <4FCCFE76.3060304@candelatech.com> <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54035 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab2FGEP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 00:15:59 -0400
In-Reply-To: <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 12:22 PM, Daniel Baluta wrote:
> On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> I'm going some TCP performance testing on wifi ->  LAN interface connections.
>>   With
>> UDP, we can get around 250Mbps of payload throughput.  With TCP, max is
>> about 80Mbps.
>>
>> I think the problem is that there are way too many ACK packets, and
>> bi-directional
>> traffic on wifi interfaces really slows things down.  (About 7000 pkts per
>> second in
>> upload direction, 2000 pps download.  And the vast majority of the download
>> pkts
>> are 66 byte ACK pkts from what I can tell.)

> [1] http://marc.info/?l=linux-netdev&m=131983649130350&w=2

After a bit more playing, I did notice a reliable 5% increase in
traffic (200Mbps -> 210Mbps) from changing the delack segments
to 20 from the default of 1.  That is enough to be useful to me,
and there may be more significant gains to be found...
I haven't done a full matrix of testing yet.

I read through the original thread, and to summarize:

* Need to make the values per-socket.
* No multiplication in hot path.
* Would be nice to make it automatic.

The first seems fairly trivial..just add a new set of socket-opts (or
maybe just one that can take all 3 values?) and store the settings in
the socket structs.

As for getting rid of the multiply..I think you cannot just use shifts.
That does not give the needed granularity.  An alternative is
to update a cached computation every time the mss or socket-opt changes.

As for a magic heuristic to figure this out, I think that would be
quite tricky to do right.  So, maybe add that in the future, but
for the present, just allowing applications to set the value seems
enough.

We could support configurable system-wide defaults so that users of
programs that do not know this new sockopt can still take advantage
of the feature.

Does this sound like a reasonable solution?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
