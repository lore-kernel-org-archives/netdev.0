From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/2] vxlan: Remote checksum offload
Date: Tue, 13 Jan 2015 16:40:11 +0000
Message-ID: <20150113164011.GO20387@casper.infradead.org>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
 <1421110838-5146-3-git-send-email-therbert@google.com>
 <20150113012626.GD20387@casper.infradead.org>
 <20150113114443.GK20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53258 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbAMQkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:40:13 -0500
Content-Disposition: inline
In-Reply-To: <20150113114443.GK20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Moving this discussion to the thread of the respective patch]

On 01/13/15 at 08:16am, Tom Herbert wrote:
> On 01/13/15 at 11:44am, Thomas Graf wrote:
> > The major difference here is that we have to consider backwards
> > compatibility specifically for VXLAN. Your initial feedback on GPE
> > actually led me to how I implemented GBP.
> >
> > I think the axioms we want to establish are as follows:
> >  1. Extensions need to be explicitly enabled by the user. A previously
> >     dropped frame should only be processed if the user explitly asks
> >     for it.
> >  2. As a consequence: only share a VLXAN UDP port if the enabled
> >     extensions match (vxlan_sock_add), e.g. user A might want RCO
> >     but user B might be unaware. They cannot share the same UDP port.
> >
> > The 2nd lead me to introduce the 'exts' member to vxlan_sock so we can
> > compare it in vxlan_find_sock() and only share a UDP port if the
> > enabled extensions match.
> >
> RCO is represented in the socket in VXLAN flags (VLXAN_F_*). My patch
> also adds a flags to vxlan_sock which contains the VLXAN flags. For
> shared port, I suspect all the receive features must match, including
> receive checksum settings for instance, but we don't care about
> transmit side. To facilitate this, I would suggest splitting flags
> into o_flags and i_flags like ip_tunnel does, and then compare i_flags
> in vxlan_find_sock.

Not sure I understand why you want to omit the transmit side. If a
VXLAN socket with RCO TX enabled is found and shared with a user
who does not want RCO enabled, it will get RCO enabled frames which
will get dropped by non RCO VXLAN receivers.
