From: Brandon Cazander <brandon.cazander@multapplied.net>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Tue, 6 Sep 2016 16:41:16 +0000
Message-ID: <BL2PR07MB23065A58E771485F53D553E99EF90@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160729132154.GB13634@breakpoint.cc>
 <BL2PR07MB2306B2B920C441DF5406B1439E050@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160802221121.GB31209@breakpoint.cc>
 <BL2PR07MB23061A24DD64E80532DBD9799E060@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306C9A7EB393F441D56E7D69E1E0@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160812190319.GB25519@breakpoint.cc>,<BL2PR07MB23066ABAF5223701D17CFFF29E120@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Florian Westphal <fw@strlen.de>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0077.outbound.protection.outlook.com ([104.47.41.77]:6135
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932845AbcIFQ4K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 12:56:10 -0400
In-Reply-To: <BL2PR07MB23066ABAF5223701D17CFFF29E120@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry to resurrect this so much later=97I just got back from holidays and t=
his was still on my desk.

Will anyone have another chance to look at this? It appears that the DIVERT=
 rule is not working in our case, and I wonder if it is possible to fix the=
 TPROXY target as well as the socket target fix that Florian provided.

It appears as though nobody else has encountered this regression, so I can =
appreciate that it comes up pretty low on the priority list. If it is not r=
ealistic that this will be looked at further, then we will have to look at =
replacing TPROXY.

Thanks for your time.


From: Brandon Cazander
Sent: Monday, August 15, 2016 9:28 AM
To: Florian Westphal
Cc: netdev@vger.kernel.org; Eric Dumazet
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
=A0  =20
I can recreate the issue with these rules:

ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-=
port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
iptables -t nat -A PREROUTING -d 192.168.7.20/32 -i eth0 -j DNAT --to-desti=
nation 192.168.8.1

If I add in the DIVERT chain it works:

iptables -t mangle -N DIVERT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-=
port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1

But that's still a regression in my opinion.    =
