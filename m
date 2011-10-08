From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: raw ethenet socket question
Date: Sat, 8 Oct 2011 22:20:32 +0200
Message-ID: <CAMJ=MEfkY4M6M=yfzXcGt1qPnDJ_3ESmb0rfYpTmENOxQUE7-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41071 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab1JHUUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 16:20:33 -0400
Received: by gyg10 with SMTP id 10so4465381gyg.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 13:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello

I'm doing some tests on a raw Ethernet socket and I observe some
strange behavior.

My system is a FreeScale P4040, running  Linux 2.6.36.4 compiled for
SMP mode but only 1 core activated.
[    0.000000] Using P4080 DS machine description
[    0.000000] Memory CAM mapping: 256/256/256 Mb, residual: 1248Mb
[    0.000000] Linux version 2.6.36.4 (meeusr@devws108) (gcc version
4.4.6 (Buildroot 2011.08-hgc574811c3fc5) ) #1 SMP Sat Oct 8 20:40:40
CEST 2011

I basically have one of the Ethernet ports in a loopmode, which means
that all packets sent to the port will be received on the same port.
I want to check the amount of packets I can send/receive on my board,
so there a large loop to send/receive packets (see code below).
To stress the system a bit more, I send a number of packets before I
start to receive packets.

If I send 10 or less packets at a time, I do not see issues (see for
(j=0;j<10;j++)), but if I send for example 16 packets before starting
to receive, I always see packet loss.
For example if I send 1000 times 16 packets, I only receive 12000
packets, if I send 1000 times 20 packets, I receive 16000 packets.

I also checked the ifconfig statistics and the counters for Rx and Tx
are always identical and equal to the amount of packets that were
sent. So it looks like the packets are getting lost in the linux
kernel of in my test application.

Can somebody explain this behavior?
Is there a fixed amount of Ethernet packets that are queue in a socket?

Test code:

  for (i=0;i<packets_to_send;i++)
  {
    fd_set readset;
    struct timeval tv;

    FD_ZERO(&readset);
    FD_SET(eth_sock,&readset);

    for (j=0;j<10;j++)
    {
      if (sendto(eth_sock,packet,packet_size, 0,(struct
sockaddr*)eth_dest, sizeof(struct sockaddr_ll)) > 0)
        packet_count++;
    }

    tv.tv_sec = 0;
    tv.tv_usec = 500;
    while (select(eth_sock+1,&readset,0,0,&tv) == 1) {
        int len = recvfrom(eth_sock,recvdata,sizeof(recvdata),0,NULL,NULL);
        if (len>0) rcv_count++;
        tv.tv_usec = 500;
    }
    printf("packet sent: %10ld  packets received:
%10ld\r",packet_count,rcv_count);
  }

This is how I create my socket:

int create_raw_eth_socket(void)
{
  int eth_sock;
  eth_dest.sll_family   = PF_PACKET;
  eth_dest.sll_protocol = htons(ETH_P_ALL);
  eth_dest.sll_ifindex  = itf_ifindex;
  eth_dest.sll_hatype   = ARPHRD_ETHER;
  eth_dest.sll_pkttype  = PACKET_OTHERHOST;
  eth_dest.sll_halen    = ETH_ALEN;
  eth_sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
  bind(eth_sock,(struct sockaddr*)&eth_dest,sizeof(eth_dest));
  return eth_sock;
}


Regards,
Ronny
