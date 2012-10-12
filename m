From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: conntrack, NAT and icmp echo reply
Date: Fri, 12 Oct 2012 14:41:02 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210121436030.27997@blackhole.kfki.hu>
References: <e457eb3b6f3e357c3681c7af5f504161@visp.net.lb> <1349949430.21172.8435.camel@edumazet-glaptop> <10293136eb284457b47cbffd6c91d1ef@visp.net.lb> <5077A707.1030709@atc.tcs.com> <4c082d4e3afe8226cb07baeeb550712d@visp.net.lb>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vigneswaran R <vignesh@atc.tcs.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4c082d4e3afe8226cb07baeeb550712d@visp.net.lb>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2012, Denys Fedoryshchenko wrote:

> On 2012-10-12 09:13, Vigneswaran R wrote:
> > On Thursday 11 October 2012 03:32 PM, Denys Fedoryshchenko wrote:
> > > On 2012-10-11 12:57, Eric Dumazet wrote:
> > > > On Thu, 2012-10-11 at 12:41 +0300, Denys Fedoryshchenko wrote:
> > > > > 
> > > > > I have NAT box, with very simple rule
> > > > > iptables -t nat -I POSTROUTING -s 10.0.0.0/8 -j MASQUERADE
> > > > > It can be SNAT also, and it works fine, as NAT.
> > > > > 
> > > > > When i generate icmp _reply_ packet, to some host
> > > > > hping -I ppp0 -1 --icmptype 0 8.8.8.8
> > > > > 
> > > > > It will pass the box, and will exit it without NAT, e.g. with original
> > > > > IP 10.x.x.x
> > > > > on outgoing interface, which is not expected behavior IMHO.
> > > > > Is it a bug or feature?
> > > > > 
> > > > 
> > > > It depends, -s 10.0.0.0/8 wont match the rule if the source address
> > > > should be 198.23.44.55 I guess ?
> > > > 
> > > > I would try the more obvious
> > > > 
> > > > iptables -t nat -I POSTROUTING -o device -j MASQUERADE
> > > Source is correct, it is 10.0.0.0/8 range. I tested also ICMP code 3, it
> > > wont be NATed also.
> > > But ICMP echo passing OK.
> > > Also TCP RST generated same way, (i guess that don't have any match in
> > > conntrack table), won't be NATed too.
> > > hping -I ppp0 -R 8.8.8.8
> > > 13:01:07.074134 IP 10.0.0.142.2106 > 8.8.8.8.0: Flags [R], seq 510333079,
> > > win 512, length 0
> > > 13:01:08.074239 IP 10.0.0.142.2107 > 8.8.8.8.0: Flags [R], seq 1169580528,
> > > win 512, length 0
> > > 13:01:09.074253 IP 10.0.0.142.2108 > 8.8.8.8.0: Flags [R], seq 186548661,
> > > win 512, length 0
> > > 13:01:10.074376 IP 10.0.0.142.2109 > 8.8.8.8.0: Flags [R], seq 2135508128,
> > > win 512, length 0
> > > 13:01:11.074553 IP 10.0.0.142.2110 > 8.8.8.8.0: Flags [R], seq 1507433100,
> > > win 512, length 0
> > > 
> > > And ICMP here you can see correct behavior with icmp echo request:
> > > 
> > > 12:58:22.917458 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq 0,
> > > length 8
> > > 12:58:23.917543 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq
> > > 256, length 8
> > > 12:58:24.917657 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq
> > > 512, length 8
> > > 12:58:31.047475 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable,
> > > length 36
> > > 12:58:32.047562 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable,
> > > length 36
> > > 12:58:33.047734 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable,
> > > length 36
> > > 12:58:54.014601 IP X.146.153.X > 8.8.8.8: ICMP echo request, id 10462, seq
> > > 0, length 8
> > > 12:58:54.081897 IP 8.8.8.8 > X.146.153.X: ICMP echo reply, id 10462, seq
> > > 0, length 8
> > 
> > I think, the following may be the reason for the behaviour you
> > observed. (I may be wrong, I am not an expert in iptables.)
> > 
> > "nat" table only consulted for "NEW" connections. ref:
> > <http://inai.de/images/nf-packet-flow.svg>
> > 
> > The ICMP echo _reply_ may not be considered as part of a "NEW"
> > connection, as it must be a _reply_ to some already received
> > _request_. So _request_ is new and _reply_ is not.
> > 
> Yes, they are not related to existing and it is not new connection, but 
> there is similar issues related to TCP, and it is handled differently. 
> For example if nf_conntrack_tcp_loose is set to 0 - it will not pickup 
> already established connections, and just they will have INVALID state. 
> If set to 1 (and it is default value) - it will pickup the connection, 
> even it is established state. I was expecting ICMP and especially RST 
> can be consistent with that.

TCP is a connection-oriented procol while ICMP isn't. There is no point
in creating a connection entry from a bogus-looking ICMP reply packet.

The packets you generated neither belong nor related to an existing 
connection, thus are marked as INVALID. INVALID packets are not NAT-ed and 
if not dropped explicitely, will be sent out without natted.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
