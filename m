From: Michal Schmidt <mschmidt@redhat.com>
Subject: sit tunnel slow since added GSO/TSO support
Date: Fri, 13 Dec 2013 17:13:31 +0100
Message-ID: <52AB322B.7030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab3LMQNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 11:13:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've been experimenting with IPIP and SIT tunnels. Both of them
had the support for GSO/TSO added recently, by commits:
  cb32f511a7 "ipip: add GSO/TSO support"
  61c1db7fae "ipv6: sit: add GSO/TSO support"

IPIP works fine for me.

I am seeing very low TCP performance with SIT if TSO is enabled on the
SIT interface. It does not matter if the underlying hardware supports
NETIF_F_GSO_SIT or not (I have tested with bnx2x and tg3).

This is for example with TSO on a 1Gb interface:

  $ netperf -H 2001:0DB8:1234::000e
  MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2001:0DB8:1234::000e () port 0 AF_INET6
  Recv   Send    Send                          
  Socket Socket  Message  Elapsed              
  Size   Size    Size     Time     Throughput  
  bytes  bytes   bytes    secs.    10^6bits/sec  
  
   87380  16384  16384    10.00      35.92

After "ethtool -K sittun tso off":

  $ netperf -H 2001:0DB8:1234::000e
  MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2001:0DB8:1234::000e () port 0 AF_INET6
  Recv   Send    Send                          
  Socket Socket  Message  Elapsed              
  Size   Size    Size     Time     Throughput  
  bytes  bytes   bytes    secs.    10^6bits/sec  
  
   87380  16384  16384    10.01     706.86

After looking into what was happening I discovered that in the
TSO-enabled case big skbs enters into ipip6_tunnel_xmit() where they are
dropped by this branch:

        if (df) {
                /* ... */
                if (skb->len > mtu) {
                        icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
                        ip_rt_put(rt);
                        goto tx_error;
                }
        }

After having looked at the meaning of "df" I found that I can use
the "nopmtudisc" option when creating the sit tunnel to work around
the problem:
  ip tun add sittun mode sit remote $REMOTE local $LOCAL dev $IFACE nopmtudisc

With "nopmtudisc" and TSO enabled:

  $ netperf -H 2001:0DB8:1234::000e
  MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2001:0DB8:1234::000e () port 0 AF_INET6
  Recv   Send    Send                          
  Socket Socket  Message  Elapsed              
  Size   Size    Size     Time     Throughput  
  bytes  bytes   bytes    secs.    10^6bits/sec  
  
   87380  16384  16384    10.01     716.85 

Regards,
Michal
