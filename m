From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: more info on ipsec-related invalid trusize
Date: Tue, 25 Nov 2008 07:28:57 +0300
Message-ID: <20081125042752.GA4085@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:5681 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbYKYEZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 23:25:05 -0500
Received: by ey-out-2122.google.com with SMTP id 6so954902eyi.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 20:25:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://bugzilla.kernel.org/show_bug.cgi?id=10996
http://marc.info/?l=linux-netdev&m=122641698504902&w=2

SKB BUG: Invalid truesize (344) len=134, sizeof(sk_buff)=216

This correlates with ping6 the box to death with the following IPsec
configuration and entering/leaving tcpdumping on the other end.

Numbers are always the same.

It _looks_like_ IPv4 ping is fine, but I haven't experimented much.


#!/usr/sbin/setkey -f
flush;
spdflush;

add 192.168.0.1 192.168.0.42 ah 15700 -A hmac-md5 "1234567890123456";
add 192.168.0.1 192.168.0.42 esp 15701 -E 3des-cbc "123456789012123456789012";

add 192.168.0.42 192.168.0.1 ah 24500 -A hmac-md5 "1234567890123456";
add 192.168.0.42 192.168.0.1 esp 24501 -E 3des-cbc "123456789012123456789012";

spdadd 192.168.0.42 192.168.0.1 any -P out ipsec
	esp/transport//require
	ah/transport//require;

spdadd 192.168.0.1 192.168.0.42 any -P in ipsec
	esp/transport//require
	ah/transport//require;

# ipv6
add -6 fe80::218:f3ff:fea2:9f90 fe80::21b:38ff:feaf:2249 ah 4242 -A hmac-md5 "1234567890123457";
add -6 fe80::218:f3ff:fea2:9f90 fe80::21b:38ff:feaf:2249 esp 4243 -E 3des-cbc "123456789012123456789012";

add -6 fe80::21b:38ff:feaf:2249 fe80::218:f3ff:fea2:9f90 ah 4244 -A hmac-md5 "1234567890123457";
add -6 fe80::21b:38ff:feaf:2249 fe80::218:f3ff:fea2:9f90 esp 4245 -E 3des-cbc "123456789012123456789012";

spdadd fe80::21b:38ff:feaf:2249 fe80::218:f3ff:fea2:9f90 any -P out ipsec
	esp/transport//require
	ah/transport//require;

spdadd fe80::218:f3ff:fea2:9f90 fe80::21b:38ff:feaf:2249 any -P in ipsec
	esp/transport//require
	ah/transport//require;
