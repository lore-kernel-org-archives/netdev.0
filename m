From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Mon, 26 Jan 2015 15:32:07 -0600
Message-ID: <1422307927.3474.12.camel@dcbw.local>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
		 <20150124.231432.1788575004982971514.davem@davemloft.net>
		 <20150125072101.GA25495@angus-think.lan> <54C519B3.9050905@codeaurora.org>
	 <1422284628.2393.4.camel@dcbw.local>
	 <028401d03983$6ed4e750$4c7eb5f0$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	"'Vadim Kochan'" <vadim4j@gmail.com>
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756243AbbAZVcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 16:32:12 -0500
In-Reply-To: <028401d03983$6ed4e750$4c7eb5f0$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-26 at 09:16 -0700, Harout Hedeshian wrote:
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Dan Williams
> > Sent: Monday, January 26, 2015 8:04 AM
> > To: Harout Hedeshian
> > Cc: David Miller; netdev@vger.kernel.org; Vadim Kochan
> > Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable
> > MTU updates from RA
> > 
> > On Sun, 2015-01-25 at 09:28 -0700, Harout Hedeshian wrote:
> > > On 01/25/2015 12:21 AM, Vadim Kochan wrote:
> > > > On Sat, Jan 24, 2015 at 11:14:32PM -0800, David Miller wrote:
> > > >> From: Harout Hedeshian <harouth@codeaurora.org>
> > > >> Date: Tue, 20 Jan 2015 10:06:05 -0700
> > > >>
> > > >>> The kernel forcefully applies MTU values received in router
> > > >>> advertisements provided the new MTU is less than the current. This
> > > >>> behavior is undesirable when the user space is managing the MTU.
> > > > Instead
> > > >>> a sysctl flag 'accept_ra_mtu' is introduced such that the user
> > > >>> space can control whether or not RA provided MTU updates should be
> > applied.
> > > > The
> > > >>> default behavior is unchanged; user space must explicitly set this
> > > > flag
> > > >>> to 0 for RA MTUs to be ignored.
> > > >>>
> > > >>> Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
> > > >> Under what circumstances would userland ignore a router advertized
> > > >> MTU, and are the RFCs ok with this?
> > > >> --
> > > >> To unsubscribe from this list: send the line "unsubscribe netdev"
> > > >> in the body of a message to majordomo@vger.kernel.org More
> > > >> majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > Hi,
> > > >
> > > > I don't know if it make sense but I had the same use case when was
> > > > working on supporting IPv6 infrastructure for home gateway.
> > > > One of the provider had requirements to have ability set force IPv6
> > > > MTU value via TR parameters and disable update it via RA.
> > > Hi David,
> > >
> > > We are optionally allowing the kernel shift this responsibility to the
> > > userland. The idea would be that the kernel would ignore it, not so
> > > much the userland. Just like Vadim, we may not want to use the MTU
> > > value which comes from the network. Instead, we get an MTU value from
> > > the cellular modem via configuration message, and that is the MTU we
> > use.
> > 
> > Are you talking about an ethernet interface exposed by the modem, or a
> > separate network interface connected to a normal LAN?  In the modem
> > case, why would the network-provided RA's MTU be incorrect, but the
> > modem's MTU be correct?  If the normal LAN case, why would the modem's
> > MTU be correct for a different network that is broadcasting its own RAs?
> > Just curious...
> > 
> > Dan
> 
> Hi Dan,
> 
> This is a really good question. In the case of a normal LAN, we will allow the kernel to handle the MTU values as they have been today (basically, keep the accept_ra_mtu=1). The issue is not really about the correctness of the RA MTU value (we assume this value is correct, otherwise we are in serious trouble).The issue is on the modem interfaces. To the modem, each protocol family is its own interface. This analogy breaks down for us in Linux because v4 and v6 are fundamentally the same net_device interface. From what I can tell, there is no /proc/sys/net/ipv4/conf/<dev>/mtu which means that IPv4 will take the MTU value from dev->mtu (see ipv4_mtu() ). In contrast, IPv6 maintains a separate MTU and will apply the RA MTUs such that they are less than the device's MTU (dev->mtu). For consi
 stency, we have been asked to always pick the minimum value of the IPv4 and IPv6 MTU, and that will become the overall interface MTU. If the kernel goes and changes the V6 MTU without us kn!
 ow!
>  ing, the userland daemon which maintains the MTU parity will be out of sync. We *could* theoretically let the kernel apply RA MTU updates and we listen for netlink events, but that is unnecessarily complicated as we are already listening in multiple places for these MTU updates. Additionally, we have a problem where the default dev->mtu is 1500 bytes. If we have an IPv6-only network, then it is possible that the network will want to use an MTU > 1500 (esp. multimedia optimized carrier networks). Currently, ndisc.c compares the new MTU value with dev->mtu, if bigger, the RA is ignored. I don't see a good alternative to this because there is no way for ndisc.c to know what the device's maximum physical capabilities are (or that we even want to use such a large MTU). Because of that, we ha
 ve to have an out-of-band mechanism to adjust the interface MTU since we know that the hardware is capable of transmitting packets greater than 1500 bytes. Thus, instead of letting the kern!
 el!

I believe the IPv4 MTU is taken from the device MTU, eg 'ip link set dev
wwp0s26f7u2i8 mtu XXXX'.  I believe that's also where the IPv6 MTU is
taken from, unless it's set via /proc.

But thanks for the explanation, it makes sense.

Dan

>   handle RA MTUs in some special circumstances, it is safer and!
>   cleaner to disable RA MTUs on the modem interface altogether and let userland pick the correct MTU. 
> 
> One way to clean up this mess would be to make some changes in the way the kernel handles MTUs. 
> 1. Make dev->mtu actually be the MTU the device is capable. For example, jumbo frame capable devices would set this to 9000 upon enumeration instead of 1500. This value would not be editable from userland. There would no longer be a need for driver to implement the MTU adjustment ndo.
> 2. *ALL* protocols must maintain their own MTU values. This would mean a new per-device proc entry for IPv4 at a minimum. The defaults of these values can remain 1500.
> 
> If we did this, then the kernel can apply RA MTUs > 1500, and we would get it for free (no changes in IPv6 code). IPv4 would be parity with IPv6 in terms of decoupling MTU from dev->mtu. This means userland can completely not care about the IPv6 MTU, and we can push back on the MTU consistency requirement. Of course, this is a pretty drastic change in interpretation of dev->mtu and would break a lot of userland utilities. Or maybe we leave #1 editable in userland so the utilities and IOCTLs still work, however, userland will now have to additionally adjust IPv4 MTU...
> 
> If the kernel community likes this approach, I would be happy to upload some patches which creates a new definition for IPv4 MTU. I think #1 will need more discussion.
> 
> If v4 and v6 were truly decoupled, then we could get rid of this minimum selection mess and special case handling for large IPv6 MTUs and this patch could go away.
> 
> 
> Thanks,
> Harout
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
