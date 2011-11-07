From: Kumar Sanghvi <divinekumar@gmail.com>
Subject: Query on usage of multicast as source IPv6 address
Date: Tue, 8 Nov 2011 02:15:52 +0530
Message-ID: <20111107204550.GB2980@kumar.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:49421 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab1KGUp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 15:45:58 -0500
Received: by qyk2 with SMTP id 2so3964913qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 12:45:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to understand IPv6 behavior in Linux.
And I have a doubt related to use of multicast address
as source address.

RFC 4291 in Section 2.7 states that:
"Multicast addresses must not be used as source addresses
 in IPv6 packets or appear in any Routing header."

However, what should be the behavior if a host receives a
packet (probably from a malicious host with pktgen abilities)
having a multicast address in source address field:
1) Should the receiving host discard the packet?
2) Should the receiving host dicard the packet, and send back
   ICMP error?
3) Or should the receiving host send a response to the multicast
   address?

I tried to search on the usage of multicast address in source
address field. However, could not find much detail (may be I am
not looking hard enough...)

So, I tried a below experiment between two linux hosts:

Host1: Running Linux 3.1,
       IP address: 2001:db8:0:f101::2/64,
       and netserver listening on port 12865.

Host2: Running Linux 2.6.32,
       IP address: 2001:db8:0:f101::1/64,
       and with pktgen abilities.

Host1 and Host2 are back-to-back connected.

Now, from Host2, I send a TCP packet with a multicast address
(ff02::1) in source IP address field.
>From the tcpdump running on Host2, I see below:
----
tcpdump ip6 -i eth6 -vv
tcpdump: WARNING: eth6: no IPv4 address assigned
tcpdump: listening on eth6, link-type EN10MB (Ethernet), capture size 65535 bytes
01:16:11.297469 IP6 (hlim 37, next-header TCP (6) payload length: 20) ff02::1.43373 > 2001:db8:0:f101::2.12865: Flags [S], cksum 0x0d91 (correct), seq 768433557, win 5760, length 0
01:16:11.297627 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
01:16:12.299063 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
01:16:14.298824 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
01:16:16.297476 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 32) fe80::7:4300:210:a410 > 2001:db8:0:f101::2: [icmp6 sum ok] ICMP6, neighbor solicitation, length 32, who has 2001:db8:0:f101::2
	  source link-address option (1), length 8 (1): 00:07:43:10:a4:10
	    0x0000:  0007 4310 a410
01:16:16.297591 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 24) 2001:db8:0:f101::2 > fe80::7:4300:210:a410: [icmp6 sum ok] ICMP6, neighbor advertisement, length 24, tgt is 2001:db8:0:f101::2, Flags [solicited]
01:16:18.498340 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
01:16:21.309998 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 32) fe80::7:4300:210:8450 > fe80::7:4300:210:a410: [icmp6 sum ok] ICMP6, neighbor solicitation, length 32, who has fe80::7:4300:210:a410
	  source link-address option (1), length 8 (1): 00:07:43:10:84:50
	    0x0000:  0007 4310 8450
01:16:21.310040 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 24) fe80::7:4300:210:a410 > fe80::7:4300:210:8450: [icmp6 sum ok] ICMP6, neighbor advertisement, length 24, tgt is fe80::7:4300:210:a410, Flags [solicited]
01:16:26.309429 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 32) fe80::7:4300:210:a410 > fe80::7:4300:210:8450: [icmp6 sum ok] ICMP6, neighbor solicitation, length 32, who has fe80::7:4300:210:8450
	  source link-address option (1), length 8 (1): 00:07:43:10:a4:10
	    0x0000:  0007 4310 a410
01:16:26.309482 IP6 (hlim 255, next-header ICMPv6 (58) payload length: 24) fe80::7:4300:210:8450 > fe80::7:4300:210:a410: [icmp6 sum ok] ICMP6, neighbor advertisement, length 24, tgt is fe80::7:4300:210:8450, Flags [solicited]
01:16:26.497391 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
01:16:42.495518 IP6 (hlim 64, next-header TCP (6) payload length: 24) 2001:db8:0:f101::2.12865 > ff02::1.43373: Flags [S.], cksum 0x4614 (correct), seq 4202338952, ack 768433558, win 14400, options [mss 1440], length 0
^C
13 packets captured
13 packets received by filter
0 packets dropped by kernel
----

So, it seems that Linux responds to packets having source IP
field as multicast address, and sends response to that multicast
address. Or am I interpreting it wrongly ?

I would like to understand if this is a valid behavior to send
response to multicast address? Will it not lead to some kind of
amplification attack, if the malicious user from Host2 sends a
flood of TCP packets, with multicast as source IP, towards Host1,
and if there are several hosts present in that same LAN segment?

Or, is it completely valid to send a response to multicast address?
May be, my understanding is not clear then.


Any help in this regards is appreciated.


Thanks,
Kumar.
