From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.12+
Date: Sat, 29 Nov 2014 12:44:07 +0100
Message-ID: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2046400.nKnNPQkjt9"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:52958 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbaK2MK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 07:10:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart2046400.nKnNPQkjt9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

Hello,

we're in the process of updating production level machines
from kernel 3.4.101 to kernel 3.14.25. On one mail server
we noticed that emails destined for an IPSec tunnel sometimes
get stuck in the mail queue with TCP timeouts.

To make a long story short: When the VPN connection is initially
set up or re-newed, the path MTU for the xfrm tunnel is undetermined.

As soon as a TCP client starts to send large packets,
it triggers path MTU detection. Some middlebox on the
way to the final server has a lower MTU and sends back
an "ICMP fragmentation needed" packet as normal.

With the old kernel, the packet size for the TCP connection inside
the xfrm tunnel gets adjusted and all is fine. With kernel v3.12+,
the connection stalls completely. Same thing with kernel v3.18-rc6.

We wrote a small tool to mimic postfix's TCP behavior (see attached fil=
e).
In the end it's a normal TCP client sending large packets.
The server side is just "socat - tcp4-listen:667".

If you run "socket_client" a second time, the path MTU
for the xfrm tunnel is already known and packets flow normal, too.


The "evil" commit in question is this one:
---------------------------------------------------------------------
commit 8f26fb1c1ed81c33f5d87c5936f4d9d1b4118918
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 15 12:24:54 2013 -0700

    tcp: remove the sk_can_gso() check from tcp_set_skb_tso_segs()

    sk_can_gso() should only be used as a hint in tcp_sendmsg() to buil=
d GSO
    packets in the first place. (As a performance hint)

    Once we have GSO packets in write queue, we can not decide they are=
 no
    longer GSO only because flow now uses a route which doesn't handle
    TSO/GSO.

    Core networking stack handles the case very well for us, all we nee=
d
    is keeping track of packet counts in MSS terms, regardless of
    segmentation done later (in GSO or hardware)

    Right now, if  tcp_fragment() splits a GSO packet in two parts,
    @left and @right, and route changed through a non GSO device,
    both @left and @right have pcount set to 1, which is wrong,
    and leads to incorrect packet_count tracking.

    This problem was added in commit d5ac99a648 ("[TCP]: skb pcount wit=
h MTU
    discovery")

    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Neal Cardwell <ncardwell@google.com>
    Signed-off-by: Yuchung Cheng <ycheng@google.com>
    Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8fad1c1..d46f214 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -989,8 +989,7 @@ static void tcp_set_skb_tso_segs(const struct sock =
*sk, struct sk_buff *skb,
        /* Make sure we own this skb before messing gso_size/gso_segs *=
/
        WARN_ON_ONCE(skb_cloned(skb));
=20
-       if (skb->len <=3D mss_now || !sk_can_gso(sk) ||
-           skb->ip_summed =3D=3D CHECKSUM_NONE) {
+       if (skb->len <=3D mss_now || skb->ip_summed =3D=3D CHECKSUM_NON=
E) {
                /* Avoid the costly divide in the normal
                 * non-TSO case.
                 */
---------------------------------------------------------------------

When I revert it, even kernel v3.18-rc6 starts working.
But I doubt this is the root problem, may be just hiding another issue.=


--- Sample output of socket_client using vanilla v3.12 kernel ---
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1370
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1370
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1370
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1370
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1338
[1417258063 SEND result: 4096, strerror: Success]
tcp max seg: res: 0, max_seg: 1338
*STUCK*
--------------------------------------------------------

The "machine" is running on KVM and using "virtio_net" as NIC driver.
I've played with the ethtool offload settings:

*** eth1 defaults ***
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off

*** eth1 working (no stalls) using vanilla kernel ***
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: off  <-- the magic switch
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off

When I turn "tx-checksumming" back on, it fails again.
Though that is probably also just a side effect.

I can provide tcpdumps if needed but they are no real help
since you can just see the kernel stops sending TCP packets.
(and the outgoing TCP packets are encrypted in ESP packets)


Any vague idea what might be the root cause?

I also tried reverting commit 4d53eff48b5f03ce67f4f301d6acca1d2145cb7a
("xfrm: Don't queue retransmitted packets if the original is still on t=
he host")
but that didn't change the situation. In fact it wasn't even triggered.=


Please CC: comments. Thanks.

Best regards,
Thomas

--nextPart2046400.nKnNPQkjt9
Content-Disposition: attachment; filename="socket_client.c"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-csrc; charset="UTF-8"; name="socket_client.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/un.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

/*
    Remote server: socat - tcp4-listen:667
*/

int main()
{
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in servaddr;
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr=inet_addr("192.168.12.254");
    servaddr.sin_port=htons(667);

    int result = connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
    if(result != 0)
    {
        perror("failed to connect");
        exit(1);
    }

    char sendbuf[4096];
    memset(sendbuf, 0, sizeof(sendbuf));
    strcpy(sendbuf, "NOOP\n");

    int max_seg = 0, max_seg_len = sizeof(max_seg), get_res = 0;

    for (int i = 0; i < 10; ++i)
    {
        errno = 0;
        int send_res = send(sockfd, sendbuf, sizeof(sendbuf), 0);
        printf("[%d SEND result: %d, strerror: %s]\n", time(NULL), send_res, strerror(errno));

        get_res = getsockopt(sockfd, SOL_TCP, TCP_MAXSEG, &max_seg, &max_seg_len);
        printf("tcp max seg: res: %d, max_seg: %d\n", get_res, max_seg);
    }

    printf("All sent.\n");

    close(sockfd);
    exit(0);
}

--nextPart2046400.nKnNPQkjt9--
