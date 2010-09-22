From: Bob Arendt <rda@rincon.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Wed, 22 Sep 2010 13:56:39 -0700
Message-ID: <4C9A6D87.2000103@rincon.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:38329
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755593Ab0IVVCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 17:02:48 -0400
In-Reply-To: <alpine.DEB.2.00.1009221448460.32661@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2010 12:58 PM, Christoph Lameter wrote:
> On Wed, 22 Sep 2010, David Stevens wrote:
>> 3) I don't think it's a good idea to make up intervals, and especially
>>          non-randomized ones. The probability of getting all minimum
>> intervals
>>          is very low (which goes back to #1) and sending fixed intervals
>> may
>>          introduce a problem (packet storms) that isn't there per RFC.
>> These
>>          fixed intervals can also be either way too long or way too short,
>>          depending on link characteristics they don't account for. Leaving
>>          the intervals randomized based on querier-supplied data seems much
>>          more appropriate to me.
>
> These are *unsolicited* igmp reports. There is *no* querier supplied data
> yet. The first querier supplied data (or any other unsolicited igmp
> report) will immediately stop the unsolicited reports and then will
> continue to respond in randomized intervals based on the data that the
> querier has supplied.
>
>

There certainly seems to be some backing for part of Christoph's concept in
the IETF rfc's.  I've posted the relevant sections below.  IGMPv2 doesn't specify
a limit on retransmissions of an unsolicited Join, only that they stop once
multicast traffic is received. While IGMPv2 defines an "Unsolicited Report
Interval" default of 10 seconds, it appears that this is a significant enough
issue that the later IGMPv3 document calls out a default of 1 second, and
goes on to define a "Robustness Variable" and talks about the same case that
Christoph is trying to mitigate.

However, both rfc's *do* specify that the random timers should be used based
on a value called the "unsolicited report interval".

Perhaps implementing the IGMPv3 capability with kernel parameters for an
"unsolicited report interval" and "robustness variable" would satisfy
Christoph's issue?

-Bob Arendt

rfc2236 IGMPv2  =============================
Section 3 .... page 4 para 2
    When a host joins a multicast group, it should immediately transmit
    an unsolicited Version 2 Membership Report for that group, in case it
    is the first member of that group on the network.  To cover the
    possibility of the initial Membership Report being lost or damaged,
    it is recommended that it be repeated once or twice after short
    delays [Unsolicited Report Interval].

Section 6 ...  page 8 para 4
- "start timer" for the group on the interface, using a delay value
      chosen uniformly from the interval (0, Max Response Time], where
      Max Response time is specified in the Query.  If this is an
      unsolicited Report, the timer is set to a delay value chosen
      uniformly from the interval (0, [Unsolicited Report Interval] ].

8.10.  Unsolicited Report Interval  (page 18)
    The Unsolicited Report Interval is the time between repetitions of a
    host's initial report of membership in a group.  Default: 10 seconds.

rfc3376 IGMPv3  ============================
Section 5.1 page 19, near end
    (note - unsolicited Join is a type of State-Change report)
    To cover the possibility of the State-Change Report being missed by
    one or more multicast routers, it is retransmitted [Robustness
    Variable] - 1 more times, at intervals chosen at random from the
    range (0, [Unsolicited Report Interval]).

8.11. Unsolicited Report Interval  (page 41)
    The Unsolicited Report Interval is the time between repetitions of a
    host's initial report of membership in a group.  Default: 1 second.

8.1. Robustness Variable (page 39)
    The Robustness Variable allows tuning for the expected packet loss on
    a network.  If a network is expected to be lossy, the Robustness
    Variable may be increased.  IGMP is robust to (Robustness Variable -
    1) packet losses.  The Robustness Variable MUST NOT be zero, and
    SHOULD NOT be one.  Default: 2

8.14.1. Robustness Variable  (page 41/42)
    The Robustness Variable tunes IGMP to expected losses on a link.
    IGMPv3 is robust to (Robustness Variable - 1) packet losses, e.g., if
    the Robustness Variable is set to the default value of 2, IGMPv3 is
    robust to a single packet loss but may operate imperfectly if more
    losses occur.  On lossy subnetworks, the Robustness Variable should
    be increased to allow for the expected level of packet loss. However,
    increasing the Robustness Variable increases the leave latency of the
    subnetwork.  (The leave latency is the time between when the last
    member stops listening to a source or group and when the traffic
    stops flowing.)
