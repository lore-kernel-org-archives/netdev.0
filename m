From: Kevin Cernekee <cernekee@gmail.com>
Subject: Re: [PATCH/RFC] netfilter: nf_conntrack_sip: Handle quirky Cisco phones
Date: Sun, 14 Nov 2010 10:33:06 -0800
Message-ID: <AANLkTik4PLga8mX73c8iONPeOtpDiuDhfu3xiPmF07jC@mail.gmail.com>
References: <28d666269c390965f1a4edca42f93c12@localhost>
	<1289725175.2743.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289725175.2743.65.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 14, 2010 at 12:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I would like to get an exact SIP exchange to make sure their is not
> another way to handle this without adding a "Cisco" string somewhere...
>
> Please provide a pcap or tcpdump -A

Existing nf_nat_sip: phone sends unauthenticated REGISTER requests
over and over again, because it is not seeing the replies sent back to
port 50070:

10:05:53.496479 IP 192.168.2.28.50070 > 67.215.241.250.5060: SIP, length: 723
E`...[..@.r.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
Via: SIP/2.0/

10:05:53.587370 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 486
E.......3..fC...............SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.2.28:5060

10:05:53.587807 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 550
E..B....3..%C...............SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 192.168.2.2

10:05:57.496541 IP 192.168.2.28.50070 > 67.215.241.250.5060: SIP, length: 723
E`...\..@.r.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
Via: SIP/2.0/

10:05:57.526716 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 486
E.......3..dC...............SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.2.28:5060

10:05:57.527162 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 550
E..B....3..#C...............SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 192.168.2.2

10:06:01.486821 IP 192.168.2.28.50070 > 67.215.241.250.5060: SIP, length: 723
E`...]..@.r.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
Via: SIP/2.0/

10:06:01.515611 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 486
E.......3..bC...............SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.2.28:5060

10:06:01.516024 IP 67.215.241.250.5060 > 192.168.2.28.50070: SIP, length: 550
E..B....3..!C...............SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 192.168.2.2

... continues forever ...


Patched nf_nat_sip: router sends the replies back to port 5060, so the
phone is now able to register itself and make calls:

10:09:46.221631 IP 192.168.2.28.50618 > 67.215.241.250.5060: SIP, length: 723
E`...G..@.p.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
Via: SIP/2.0/

10:09:46.253052 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, length: 491
E....+..4..$C...............SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.2.28:5060

10:09:46.253472 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, length: 550
E..B.,..4...C...............SIP/2.0 401 Unauthorized
Via: SIP/2.0/UDP 192.168.2.2

10:09:46.261602 IP 192.168.2.28.50618 > 67.215.241.250.5060: SIP, length: 900
E`...H..@.p.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
Via: SIP/2.0/

10:09:46.290211 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, length: 491
E....-..4.."C...............SIP/2.0 100 Trying
Via: SIP/2.0/UDP 192.168.2.28:5060

10:09:46.295041 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, length: 579
E.._....4...C............K..SIP/2.0 200 OK
Via: SIP/2.0/UDP 192.168.2.28:5060;bra


BTW, I thought of two possible issues with the original patch:

1) Might need to call skb_make_writable() prior to modifying the
packet.  Presumably the second invocation inside
nf_nat_mangle_udp_packet() will have no effect.

(Is there a cleaner way to mangle just the port number?  Most of the
utility functions only help with modifying the data area.)

2) I should probably be checking to make sure request == 0 before
mangling the packet.  The current behavior is harmless if the SIP
proxy is on port 5060, but that might not always be the case.

I can roll these, along with any other suggestions, into v2.
