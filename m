From: Graeme Smecher <gsmecher@threespeedlogic.com>
Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast address
 to ALE table
Date: Wed, 03 Sep 2014 12:01:40 -0700
Message-ID: <1409770900.15153.6.camel@fromme.threespeedlogic.local>
References: <1409682156.3334.16.camel@fromme.threespeedlogic.local>
	 <5406D128.3080304@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2s63.a2hosting.com ([75.98.166.66]:51893 "EHLO
	a2s63.a2hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbaICTBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 15:01:45 -0400
In-Reply-To: <5406D128.3080304@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mungathan,

FYI, I think the multicast bug I'm working on also affects dual EMAC
mode in upstream cpsw.c. I will add a 2.6.37-specific patch on my e2e
forum post (link below), but this is a heads-up for code you maintain.

Symptoms: each port in dual EMAC mode trashes the other port's multicast
reception.

Cause: cpsw_ndo_set_rx_mode does the following:

cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS << priv->host_port);

if (!netdev_mc_empty(ndev)) {
struct netdev_hw_addr *ha;

/* program multicast address list into ALE register */
netdev_for_each_mc_addr(ha, ndev) {
cpsw_add_mcast(priv, (u8 *)ha->addr);
}
}

This code can be invoked by eth0 or eth1, which have potentially
differing multicast lists. However, cpsw_ale_flush_multicast() trashes
ALL multicast entries in the ALE, affecting both ports. Only the entries
for the net_device that invoked cpsw_ndo_set_rx_mode() are restored.

To fix this, you will have to pass a correct port_mask to
cpsw_ale_flush_multicast(), and correct the free-entry check at the
bottom of cpsw_ale_flush_mcast().

best,
Graeme

On Wed, 2014-09-03 at 13:58 +0530, Mugunthan V N wrote: 
> Hi Graeme
> 
> There is already a support for add multicast in v2.6.37 cpsw driver, if
> there is a bug and you found a fix, can go a head and fix that. The
> patch you have mentioned is an upstream patch with was done on top of
> am335x platform, so there might be bugs fixed and added into the patch
> which are not in v2.6.37 cpsw driver.
> 
> Regards
> Mugunthan V N
> 
> On Tuesday 02 September 2014 11:52 PM, Graeme Smecher wrote:
> > Hi Mugunthan,
> > 
> >> On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
> >>> Adding multicast address to ALE table via netdev ops to subscribe, transmit
> >>> or receive multicast frames to and from the network
> >>
> >> Is this somehow related to the time stamping function? If so, how?
> >>
> >> Thanks,
> >> Richard
> > 
> > Can you give me a brief description of this (relatively ancient) patch? Your
> > original e-mail is visible here:
> > 
> > 	http://marc.info/?l=linux-netdev&m=135042754927177&w=2
> > 
> > I'm wondering if this patch needs to be backported to older CPSW driver
> > snapshots (specifically, TI's 2.6.37 branch for dm81xx.) It appears to
> > fix a multicast bug I'm tracking down, but it's difficult to know for
> > sure without a good description of what problem the patch addresses. (I
> > don't want to commit code that fixes my hardware by accident.)
> > 
> > For a little more information, you can refer to my e2e.ti.com post:
> > 
> > 	http://e2e.ti.com/support/dsp/davinci_digital_media_processors/f/716/t/365586.aspx
> > 
> > I'm slowly learning about ALE filtering, but a quick reply from a
> > domain expert would be very helpful.
> > 
> > best,
> > Graeme
> > 
> 
