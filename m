From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Mon, 6 Dec 2010 11:35:34 -0600
Message-ID: <20101206173534.GC13628@auslistsprd01.us.dell.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:27099 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab0LFRfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 12:35:37 -0500
Content-Disposition: inline
In-Reply-To: <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 11:33:12AM +0200, Eilon Greenstein wrote:
> The main difference here is that we are talking about multiple PFs - so
> each can be brought up or down independently of the others. So there is
> no one master PF that controls the port and once it is brought down, the
> port is down too. At any given moment, one of the PFs is acting as the
> port master and controls the shared HW - but once this PF is brought
> down, another PF is seamlessly taking over.

Hmm, that complicates things a bit.
 
> I think the main difference is that we have real PCI functions and not
> virtual ones. On the same PCI bus, we have two physical ports, and 8
> physical functions - 4 on each port. I agree that exposing which
> functions are using the same port can really help - so I'm open to
> suggestions on the "how".

We really need, for NPAR, SR-IOV, and the Chelsio
multiple-ports-per-PCI-device model, a "network port" abstraction in
sysfs.  We need the ability to map M ports to N PCI devices, and
expose that mapping in sysfs.

For SR-IOV, biosdevname follows the physfn and virtfn* pointers to map
VFs to the PF.  But it assumes 1 PF -> 1 port.  For the Intel 1GbE and
10GbE cards I have, this is true, but nothing says it has to be true.

Maybe something like:

/sys/class/net_port/<port_name>/<ifname> -> /sys/class/net/<ifname>

/sys/class/net/<ifname>/port -> /sys/class/net_port/<port_name>

This introduces the idea of ports, though adds the complication of
needing to name them somehow.  But it would expose the relationship of
each net interface to a specific port, as well as allow multiple
interfaces per port, conceptually independent of the PCI device
mapping.  That way, each driver, which must know the mapping somehow,
could fill these links out?

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
