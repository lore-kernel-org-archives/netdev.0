From: Brandon Cazander <brandon.cazander@multapplied.net>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Mon, 15 Aug 2016 16:28:22 +0000
Message-ID: <BL2PR07MB23066ABAF5223701D17CFFF29E120@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160729132154.GB13634@breakpoint.cc>
 <BL2PR07MB2306B2B920C441DF5406B1439E050@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160802221121.GB31209@breakpoint.cc>
 <BL2PR07MB23061A24DD64E80532DBD9799E060@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306C9A7EB393F441D56E7D69E1E0@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160812190319.GB25519@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0051.outbound.protection.outlook.com ([104.47.33.51]:63975
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752881AbcHOQnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2016 12:43:32 -0400
In-Reply-To: <20160812190319.GB25519@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can recreate the issue with these rules:

ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
iptables -t nat -A PREROUTING -d 192.168.7.20/32 -i eth0 -j DNAT --to-destination 192.168.8.1

If I add in the DIVERT chain it works:

iptables -t mangle -N DIVERT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1

But that's still a regression in my opinion.
