From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 10:42:25 -0500
Message-ID: <20150226154225.GA5940@oracle.com>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226112252.GF9840@oracle.com>
 <20150226113942.GC1973@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, john.r.fastabend@intel.com,
	jhs@mojatatu.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	simon.horman@netronome.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36055 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbBZPna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:43:30 -0500
Content-Disposition: inline
In-Reply-To: <20150226113942.GC1973@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Sure. If you look into net/openvswitch/vport-vxlan.c for example, there
> is a socket created by vxlan_sock_add.
>  vxlan_rcv is called on rx and vxlan_xmit_skb to xmit.
   :
> What I have on mind is to allow to create tunnels using "ip" but not as
> a device but rather just as a wrapper of these functions (and others alike).

Could you elaborate on what the wrapper will look like? will
it be a socket? or something else?

For contextual comparison:
  For RDS, the listen side of the TCP socket is created when the 
  rds_tcp module is initialized. The client side is created when a RDS
  packet is sent out In the case of RDS, something similar is achieved
  by creating a PF_RDS socket, which can then be used as a datagram socket
  (i.e., no need to do connect/accept). In the rds module, what happens is
  that the rds_sock gets plumbed up with the underlying kernel TCP socket.
  
  The the fanout per RDS port on the receive side happens via ->sk_data_ready
  (in rds_tcp_ready). On the send side, rds_sendmsg sets up the client
  socket (if necessary).  
  
  All of this is done such that multiple RDS sockets share a single 
  underlying kernel tcp socket.
  
  But perhaps there is one significant difference for vxlan- vxlan
  is encapsulating L2 frames in UDP, so the socket layering model
  may not fit so well, except when uspace is creating an entire L2 frame
  (which may be fine with ovs/dpdk, I'm not sure what scenarios you
  have in mind).

> To identify the instance we name it (OVS has it identified and vport).

not sure I follow the name-space you have in mind here, how is fanout 
going to be achieved?  (for rds, we determine which endpoint should get
the packet  based on the rds sport/dport)

> After that, tc could allow to attach ingress qdisk not only to a device,
> but to this named socket as well. Similary with tc action mirred, it would
> be possible to forward not only to a device, but to this named socket as
> well. All should be very light.

This is the part that I'm interested in.. in the RDS case, the flows
are going to be specified based on the sport/rport in the rds_header,
but as far as the rest of the tcp/ip stack is concerned, the rds_header
is just opaque payload bytes.  I realize tc and iptables support that
DPI in theory, and that one can use CLI interfaces to set this up
(I dont know if the system calls used by  tc are published as a
stable library to applications?) but I would be interested in 
kernel-socket options to set up the tc hooks so that operations on
the RDS socket can be translated into flows and other config 
on the shared tcp socket. 

> I'm not talking about QoS at all. See the description above.

Understood, but I mentioned qos because tc is typically used to specify
flows for QoS managing algorithms like cbq.

I realize that you are focussed on offloading some of this to h/w,
but you mentioned a "name-based" socket, and tc hooks (for flows in the
inner L2 frame?), and thats the design-detail I'm most interested in..

--Sowmini
