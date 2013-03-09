From: Adam Baker <linux@baker-net.org.uk>
Subject: Re: [Patch net] bridge: do not expire mdb entry when bridge still
 uses it
Date: Sat, 09 Mar 2013 22:46:02 +0000
Message-ID: <513BBBAA.2050800@baker-net.org.uk>
References: <1362708423-23932-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from april.london.02.net ([87.194.255.143]:56518 "EHLO
	april.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab3CIWqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 17:46:21 -0500
In-Reply-To: <1362708423-23932-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/13 02:07, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
>
> This is a long-standing bug and reported several times:
> https://bugzilla.redhat.com/show_bug.cgi?id=880035
> http://marc.info/?l=linux-netdev&m=136164389416341&w=2
>
> This bug can be observed in virt environment, when a KVM guest
> communicates with the host via multicast. After some time (should
> be 260 sec, I didn't measure), the multicast traffic suddenly
> terminates.
>
> This is due to the mdb entry for bridge itself expires automatically,
> it should not expire as long as the bridge still generates multicast
> traffic. It should expire when the bridge leaves the multicast group,
> OR when there is no multicast traffic on this bridge.
>
> I fix this by adding another bool which is set when there is
> multicast traffic goes to the bridge, cleared in the expire timer and
> when IGMP leave is received. I ran omping for 15 minutes, everything
> looks good now.
Despite Herbert's comment that he didn't think this patch was correct I 
decided to test it anyway and can confirm that it doesn't fix the issue 
for my configuration.

When Herbert Xu originally sent the patch series that caused the change 
in behaviour that triggered this issue 
(http://www.spinics.net/lists/netdev/msg194893.html) he noted that for 
IPv6 the bridge sends it's own IP address so it can potentially be 
elected as the active querier which he claimed is incorrect. I note 
however that a randomly selected Cisco page on configuring layer 2 IGMP 
snooping 
(http://www.cisco.com/en/US/docs/routers/asr9000/software/multicast/configuration/guide/mcasr9kigsn.html#wp1039776) 
suggests that when configuring a querier on a bridge it should be 
assigned a valid IP address. If it is believed that the use of 0.0.0.0 
as the IP address is what is causing strange behaviour on other devices 
then is there a good reason that a bridge rather than a router shouldn't 
be the active querier? If not then using the bridge IP address and 
having the querier enabled by default may be a reasonable solution 
(provided that our querier obeys the election rules and shuts up if it 
sees a query from a lower IP address that isn't 0.0.0.0). Just because a 
device is the elected querier for IGMP doesn't appear to mean it is 
required to perform any other routing functions.

Any thought on whether that would work - I don't have a device that 
misbehaves on seeing the bridge initiated queries so am unable to test 
if that solves that issue.

An alternative option would be to have a third state for our querier 
where it is only active if it has not seen a query for the Other Querier 
Present Interval but that still leaves the possibility of other devices 
behaving strangely because they have seen the queries we generate when 
they are first switched on.

Regards

Adam Baker

P.S. Sorry Stephen if you feel this is a now a question rather than a 
patch so, as per your previous mail, shouldn't go to individual 
developers but as it is also a NAK to a patch I wasn't comfortable 
trimming the CC list.
