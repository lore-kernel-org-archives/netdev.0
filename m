From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Thu, 7 Jul 2016 10:32:12 -0700
Message-ID: <577E921C.5050904@gmail.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34434 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbcGGRcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 13:32:15 -0400
Received: by mail-pa0-f66.google.com with SMTP id us13so2286456pab.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 10:32:14 -0700 (PDT)
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2016 10:32 PM, Gavin Shan wrote:
> This series rebases on David's linux-net git repo ("master" branch). It's
> to support NCSI stack on net/farady/ftgmac100.c
> 
> The following figure gives an example about how NCSI is deployed: The NCSI is
> specified by DSP0222, which can be downloaded from the following link here
> (http://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.0.pdf).
> 
>    * The NC-SI (aka NCSI) is defined as the interface between a (Base) Management
>      Controller (BMC) and one or multiple Network Controlers (NC) on host side.
>      The interface is responsible for providing external network connectivity
>      for BMC.
>    * Each BMC can connect to multiple packages, up to 8. Each package can have
>      multiple channels, up to 32. Every package and channel are identified by
>      3-bits and 5-bits in NCSI packet. At one moment, one channel is active to
>      provide service.
>    * NCSI packet, encapsulated in ethernet frame, has 0x88F8 in the protocol
>      field. The destination MAC address should be 0xFF's while the source MAC
>      address can be arbitrary one.
>    * NCSI packets are classified to command, response, AEN (Asynchronous Event
>      Notification). Commands are sent from BMC to host for configuration and
>      information retrival. Responses, corresponding to commands, are sent from
>      host to BMC for confirmation and requested information. One command should
>      have one and only one response. AEN is sent from host to BMC for notification
>      (e.g. link down on active channel) so that BMC can take appropriate action.
> 
>    +------------------+        +----------------------------------------------+
>    |                  |        |                     Host                     |
>    |        BMC       |        |                                              |
>    |                  |        | +-------------------+  +-------------------+ |
>    |    +---------+   |        | |     Package-A     |  |     Package-B     | |
>    |    |         |   |        | +---------+---------+  +-------------------+ |
>    |    |   NIC   |   |        | | Channel | Channel |  | Channel | Channel | |
>    +----+----+----+---+        +-+---------+---------+--+---------+---------+-+
>              |                             |                      |
>              |                             |                      |
>              +-----------------------------+----------------------+
> 
> The design for the patchset is highlighted as below:
> 
>    * The NCSI interface is abstracted with "struct ncsi_dev". It's registered
>      when net_device is created, started to work by calling ncsi_start_dev()
>      when net_device is opened (ndo_open()). For the first time, NCSI packets
>      are sent and received to/from the far end (host in above figure) to probe
>      available NCSI packages and channels. After that, one channel is chosen as
>      active one to provide service.
>    * The NCSI stack is driven by workqueue and state machine internally.
>    * AEN (Asychronous Event Notification) might be received from the far end
>      (host). The currently active NCSI channel fails over to another available
>      one if possible. Otherwise, the NCSI channel is out of service.
>    * NCSI stack should be configurable through netlink or another mechanism,
>      but it's not implemented in this patchset. It's something TBD.
>    * The first NIC driver that is aware of NCSI: drivers/net/ethernet/faraday/ftgmac100.c

I know nothing about NCSI, pretty much like Jon Snow, but from a cursory
look at your patches, is not there a way to make the NCSCI capable
network devices strictly adhere to the net_device APIs and calling
conventions?

Even if the data flow is a little different than normal ethernet frames,
and there is not a good way to trap to intercept the delivery of NCSI
packets, one could imagine doing something ala DSA where you register a
fake ethertype for NCSI to hook a ptype_fun packet handler, augment
struct net_device with a ncsi_dev pointer, and do processing in
net/nsci/ for this device you know where the packet came from. You don't
need to have an officially assigned ethertype for this, see
netdev_uses_dsa() which just tests whether the traffic is tagged with a
particular tag and delivers packet to a protocol specific parser in
net/dsa/.

For packets on their way out you could imagine assigning them a specific
skb->protocol value and have the driver's transmit path do specific
things based on that.

Just an idea, I am not even sure this makes sense here, but what seems
to make sens to me is that if more network device drivers end up
supporting and transporting NCSI, we barely want them to know about that.
-- 
Florian
