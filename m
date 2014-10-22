From: "Cheng (LC) Li" <chengli@broadcom.com>
Subject: RE: Issue about dst spoofed in case of IPv6 RD (Rapid Deployment)
Date: Wed, 22 Oct 2014 03:13:54 +0000
Message-ID: <7B5C5EFFF14EC64A8E0B5568B9580BD20FE71268@IRVEXCHMB07.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:39360 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJVDNm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 23:13:42 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After moving from Linux kernel 3.8.3 to 3.14.13, I have the dst spoofed issue when testing IPv6 RD (Rapid Deployment). The console output below error message and the ping reply pack is dropped.

sit: Dst spoofed 10.149.6.128/2001:db8:ac10:1::1 -> 172.16.0.192/2001:db8:ac10:c0:d59d:4649:8244:6dfd

In my testing, I created an 6rd tunnel on the CE router:
sit1: ipv6/ip remote any local 172.16.0.192 ttl 64 6rd-prefix 2001:db8::/32 6rd-relay_prefix 10.149.6.128/32 

Correspondingly, there was a 6rd tunnel on the server 
sit1: ipv6/ip remote any local 10.149.6.128 ttl 64 6rd-prefix 2001:db8::/32 

172.16.0.192 is the IPv4 address of my CE router, 10.149.6.128 is the address of the BR. 6rd prefix is 2001:db8::/32.

After looking into the linux kernel file, linux\net\ipv6\sit.c,
I suspect the function 
static bool check_6rd(struct ip_tunnel *tunnel, const struct in6_addr *v6dst,
__be32 *v4dst)

misbehave.

It get the IPv4 destination IP by
*v4dst = tunnel->ip6rd.relay_prefix | htonl(d);

But I think it should get the IPv4 destination IP by getting it from IPv6 destination IP address per rfc5569.

Can anybody please help confirm this is a kernel issue or not?
