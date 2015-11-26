From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: Re: [PATCH iproute2] ip_tunnel: determine tunnel address family from
 the tunnel type
Date: Thu, 26 Nov 2015 18:22:05 +0200
Message-ID: <565731AD.4060009@shemyak.com>
References: <59e83fe5165e4c3698a1caa3950d72a3@HQ1WP-EXMB11.corp.brocade.com>
 <20151123162609.713e34a1@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060500020402000503040509"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:60121 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbbKZQWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 11:22:10 -0500
Received: from homiemail-a39.g.dreamhost.com (sub3.mail.dreamhost.com [69.163.253.7])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 190928CDC4
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:22:10 -0800 (PST)
In-Reply-To: <20151123162609.713e34a1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060500020402000503040509
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 24.11.2015 02:26, Stephen Hemminger wrote:
> On Thu, 12 Nov 2015 21:10:08 +0000
> Konstantin Shemyak <konstantin@shemyak.com> wrote:
>
>> When creating an IP tunnel over IPv6, the address family must be passed in
>> the option, e.g.
>>
>> ip -6 tunnel add mode ip6gre local 1::1 remote 2::2
>>
>> This makes it impossible to create both IPv4 and IPv6 tunnels in one batch.
>>
>> In fact the address family option is redundant here, as each tunnel mode is
>> relevant for only one address family.
>> The patch determines whether the applicable address family is AF_INET6
>> instead of the default AF_INET and makes the "-6" option unnecessary for
>> "ip tunnel add".
>>
>> Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>
>> ---
>>   ip/iptunnel.c                          | 26 ++++++++++++++++++++++++++
>>   testsuite/tests/ip/tunnel/add_tunnel.t | 14 ++++++++++++++
>>   2 files changed, 40 insertions(+)
>>   create mode 100755 testsuite/tests/ip/tunnel/add_tunnel.t
>>
>> diff --git a/ip/iptunnel.c b/ip/iptunnel.c
>> index 78fa988..7826a37 100644
>> --- a/ip/iptunnel.c
>> +++ b/ip/iptunnel.c
>> @@ -629,8 +629,34 @@ static int do_6rd(int argc, char **argv)
>>          return tnl_6rd_ioctl(cmd, medium, &ip6rd);
>>   }
>>
>> +static int tunnel_mode_is_ipv6(char *tunnel_mode) {
>> +       char *ipv6_modes[] = {
>> +               "ipv6/ipv6", "ip6ip6",
>> +               "vti6",
>> +               "ip/ipv6", "ipv4/ipv6", "ipip6", "ip4ip6",
>> +               "ip6gre", "gre/ipv6",
>> +               "any/ipv6", "any"
>> +       };
>> +       int i;
>> +
>> +       for (i = 0; i < sizeof(ipv6_modes) / sizeof(char *); i++) {
>> +               if (strcmp(ipv6_modes[i], tunnel_mode) == 0)
>> +                       return 1;
>> +       }
>> +       return 0;
>> +}
>> +
>
> The ipv6_modes table should be static const.

Thank you for the note! attached the corrected patch.

> Also is it possible to use strstr for ipv6 and ip6 or even strchr(tunnel_mode, '6')
> to simplify this?

There is IPv6 tunnel mode 'any', and IPv4 tunnel mode 'ipv6/ip' (aka 
'sit'). It looks to me that attempts to find some substring match
would not make the code much shorter, but definitely less readable.

Konstantin Shemyak.

--------------060500020402000503040509
Content-Type: text/x-patch;
 name="0001-Tunnel-address-family-is-determined-from-the-tunnel-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Tunnel-address-family-is-determined-from-the-tunnel-.pa";
 filename*1="tch"

>From 42d27db0055c3a114fe6eb86d680bef9ec098ad4 Mon Sep 17 00:00:00 2001
From: Konstantin Shemyak <konstantin@shemyak.com>
Date: Thu, 12 Nov 2015 20:52:02 +0200
Subject: [PATCH] Tunnel address family is determined from the tunnel mode

When the tunnel mode already tells the IP address family, "ip tunnel"
command determines it and does not require option "-4"/"-6" to be passed.

This makes possible creating both IPv4 and IPv6 tunnels in one batch.

Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>
---
 ip/iptunnel.c                          | 26 ++++++++++++++++++++++++++
 testsuite/tests/ip/tunnel/add_tunnel.t | 14 ++++++++++++++
 2 files changed, 40 insertions(+)
 create mode 100755 testsuite/tests/ip/tunnel/add_tunnel.t

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index b9552ed..096bbe4 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -570,8 +570,34 @@ static int do_6rd(int argc, char **argv)
 	return tnl_6rd_ioctl(cmd, medium, &ip6rd);
 }
 
+static int tunnel_mode_is_ipv6(char *tunnel_mode) {
+	static const char *ipv6_modes[] = {
+		"ipv6/ipv6", "ip6ip6",
+		"vti6",
+		"ip/ipv6", "ipv4/ipv6", "ipip6", "ip4ip6",
+		"ip6gre", "gre/ipv6",
+		"any/ipv6", "any"
+	};
+	int i;
+
+	for (i = 0; i < sizeof(ipv6_modes) / sizeof(ipv6_modes[0]); i++) {
+		if (strcmp(ipv6_modes[i], tunnel_mode) == 0)
+			return 1;
+	}
+	return 0;
+}
+
 int do_iptunnel(int argc, char **argv)
 {
+	int i;
+
+	for (i = 0; i < argc - 1; i++) {
+		if (strcmp(argv[i], "mode") == 0) {
+			if (tunnel_mode_is_ipv6(argv[i + 1]))
+				preferred_family = AF_INET6;
+			break;
+		}
+	}
 	switch (preferred_family) {
 	case AF_UNSPEC:
 		preferred_family = AF_INET;
diff --git a/testsuite/tests/ip/tunnel/add_tunnel.t b/testsuite/tests/ip/tunnel/add_tunnel.t
new file mode 100755
index 0000000..18f6e37
--- /dev/null
+++ b/testsuite/tests/ip/tunnel/add_tunnel.t
@@ -0,0 +1,14 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+TUNNEL_NAME="tunnel_test_ip"
+
+ts_log "[Testing add/del tunnels]"
+
+ts_ip "$0" "Add GRE tunnel over IPv4" tunnel add name $TUNNEL_NAME mode gre local 1.1.1.1 remote 2.2.2.2
+ts_ip "$0" "Del GRE tunnel over IPv4" tunnel del $TUNNEL_NAME
+
+ts_ip "$0" "Add GRE tunnel over IPv6" tunnel add name $TUNNEL_NAME mode ip6gre local dead:beef::1 remote dead:beef::2
+ts_ip "$0" "Del GRE tunnel over IPv6" tunnel del $TUNNEL_NAME
+
-- 
1.9.1


--------------060500020402000503040509--
