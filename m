From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: 27 Feb 2008 22:08:06 +0100
Message-ID: <ygfhcfu85vt.fsf@janus.isnogud.escape.de>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
	<20080226.225104.175000479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:49214 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbYB0VKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 16:10:10 -0500
In-Reply-To: <20080226.225104.175000479.davem@davemloft.net>; from David Miller on Tue, 26 Feb 2008 22:51:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> When given a specific device, libpcap uses SOCK_RAW.

I don't think this is completely true for PPP interfaces.  If you do a
pcap_open_live() on interface "any", libpcap opens a PF_PACKET/SOCK_DGRAM
socket.  Otherwise, on a specific device a SOCK_RAW is opened like you
write but libpcap asks with SIOCGIFHWADDR for the ARPHRD_* type of the
interface.  In case of PPP libpcap closes the socket and opens a new
socket with SOCK_DGRAM to capture packets on.  Here's a strace showing
this behavior:

    execve("./pcap", ["./pcap", "ppp0"], [/* 34 vars */]) = 0
    brk(0)                                  = 0x8068f5c
    ...
    socket(PF_PACKET, SOCK_RAW, 768)        = 3
    ioctl(3, SIOCGIFINDEX, {ifr_name="lo", ifr_index=1}) = 0
    ioctl(3, SIOCGIFHWADDR, {ifr_name="ppp0", ifr_hwaddr=00:00:00:00:00:00}) = 0
    close(3)                                = 0
    socket(PF_PACKET, SOCK_DGRAM, 768)      = 3
    ioctl(3, SIOCGIFINDEX, {ifr_name="ppp0", ifr_index=22}) = 0
    bind(3, {sa_family=AF_PACKET, proto=0x03, if22, pkttype=PACKET_HOST, addr(0)={0, }, 20) = 0
    ...

> I spent some time seriously considering this change but I
> can't because it really can potentially break so much stuff.

Thanks for your time on this.  But AFAICS, the patch doesn't break
libpcap.  I have it running here on 2.4 and 2.6 kernels for some weeks
now with PPPoE.  tcpdump and wireshark run without problems since they
use libpcap and for SOCK_DGRAM there is no difference.

My own simple packet sniffer is not libpcap based and takes advantage of
the patch.  Other programs using PF_PACKET I run here are dhcpd,
dhclient, rarpd, pppoe-server, and pppoe, but all of these use
SOCK_DGRAM or SOCK_PACKET and/or work on Ethernet interfaces.

I don't think the patch would break much stuff.

urs
