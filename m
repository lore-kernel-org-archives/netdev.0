From: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Subject: tcp/udp checksum on loopback interface
Date: Fri, 22 Jul 2011 10:01:21 +0200
Message-ID: <4E292E51.4040802@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:27248
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752321Ab1GVILH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 04:11:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody

I am interested in the reliability of TCP and UDP using the loopback 
interface.
I found that there is no checksum verification on the body of packets 
transmitted through the loopback interface : 
http://kerneltrap.org/mailarchive/linux-netdev/2007/10/2/327241
I ran a simple test using iperf and wireshark and I indeed found the 
validation of the checksum is disabled at packets reception.

At the reception, I guess the piece of code responsible for this 
behaviour is (line 1196 of net/ipv4/udp.c, in udp_recvmsg() for UDP) :
if (skb_csum_unnecessary(skb))
     err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), 
msg->msg_iov, len);
Is this the responsible piece of code? If yes, where does the 
CHECKSUM_UNNECESSARY flag is set?

However, I am not sure whether the checksum is computed on the whole 
packet at emission.
In __ip_append_data (net/ipv4/ip_output.c), I found the flag csummode is 
at the beginning at CHECKSUM_NONE.
Then, it is augmented using the dev->features flag of the network device 
(e.g. the loopback interface).
As the loopback interface has the NETIF_F_NO_CSUM flag, csummode stays 
at CHECKSUM_NONE and the checksum is not computed on the body of the 
message.
Can you confirm the checksum is computed only on the header of the 
packet when sending it through the loopback interface?

Finally, why this behaviour? Is it because you assume message can not 
get corrupted while staying on the same machine?

Thank you in advance
Pierre Louis Aublin
