From: Andrew Lunn <andrew@lunn.ch>
Subject: TPACKET_V3 timeout bug?
Date: Sat, 15 Apr 2017 21:40:42 +0200
Message-ID: <20170415194042.GA5936@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59413 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754504AbdDOTko (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 15:40:44 -0400
Received: from andrew by vps0.lunn.ch with local (Exim 4.80)
        (envelope-from <andrew@lunn.ch>)
        id 1czTYo-0001qD-H3
        for netdev@vger.kernel.org; Sat, 15 Apr 2017 21:40:42 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks

I'm running this simple program using libpcap:

#include <stdio.h>
#include <stdint.h>
#include <pcap/pcap.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
        struct pcap_pkthdr *hdr;
        const uint8_t *data;
        pcap_t *handle;
        int ret;


        handle = pcap_open_live("lan3", 65535, 1, 1000, NULL);
        if (handle == NULL)
                exit(EXIT_FAILURE);

        while (1) {
                ret = pcap_next_ex(handle, &hdr, &data);
                printf("ret: %d\n", ret);
        }
}

The man page says:

       pcap_t *pcap_open_live(const char *device, int snaplen,
               int promisc, int to_ms, char *errbuf);

DESCRIPTION

       pcap_open_live() is used to obtain a packet capture handle to
       look at packets on the network.  device is a string that
       specifies the network device to open; on Linux systems with 2.2
       or later kernels, a device argument of "any" or NULL can be
       used to capture packets from all interfaces.

       snaplen specifies the snapshot length to be set on the handle.

       promisc specifies if the interface is to be put into promiscuous mode.

       to_ms specifies the read timeout in milliseconds.

so i'm passing to_ms for 1000ms.

and the man page for pcap_next_ex() says:

RETURN VALUE

       pcap_next_ex() returns 1 if the packet was read without
       problems, 0 if packets are being read from a live capture and
       the timeout expired

In my case, lan3 is up and idle, there are no packets flying around to
be captured. So i would expect pcap_next_ex() to exit once a second,
with a return value of 0. But it is not, it blocks and stays blocked.

strace shows:

socket(AF_PACKET, SOCK_RAW, 768)        = 3
ioctl(3, SIOCGIFINDEX, {ifr_name="lo", }) = 0
ioctl(3, SIOCGIFHWADDR, {ifr_name="lan3", ifr_hwaddr=94:10:3e:80:bc:f3}) = 0
stat64("/sys/class/net/lan3/wireless", 0xbe9443a0) = -1 ENOENT (No such file or directory)
ioctl(3, SIOCBONDINFOQUERY, 0xbe944304) = -1 EOPNOTSUPP (Operation not supported)
ioctl(3, SIOCGIWNAME, 0xbe944354)       = -1 EINVAL (Invalid argument)
ioctl(3, SIOCGIFINDEX, {ifr_name="lan3", }) = 0
bind(3, {sa_family=AF_PACKET, sll_protocol=htons(ETH_P_ALL), sll_ifindex=if_nametoindex("lan3"), sll_hatype=ARPHRD_NETROM, sll_pkttype=PACKET_HOST, sll_halen=0}, 20) = 0
getsockopt(3, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
setsockopt(3, SOL_PACKET, PACKET_ADD_MEMBERSHIP, {mr_ifindex=5, mr_type=PACKET_MR_PROMISC, mr_alen=0, mr_address=}, 16) = 0
setsockopt(3, SOL_PACKET, PACKET_AUXDATA, [1], 4) = 0
getsockopt(3, SOL_SOCKET, SO_BPF_EXTENSIONS, [64], [4]) = 0
getsockopt(3, SOL_PACKET, PACKET_HDRLEN, [48], [4]) = 0
setsockopt(3, SOL_PACKET, PACKET_VERSION, [2], 4) = 0
setsockopt(3, SOL_PACKET, PACKET_RESERVE, [4], 4) = 0
setsockopt(3, SOL_PACKET, PACKET_RX_RING, 0xbe9445c0, 28) = 0
mmap2(NULL, 2097152, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0xb6c93000
uname({sysname="Linux", nodename="wrt1900ac", ...}) = 0
poll([{fd=3, events=POLLIN}], 1, -1

Looking at the libpcap source, the 1000ms timeout is being used as
part of the setsockopt(3, SOL_PACKET, PACKET_RX_RING, 0xbe9445c0, 28)
call, req.tp_retire_blk_tov is set to the timeoutval.

And libpcap, when determining the timeout value to pass to poll has
the comment:

	 * For TPACKET_V3, the timeout is handled by the kernel,
	 * so block forever; that way, we don't get extra timeouts.

So it is expecting poll() to exit from a blocking call when
req.tp_retire_blk_tov expires.

So i think there is a bug, or a wrong understanding of the kernel API.
Any suggestions which?

Thanks
	Andrew
