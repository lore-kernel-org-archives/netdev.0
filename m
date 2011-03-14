From: Christian Hesse <mail@eworm.de>
Subject: Re: sky2, vlan and nat/masquerading
Date: Mon, 14 Mar 2011 11:11:05 +0100
Message-ID: <20110314111105.5a62e092@leda.vpn.lugor.de>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
	<AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([80.190.48.209]:34954 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab1CNKLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:11:12 -0400
In-Reply-To: <AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Mar 2011 16:39:02 -0800 Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Mar 9, 2011 at 9:15 AM, Christian Hesse <mail@eworm.de> wrote:
> > Hello everybody,
> >
> > I have a Samsung NF310, running kernel 2.6.37.3 with a patch to make my
> > ethernet controller work for vlans. It was discussed with the subject
> > "sky2: convert to new VLAN model (v0.2)" and made it to to kernel tree
> > with commit 86aa77854f47ab6f5f9c687507af1f57d2b89004.
> 
> Does that commit actually change the behavior that you are seeing?  It
> shouldn't be necessary for correct functionality.

Plain 2.6.37 did not work at all. Received packets with vlan tag did not make
it to the vlan interface but ended on the native ethernet interface iirc.

> Do you know if this
> worked at some point in the past?

This was the first time I used nat with two vlan interfaces.

> > However it does not work properly, here are the details:
> >
> > * Switch with one trunk port and several port in corresponding vlan ports
> > * Host connected to one of the vlan ports
> > * Samsung Netbook (see above) connected to the trunk port.
> >
> > I get an IP address 192.168.x.x/24 via DHCP on interface connected to
> > vlan 1. The interface connected to vlan 2 has 172.16.0.1/24 and serves
> > addresses via DHCP. The system is set up to masquerade from 172.16.0.1/24.
> >
> > I can access my netbook from the host in vlan 2, however I can not access
> > anything behind. The packets contain a broken vlan tag and the host does
> > not recognize them.
> 
> When you say "the host does not recognize them", what host do you
> mean?  This is a different host on vlan 1?

No, this is the host in vlan2.
The packet contains the vlan tag with vid 0. It should not. The host discards
it as it does not have a vlan interface with vid 0.

> > I've attached a tcpdump log. Please take a look at the icmp echo request
> > and reply packets, especially the last one.
> 
> What do you mean by broken?  I only see one tag in the trace, which is
> on the packet originating from 192.168.100.3 and it has a vid of 0.

The tag itself is valid. But it should not be there as it comes from
a native ethernet port.

> Where was this trace captured?

This trace was captured on the host in vlan2.

Ok, let me explain step by step:

* Host sends icmp echo request (172.16.0.21 -> 192.168.100.3) to router
  172.16.0.1, the packet is untagged.
* Switch receives the packet on native interface with vid 2, tags it and sends
  it to the trunk)
* Netbook receives the packet from trunk, untags it an queues it to vlan
  interface 2.
* Netbook nats the packet (192.168.x.140 > 192.168.100.3), tags it with vlan
  2 and sends it to the trunk.
* Switch receives the packet from trunk, untags it and sends it to native
  interface with vlan 1.
* The packet and its answer (192.168.100.3 -> 192.168.x.140) make their way
  through the network.
* Switch receives the icmp echo reply on native interface with vlan 1, tags
  it and sends it to the trunk
* Netbook receives the packet from trunk, untags it an queues it to vlan
  interface 1.
* Netbooks restores the original addresses from nat (192.168.100.3 ->
  172.16.0.21), _tags_it_with_vlan_0_, tags it with vlan 2 and sends it to the
  trunk.
* Switch receives packet from trunk, untags it (the tag with vid 2) and sends
  it to native interface with vid 2.
* Host receives the packet and discards it as it still contains a vlan tag
  with vid 0.
-- 
Schoene Gruesse
Chris
