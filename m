From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: allow setting congctl via routing table
Date: Fri, 5 Dec 2014 08:35:51 -0800
Message-ID: <CAA93jw46b5hCFPAwziyTRpTAzLdXeb4nrTEZXiEqxYWhRi49CA@mail.gmail.com>
References: <1417793092-6263-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:58133 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbaLEQfv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 11:35:51 -0500
Received: by mail-oi0-f46.google.com with SMTP id h136so680862oig.5
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 08:35:51 -0800 (PST)
In-Reply-To: <1417793092-6263-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 7:24 AM, Daniel Borkmann <dborkman@redhat.com> w=
rote:
> This is the second part of our work and allows for setting the conges=
tion
> control algorithm via routing table. For details, please see individu=
al
> patches.
>
> Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.
>
> Thanks!
>
> Daniel Borkmann (4):
>   net: tcp: refactor reinitialization of congestion control
>   net: tcp: add key management to congestion control
>   net: tcp: add RTAX_CC_ALGO fib handling
>   net: tcp: add per route congestion control


Very interesting. Have you tried something other than dctcp here
(e.g. westwood or lp?)

Have you considered the case where the route changes underneath
you from one device to another?

Example, here I am routing everything through eth0, where I
would want cubic, probably...

root@ganesha:~/git/tinc# ip route
default via 172.26.16.1 dev eth0  proto babel onlink
69.181.216.0/22 via 172.26.16.1 dev eth0  proto babel onlink
169.254.0.0/16 dev eth0  scope link  metric 1000
172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
172.26.16.1 via 172.26.16.1 dev eth0  proto babel onlink
172.26.16.112 via 172.26.16.112 dev eth0  proto babel onlink
172.26.17.0/24 via 172.26.16.1 dev eth0  proto babel onlink
172.26.17.3 via 172.26.16.1 dev eth0  proto babel onlink
172.26.17.227 via 172.26.16.1 dev eth0  proto babel onlink
192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  met=
ric 1
192.168.7.2 via 172.26.16.112 dev eth0  proto babel onlink

And I pull the plug, and everything flips over to wlan0,
where I might want westwood (or something saner than
that. It might be nice to have a per-device cc default
algorithm...)

root@ganesha:~/git/tinc# ip route
default via 172.26.17.224 dev wlan0  proto babel onlink
69.181.216.0/22 via 172.26.17.224 dev wlan0  proto babel onlink
169.254.0.0/16 dev eth0  scope link  metric 1000
172.26.16.0/24 dev eth0  proto kernel  scope link  src 172.26.16.177
172.26.16.1 via 172.26.17.227 dev wlan0  proto babel onlink
172.26.16.112 via 172.26.17.227 dev wlan0  proto babel onlink
172.26.17.0/24 via 172.26.17.224 dev wlan0  proto babel onlink
172.26.17.3 via 172.26.17.227 dev wlan0  proto babel onlink
172.26.17.227 via 172.26.17.227 dev wlan0  proto babel onlink
192.168.7.0/30 dev eth1  proto kernel  scope link  src 192.168.7.1  met=
ric 1
192.168.7.2 via 172.26.17.227 dev wlan0  proto babel onlink



--=20
Dave T=C3=A4ht
the quest for a fq-friendly vpn with no head of line blocking continues=
!
https://plus.google.com/u/0/107942175615993706558/posts/QWPWLoGMtrm
