From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 6 May 2016 11:25:14 +0200
Message-ID: <20160506112514.47f6e9dc@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
	<20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbcEFJZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 05:25:18 -0400
In-Reply-To: <20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 May 2016 14:57:07 +0900, Simon Horman wrote:
> On Thu, May 05, 2016 at 10:37:08AM -0700, pravin shelar wrote:
> > On transmit side you are using mac_len to detect l3 packet, why not do
> > same while extracting the key?

I agree. The skb should be self-contained, i.e. it should be obvious
whether it has the MAC header set or not just from the skb itself at
any point in the packet processing. Otherwise, I'd expect things like
recirculation to break after push/pop of eth header.

> Unfortunately mac_len can't be relied on here, emprically it has the same
> value (28 in my tests) for both the TEB and layer3 case above.

That's strange, it looks like there's something setting the mac header
unconditionally in ovs code. We should find that place and change it.

The ARPHRD_NONE interfaces don't even set mac_header and mac_len, this
will need to be set by ovs upon getting frame from such interface. 

> Perhaps that could be changed by futher enhancements in the tunneling code
> but I think things are symetric as they stand:
> 
> * On recieve skb->protocol can be read to distinguish TEB and layer3 packets
> * On transmit skb->protocol should be set to distinguish TEB and layer3 packets

Yes, but you need to act upon this directly after receiving the
frame/just before sending the frame and set up an internal flag that
will be used throughout the code. That way, the packet can be handed
over to different parts of the code, recirculated, etc. without
worries. skb->mac_len is probably a good candidate for such flag.

 Jiri
