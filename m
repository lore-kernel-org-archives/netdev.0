From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Thu, 4 May 2017 14:00:35 +0200
Message-ID: <20170504120035.GQ8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125254.GF8029@lunn.ch>
 <20170504063156.GA7620@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50377 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751904AbdEDMAk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 08:00:40 -0400
Content-Disposition: inline
In-Reply-To: <20170504063156.GA7620@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 04:31:57PM +1000, Gavin Shan wrote:
> On Wed, May 03, 2017 at 02:52:54PM +0200, Andrew Lunn wrote:
> >On Wed, May 03, 2017 at 02:44:39PM +1000, Gavin Shan wrote:
> >> This introduces /sys/kernel/debug/ncsi/eth0/pkt. The debugfs entry
> >> can accept parameters to produce NCSI command packet. The received
> >> NCSI response packet is dumped on read. Below is an example to send
> >> CIS command and dump its response.
> >> 
> >>    # echo CIS,0,0 > /sys/kernel/debug/ncsi/eth0/pkt
> >>    # cat /sys/kernel/debug/ncsi/eth0/pkt
> >>    NCSI response [CIS] packet received
> >> 
> >>    00 01 dd 80 00 0004 0000 0000
> >
> >Could this be done with a raw socket for Tx and
> >libpcap/tcpdump/wireshart for Rx?
> >
> 
> Andrew, it's really good question. Unfortunately, I don't think it can
> be done solely by raw socket to transmit NCSI command packet because the
> [packet sequence number] field in the packet can't be same to any used ones.
> Otherwise the remote NIC will be confused and start to reponse abnormally.

Just to make sure i'm on the same page. We are talking about:

https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.1.pdf

and the sequence number is the Instance ID. This is an 8-bit number,
and if it receives a message with the previously used IID, it should
assume it is a re-transmit of the request and send back the old
response. It is a very simple scheme, no windowing, only one
outstanding command/response, just one response buffered in case of a
re-transmit.

> We could reserve some sequence number to be used by raw socket.

I don't think that works. You can only have one command
'inflight'. Packets from a raw socket would have to go through your
state machine. Which makes it complex.

libpcap should however still work. So you should probably do all the
receive side in user space.

      Andrew
