From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 05 Dec 2006 10:47:25 -0600
Message-ID: <1165337245.16087.95.camel@stevo-desktop>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	 <20061202224958.27014.65970.stgit@dell3.ogc.int>
	 <20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com>
	 <20061205050725.GA26033@2ka.mipt.ru>
	 <1165330925.16087.13.camel@stevo-desktop>
	 <20061205151905.GA18275@2ka.mipt.ru>
	 <1165333198.16087.53.camel@stevo-desktop>
	 <20061205155932.GA32380@2ka.mipt.ru>
	 <1165335162.16087.79.camel@stevo-desktop>
	 <20061205163008.GA30211@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:33974 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968445AbWLEQr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 11:47:27 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061205163008.GA30211@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-05 at 19:31 +0300, Evgeniy Polyakov wrote:
> On Tue, Dec 05, 2006 at 10:12:42AM -0600, Steve Wise (swise@opengridcomputing.com) wrote:
> > Ah.  Data from an offloaded connection cannot leak into the main stack
> > nor vice-verse.  We can take an active RDMA connection establishment as
> > an example if you want:  Once the message is sent to the HW to "setup a
> > TCP connection from addr/port a.b to addr/port c.d", then packets on
> > that connection (that 4-tuple) will always be delivered to the RDMA
> > driver, not the native stack.  If the the packet received after the
> > connection is setup is -not- an MPA reply (in this example), then the
> > connection is aborted.  Once the connection is aborted.  So no leaking
> > can happen.
>  
> And if there were a dataflow between addr/port a.b to addr/port c.d
> already, it will either terminated?
> 
> Considering the following sequence:
> handlers->t3c_handlers->sched()->work_queue->work_handlers()->for
> example CPL_PASS_ACCEPT_REQ->pass_accept_req() - it just parses incoming
> skb and sets port/addr/route and other fields to be used as a base for rdma
> connection. What if it just a usual network packet from kernelspace or 
> userspace with the same payload as should be sent by remote rdma system?
> 

That skb isn't a network packet.  Its a CPL_PASS_ACCEPT_REQ message (see
struct cpl_pass_accept_req in the Ethernet driver t3_cpl.h).  If the
RDMA driver hadn't registered to listen on that addr/port, it would
never get this skb.  Once a connection is established, the MPA messages
(and any TCP payload data) is delivered to the RDMA driver in the form
of skb's containing struct cpl_rx_data.  So these skbs aren't just TCP
packets at all.  They either control messages or TCP payload. Either way
they are encapsulated in CPL message structures.

Does this make sense?



