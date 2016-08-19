From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 0/1] HW checksum offload problem on Xilinx Zynq GEM
Date: Fri, 19 Aug 2016 15:04:57 +0200
Message-ID: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35400 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753995AbcHSNFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:05:09 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so3371350wmg.2
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 06:05:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When working on upgrading the v3.x kernels of our embedded devices
to more recent 4.x kernels we noticed some of our proprietary networking
stuff is broken. Further investigations brought up an issue with small
UDP packets (data payload <= 2), which contained wrong UDP header
checksums.
We tracked this down to commit 85ff3d87bf2ef1fadcde8553628c60f79806fdb4
net/macb: add TX checksum offload feature. It turns out that Zynq's GEM
is obviously buggy regarding the UDP checksum calculation of such small
UDP packets as long as the UDP checksum field is != 0 *BEFORE* the
HW calulation. But since udp_send_skb() *ALWAYS* calculates the UDP header
checksum (unless disabled via socket option), this is the usual case.
Unfortunately it does not respect the net device feature setting which
would leave UDP checksum untouched when checksum offloading is enabled.

This can be easily verfied by using the following sample code on a Zynq
platform and tracing the relevant traffic on the receiving host:

/* testing Zynq's UDP checksum error
 * arm-linux-gnueabihf-gcc -Wall -o udp-chksum-test udp-chksum-test.c
 */

static void sends(int fd, const char *str, const struct sockaddr_in *addr)
{
        sendto(fd, str, strlen(str), 0, (struct sockaddr *)addr,
	       sizeof(*addr));
}

int main(int argc, char *argv[])
{
        int s;
        struct sockaddr_in addr;

        addr.sin_family = AF_INET;
        addr.sin_port = htons(9991);
        addr.sin_addr.s_addr = inet_addr("192.168.1.1");
        s = socket(AF_INET, SOCK_DGRAM, 0);

        if (s < 0) {
                perror("socket");
                exit(1);
        }

        sends(s, "1", &addr);           /* not received, CSUM error */
        sends(s, "22", &addr);          /* not received, CSUM error */
        sends(s, "333", &addr);         /* OK */
        sends(s, "4444", &addr);        /* OK */

        close(s);
        return 0;
}

Before turning off HW checksum offload feature we get 'bad udp cksum':

$ tcpdump -t -c 4 -vv -n -i eth1 port 9991 2> /dev/null | fold -w 75 -s
IP (tos 0x0, ttl 64, id 55613, offset 0, flags [DF], proto UDP (17),
length 29)
    192.168.4.2.55734 > 192.168.1.1.9991: [bad udp cksum 0xc15b ->
0x47ca!] UDP, length 1
IP (tos 0x0, ttl 64, id 55614, offset 0, flags [DF], proto UDP (17),
length 30)
    192.168.4.2.55734 > 192.168.1.1.9991: [bad udp cksum 0xc026 ->
0x4696!] UDP, length 2
IP (tos 0x0, ttl 64, id 55615, offset 0, flags [DF], proto UDP (17),
length 31)
    192.168.4.2.55734 > 192.168.1.1.9991: [udp sum ok] UDP, length 3
IP (tos 0x0, ttl 64, id 55616, offset 0, flags [DF], proto UDP (17),
length 32)
    192.168.4.2.55734 > 192.168.1.1.9991: [udp sum ok] UDP, length 4

Without HW checksum offloading everything is fine:

$ tcpdump -t -c 4 -vv -n -i eth1 port 9991 2> /dev/null | fold -w 75 -s
IP (tos 0x0, ttl 64, id 63227, offset 0, flags [DF], proto UDP (17),
length 29)
    192.168.4.2.44439 > 192.168.1.1.9991: [udp sum ok] UDP, length 1
IP (tos 0x0, ttl 64, id 63228, offset 0, flags [DF], proto UDP (17),
length 30)
    192.168.4.2.44439 > 192.168.1.1.9991: [udp sum ok] UDP, length 2
IP (tos 0x0, ttl 64, id 63229, offset 0, flags [DF], proto UDP (17),
length 31)
    192.168.4.2.44439 > 192.168.1.1.9991: [udp sum ok] UDP, length 3
IP (tos 0x0, ttl 64, id 63230, offset 0, flags [DF], proto UDP (17),
length 32)
    192.168.4.2.44439 > 192.168.1.1.9991: [udp sum ok] UDP, length 4

This issue might also affect other SoCs using Cadence MACB/GEM
implementations. Since I cannot verify this due to lack of hardware,
this solution is restricted to Xilinx Zynq7000.

Helmut Buchsbaum (1):
  net: macb: disable hardware checksum offload for Xilinx Zynq

 drivers/net/ethernet/cadence/macb.c | 6 ++++--
 drivers/net/ethernet/cadence/macb.h | 1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

-- 
2.1.4
