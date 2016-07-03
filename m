From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Mon, 4 Jul 2016 01:03:06 +0300
Message-ID: <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, benh@kernel.crashing.org,
	joel@jms.id.au, weixue@trustnetic.com, yuvali@mellanox.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33653 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160AbcGCWDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 18:03:08 -0400
Received: by mail-oi0-f66.google.com with SMTP id w141so20737077oia.0
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 15:03:07 -0700 (PDT)
In-Reply-To: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 3, 2016 at 8:32 AM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
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


FWIW, talking to a colleague, he made a comment that some of the text
above is wrong:

AENs are sent from NIC to BMC. Not from Host to BMC.

The traffic between a BMC and a NIC is over RBT if it is formatted as
NC-SI packets. This is not over network traffic....

Or.
