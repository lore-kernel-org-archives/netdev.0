From: Brent Cook <bcook@bpointsys.com>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Tue, 9 Jun 2009 14:30:31 -0500
Message-ID: <200906091430.32294.bcook@bpointsys.com>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com> <4A2E4A32.1060705@trash.net> <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gil Beniamini <gil.beniamini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 65-36-7-9.static.grandenetworks.net ([65.36.7.9]:44623 "EHLO
	bpointsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751885AbZFITp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 15:45:27 -0400
In-Reply-To: <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 June 2009 08:08:01 am Gil Beniamini wrote:
> Patrick,
> On the specific NIC (eth1) no vlan is defined, and in the new Linux
> the application receive NOTHING at all. In order to debug, I start
> "wireshark as root" and "wireshark" set PROMISC on, and the
> application start receive the raw packets as expected. Later I started
> setting PROMISC by my application, and it can receive the packets even
> when "wireshark" is not running.
> The problem that I have with PROMISC mode, is that I need to do the
> irelevant  unicast filtering in software rather than get it from the
> hardware (as it works in old kernel 2.6.20).
> Thanks a lot, Gil

One solution is to attach a BPF filter to the socket. Then you will only 
receive packets for whatever you are filtering. This is still in software, but 
it is higher up in the abstraction, and undoubtedly more efficient than doing 
it at the app level.

Simply compile the BPF program you wish to filter, e.g:

# tcpdump -dd vlan 4
{ 0x28, 0, 0, 0x0000000c },
{ 0x15, 0, 4, 0x00008100 },
{ 0x28, 0, 0, 0x0000000e },
{ 0x54, 0, 0, 0x00000fff },
{ 0x15, 0, 1, 0x00000004 },
{ 0x6, 0, 0, 0x00000060 },
{ 0x6, 0, 0, 0x00000000 },

Then attach it to your socket:

    struct sock_filter filter[] = {
      { 0x28, 0, 0, 0x0000000c },
      { 0x15, 0, 4, 0x00008100 },
      { 0x28, 0, 0, 0x0000000e },
      { 0x54, 0, 0, 0x00000fff },
      { 0x15, 0, 1, 0x00000004 },
      { 0x6, 0, 0, 0x00000060 },
      { 0x6, 0, 0, 0x00000000 },
    };

    struct sock_fprog inbound_filter = {
        .len = 7, .filter = filter
    };

    if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER,
        &inbound_filter, sizeof(inbound_filter)) < 0) {
        return -1;
    }

Also, note, you can easily set promiscuous mode directly with socket opts too. 
If you're more curious, just look at libpcap source.

 - Brent
