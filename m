From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Mon, 9 May 2016 17:04:22 +0900
Message-ID: <20160509080420.GA4470@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
 <20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
 <20160506112514.47f6e9dc@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34486 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbcEIIEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 04:04:14 -0400
Received: by mail-pa0-f50.google.com with SMTP id r5so71784777pag.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 01:04:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160506112514.47f6e9dc@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 11:25:14AM +0200, Jiri Benc wrote:
> On Fri, 6 May 2016 14:57:07 +0900, Simon Horman wrote:
> > On Thu, May 05, 2016 at 10:37:08AM -0700, pravin shelar wrote:
> > > On transmit side you are using mac_len to detect l3 packet, why not do
> > > same while extracting the key?
> 
> I agree. The skb should be self-contained, i.e. it should be obvious
> whether it has the MAC header set or not just from the skb itself at
> any point in the packet processing. Otherwise, I'd expect things like
> recirculation to break after push/pop of eth header.
> 
> > Unfortunately mac_len can't be relied on here, emprically it has the same
> > value (28 in my tests) for both the TEB and layer3 case above.
> 
> That's strange, it looks like there's something setting the mac header
> unconditionally in ovs code. We should find that place and change it.

It seems to be caused by the following:

1. __ipgre_rcv() calls skb_pop_mac_header() which
   sets skb->mac_header to the skb->network_header.

2. __ipgre_rcv() then calls ip_tunnel_rcv() which calls
   skb_reset_network_header(). This updates skb->network_header to
   just after the end of the GRE header.

   This is 28 bytes after the old skb->network_header
   as there is a 20 byte IPv4 header followed by an
   8 byte GRE header.

3. Later, dev_gro_receive() calls skb_reset_mac_len().
   This calculates skb->mac_len based on skb->network_header and
   skb->mac_header. I.e. 28 bytes.


I think this may be possible to address by calling
skb_reset_network_header() instead of skb_pop_mac_header()
in __ipgre_rcv().

I think that would leave skb->mac_header and skb->network_header both
set to just after the end of the GRE header and result in mac_len of 0.
It looks like this owuld be for for both TEB and non-TEB GRE packets
and that OVS would need to check against mac_len, protocol and most
likely dev->type early on.

> The ARPHRD_NONE interfaces don't even set mac_header and mac_len, this
> will need to be set by ovs upon getting frame from such interface. 

Noted.

> > Perhaps that could be changed by futher enhancements in the tunneling code
> > but I think things are symetric as they stand:
> > 
> > * On recieve skb->protocol can be read to distinguish TEB and layer3 packets
> > * On transmit skb->protocol should be set to distinguish TEB and layer3 packets
> 
> Yes, but you need to act upon this directly after receiving the
> frame/just before sending the frame and set up an internal flag that
> will be used throughout the code. That way, the packet can be handed
> over to different parts of the code, recirculated, etc. without
> worries. skb->mac_len is probably a good candidate for such flag.

Its possible that I've overlooked something but as things stand I think
things look like this:

* ovs_flow_key_extract() keys off dev->type and skb->protocol.
* ovs_flow_key_extract() calls key_extract() which amongst other things
  sets up the skb->mac_header and skb->mac_len of the skb.
* ovs_flow_key_extract() sets skb->protocol to that of the inner packet
  in the case of TEB
* Actions update the above mentioned skb fields as appropriate.

So it seems to me that it should be safe to rely on skb->protocol
in the receive path. Or more specifically, in netdev_port_receive().

If mac_len is also able to be used then I think fine. But it seems to me
that it needs to be set up by OvS at least for the ARPHRD_NONE case. This
could be done early on, say in netdev_port_receive(). But it seems that
would involve duplicating some of what is already occurring in
key_extract().
