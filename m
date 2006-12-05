From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 5 Dec 2006 20:26:50 +0300
Message-ID: <20061205172649.GA20229@2ka.mipt.ru>
References: <20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com> <20061205050725.GA26033@2ka.mipt.ru> <1165330925.16087.13.camel@stevo-desktop> <20061205151905.GA18275@2ka.mipt.ru> <1165333198.16087.53.camel@stevo-desktop> <20061205155932.GA32380@2ka.mipt.ru> <1165335162.16087.79.camel@stevo-desktop> <20061205163008.GA30211@2ka.mipt.ru> <1165337245.16087.95.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52277 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968502AbWLEReM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 12:34:12 -0500
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1165337245.16087.95.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 05, 2006 at 10:47:25AM -0600, Steve Wise (swise@opengridcomputing.com) wrote:
> > And if there were a dataflow between addr/port a.b to addr/port c.d
> > already, it will either terminated?
> > 
> > Considering the following sequence:
> > handlers->t3c_handlers->sched()->work_queue->work_handlers()->for
> > example CPL_PASS_ACCEPT_REQ->pass_accept_req() - it just parses incoming
> > skb and sets port/addr/route and other fields to be used as a base for rdma
> > connection. What if it just a usual network packet from kernelspace or 
> > userspace with the same payload as should be sent by remote rdma system?
> > 
> 
> That skb isn't a network packet.  Its a CPL_PASS_ACCEPT_REQ message (see
> struct cpl_pass_accept_req in the Ethernet driver t3_cpl.h).  If the
> RDMA driver hadn't registered to listen on that addr/port, it would
> never get this skb.  Once a connection is established, the MPA messages
> (and any TCP payload data) is delivered to the RDMA driver in the form
> of skb's containing struct cpl_rx_data.  So these skbs aren't just TCP
> packets at all.  They either control messages or TCP payload. Either way
> they are encapsulated in CPL message structures.
> 
> Does this make sense?
 
Almost - except the case about where those skbs are coming from?
It looks like they are obtained from network, since it is ethernet
driver, and if they match some set of rules, they are considered as valid 
MPA negotiation protocol.

If it is correct, it means that any packet in the network can be
potentially 'stolen' by rdma hardware, although it was part of the usual
dataflow. 
If that packets are not from ethernet network, but from different
low-level, then there is a question (besides why this driver is called
ethernet if it manages different hardware) about how connection over
that different media is being setup and since packets contain perfectly
valid IP addresses and ports.

And, btw, not related question - does postponing the whole skb multiplexing 
to work queue result in lower latency and/or higher speed?
Since there are a lot of tricks introduced to minimize gap between
interrupt/napi polling and protocol processing, so such huge postponing
with the whole context switch looks strange.

-- 
	Evgeniy Polyakov
