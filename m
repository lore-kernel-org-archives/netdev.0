From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Mon, 29 Jun 2015 12:56:47 -0700
Message-ID: <64eee574bcb29f8ec0a6c6536a910d01@imap.linux.ibm.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
 <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
 <0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
 <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
 <3df94e04daebca29c94b6d32fb372177@imap.linux.ibm.com>
 <CALx6S35-GKW+hgn-9Y5a87hETfetKuusALFUDZ5vzwrtQSiypA@mail.gmail.com>
 <3036c2aaa52dc2817e674a77b5eac24d@imap.linux.ibm.com>
 <CALx6S37+es-QD-_41O4cc59_oEX2UeeibZgjd8uOvTcPMHO+nA@mail.gmail.com>
 <CAJ3xEMj_3+p9CGH8bkF26E9X0KGQdTr14S-vACS7zKcPPO6pQA@mail.gmail.com>
 <CALx6S35B99cu=oyYcz4fSgAeA2ho6b6-H6vWg=Vq0s1UEVf0Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, J Kidambi <jkidambi@us.ibm.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:40066 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbbF2T4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 15:56:50 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Mon, 29 Jun 2015 13:56:50 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1838419D8026
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 13:47:49 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5TJsNLm39911622
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 12:54:23 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5TJulNe023653
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 13:56:49 -0600
In-Reply-To: <CALx6S35B99cu=oyYcz4fSgAeA2ho6b6-H6vWg=Vq0s1UEVf0Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-06-28 14:17, Tom Herbert wrote:
> On Sun, Jun 28, 2015 at 1:19 PM, Or Gerlitz <gerlitz.or@gmail.com> 
> wrote:
>> On Fri, Jun 26, 2015 at 10:59 PM, Tom Herbert <tom@herbertland.com> 
>> wrote:
>> [...]
>>> Looks like GRO was never implemented for vxlan tunnels. The driver is
>>> simply calling netif_rx instead of using the GRO cells 
>>> infrastructure.
>>> geneve is doing the same thing. For other tunnels which are used in
>>> foo-over-udp (GRE, IPIP, SIT) ip_tunnel_rcv is called which in turn
>>> calls gro_cells_receive.
>> 
>> Tom,
>> 
>> Since v3.14, when a tunneled (say VXLAN/GRE) packets are received on
>> the physical interface, they go through GRO aggregation before being
>> delivered up to the tunnel "device" (e.g either vxlan/gre netdevice or
>> OVS vxlan/gre vport) -- so in that respect, can you elaborate a little
>> further why we want to GRO them again?
>> 
> 
> If we don't have a verifiable checksum from the device GRO is not
> applied to UDP encapsulated packets at the physical interface, but can
> be done at the tunnel. Ramu is seeing poor performance because there
> is no GRO at all is happening, so doing it at the tunnel is an
> improvement. As I described before, avoiding checksum calculation in
> the device NAPI still seems to be a good thing (in my testing I do see
> a slight regression if we were to do the checksum in device NAPI).
> 
> btw, the real "fix" for this is for NICs to provide CHECKSUM_COMPLETE! 
> :-)
> 
> Tom
> 
>> Or.

When I force the sender to set a non-zero UDP checksum for vxlan 
encapsulated tcp-stream,
then, I can see the gro activated at the receiver (82599ES nic),
and the throughput is ~8.5Gbps !

So, to get gro to be effective for the 82599ES receiver, the sender 
needs to set the UDP
checksum.  If the sender does NOT set the UDP checksum (udp-checksum == 
0), then the gro-cells patch suggested by Tom
will perform gro at the tunnel device level.
