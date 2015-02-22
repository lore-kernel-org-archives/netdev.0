From: Alexander Clouter <alex@digriz.org.uk>
Subject: forwarding IPv6 LL packets, bug?
Date: Sun, 22 Feb 2015 16:43:41 +0000
Message-ID: <20150222164341.GD28830@stevemcqueen.digriz.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yr/DzoowOgTDcSCF"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from marmot.wormnet.eu ([188.246.204.87]:47672 "EHLO
	marmot.wormnet.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbBVRMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 12:12:38 -0500
Received: from [2a01:348:45:10:e093:4bc6:6a2a:a7a4] (helo=localhost)
	by marmot.wormnet.eu with esmtpsa (TLSv1.2:DHE-RSA-AES128-SHA:128)
	(Exim 4.84)
	(envelope-from <alex@digriz.org.uk>)
	id 1YPZd8-00026N-Nl
	for netdev@vger.kernel.org; Sun, 22 Feb 2015 16:43:43 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--yr/DzoowOgTDcSCF
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

Hi,

Stumbled on an oddity where Linux seems to be decrementing the hop limit and 
forwarding link-local packets, so hoping someone can point me where I have 
messed up, or hi-five me if I have stumbled on a bug? :)

I have a firewall policy that drops neighbour solicitation packets where the 
hop limit is not set to 255, and I seem to be getting hits.  The odd part is 
that it is my router (running 3.18.6) that is generating and trying to 
forwarding them.

This is what I see, note the IN=OUT=br0 and HOPLIMIT=254 for IPv6 NS:
----
[   38.850000] unknown icmp: IN=br0 OUT=br0 MAC=00:13:10:2e:ba:63:54:26:96:cf:6f:f3:86:dd SRC=fe80:0000:0000:0000:5626:96ff:fecf:6ff3 DST=fe80:0000:0000:0000:7099:22ff:fe85:2fd2 LEN=72 TC=0 HOPLIMIT=254 FLOWLBL=0 PROTO=ICMPv6 TYPE=135 CODE=0
----

Here 00:13:10:2e:ba:63 is the MAC address of the sender, and 54:26:96:cf:6f:f3 
is the router MAC address.  Meanwhile fe80::5626:96ff:fecf:6ff3 is the client 
LL address, but fe80::7099:22ff:fe85:2fd2 is *not* the routers LL address.

If this was not link-local addresses then Linux would be doing exactly as I 
expected, however, I do not believe it should be forwarding as this is an IPv6 
LL destination?

I simplified my firewall so the forward chain just had just:
----
iif br0 oif br0 limit rate 10/minute log prefix "wtf: "
----

Then with scapy I ran:
----
a = Ether(src="54:26:96:cf:6f:f3", dst="00:13:10:2e:ba:63")/IPv6(src="fe80::5626:96ff:fecf:6ff3", dst="fe80::7099:22ff:fe85:2fd2")/ICMPv6EchoRequest()
sendp(a)
----

>From the scapy client I ran tcpdump and saw the following (including the 
delayed destination unreachable packet):
----
# tcpdump -i wlan0 -n -v -e not tcp and not udp and not arp
16:15:16.603025 54:26:96:cf:6f:f3 > 00:13:10:2e:ba:63, ethertype IPv6 (0x86dd), length 62: (hlim 64, next-header ICMPv6 (58) payload length: 8) fe80::5626:96ff:fecf:6ff3 > fe80::7099:22ff:fe85:2fd2: [icmp6 sum ok] ICMP6, echo request, seq 0
16:15:16.604776 00:13:10:2e:ba:63 > 54:26:96:cf:6f:f3, ethertype IPv6 (0x86dd), length 150: (hlim 255, next-header ICMPv6 (58) payload length: 96) fe80::74d6:3eff:fef2:3815 > fe80::5626:96ff:fecf:6ff3: [icmp6 sum ok] ICMP6, redirect, length 96, fe80::7099:22ff:fe85:2fd2 to fe80::7099:22ff:fe85:2fd2
           redirected header option (4), length 56 (7):
             0x0000:  0407 0000 0000 0000 6000 0000 0008 3a40
             0x0010:  fe80 0000 0000 0000 5626 96ff fecf 6ff3
             0x0020:  fe80 0000 0000 0000 7099 22ff fe85 2fd2
             0x0030:  8000 64e1 0000 0000
16:15:19.600122 00:13:10:2e:ba:63 > 54:26:96:cf:6f:f3, ethertype IPv6 (0x86dd), length 110: (hlim 64, next-header ICMPv6 (58) payload length: 56) fe80::74d6:3eff:fef2:3815 > fe80::5626:96ff:fecf:6ff3: [icmp6 sum ok] ICMP6, destination unreachable, unreachable address fe80::7099:22ff:fe85:2fd2
----

Meanwhile the firewall popped up with, again with the hop limit decremented:
----
[ 6797.960000] wtf: IN=br0 OUT=br0 MAC=00:13:10:2e:ba:63:54:26:96:cf:6f:f3:86:dd SRC=fe80:0000:0000:0000:5626:96ff:fecf:6ff3 DST=fe80:0000:0000:0000:7099:22ff:fe85:2fd2 LEN=48 TC=0 HOPLIMIT=63 FLOWLBL=0 PROTO=ICMPv6 TYPE=128 CODE=0 ID=0 SEQ=0
----

So I cracked out the source code and found where I think the problem might be, 
net/ipv6/ip6_output.c:ip6_forward().  I think the else block tied to the if 
clause handling redirect generation should be move above the block alternative 
and made non-conditional?  Something like the attachment?

Regards

-- 
Alexander Clouter
.sigmonster says:             BOFH excuse #352:
			       The cables are not the same length.

--yr/DzoowOgTDcSCF
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="forwarding-ll-traffic-fix.patch"

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7deebf1..ed45930 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -437,6 +437,18 @@ int ip6_forward(struct sk_buff *skb)
 	}
 	dst = skb_dst(skb);
 
+	int addrtype = ipv6_addr_type(&hdr->saddr);
+
+	/* This check is security critical. */
+	if (addrtype == IPV6_ADDR_ANY ||
+	    addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
+		goto error;
+	if (addrtype & IPV6_ADDR_LINKLOCAL) {
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH,
+			    ICMPV6_NOT_NEIGHBOUR, 0);
+		goto error;
+	}
+
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
 	   We don't send redirects to frames decapsulated from IPsec.
@@ -466,18 +478,6 @@ int ip6_forward(struct sk_buff *skb)
 			ndisc_send_redirect(skb, target);
 		if (peer)
 			inet_putpeer(peer);
-	} else {
-		int addrtype = ipv6_addr_type(&hdr->saddr);
-
-		/* This check is security critical. */
-		if (addrtype == IPV6_ADDR_ANY ||
-		    addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
-			goto error;
-		if (addrtype & IPV6_ADDR_LINKLOCAL) {
-			icmpv6_send(skb, ICMPV6_DEST_UNREACH,
-				    ICMPV6_NOT_NEIGHBOUR, 0);
-			goto error;
-		}
 	}
 
 	mtu = ip6_dst_mtu_forward(dst);

--yr/DzoowOgTDcSCF--
