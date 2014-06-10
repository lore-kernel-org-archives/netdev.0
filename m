From: Per Jessen <per@computer.org>
Subject: Re: missing icmp redirects
Date: Tue, 10 Jun 2014 20:10:23 +0200
Message-ID: <53974A0F.7080908@computer.org>
References: <5343FE4D.40805@computer.org> <DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.spamchek.net ([88.198.172.124]:38295 "EHLO
	outbound.spamchek.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaFJS1P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 14:27:15 -0400
In-Reply-To: <DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lukas Tribus wrote:
>> See complete description here:
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D72561
>>
>> Summary - some ICMP redirects seem to be missing.
>>
>> Alan suggests I gather some traces, but I'm am unsure of what to tra=
ce.
>> Suggestions please?
>=20
> Reproduce the actual issue and post a simplified testcase, without
> transparent proxying, etc.

Okay, I have devised a way to reproduce the problem:

I have a test setup of three machines:

=93client=94, =93firewall=94 and =93server=94. All on the same network.

Client:
Set up default route via =93firewall=94.

Server:
Assign 10.232.1.1-2-3-4-...-15/24 to an interface.
Run a tcp echo service (port 7).

=46irewall:
Create routing table =93test99=94.  /etc/iproute2/rt_tables.
ip route add default via <server> dev eth0 table test99
ip rule add fwmark 5 table test99
iptables -A PREROUTING -t mangle -i eth0 -p tcp --dport 7 -j MARK --set=
-mark 5

(this setup is what will produce the ICMP redirects).

On =93firewall=94, run tcpdump to document (missing) redirects:
tcpdump -n -i eth0 proto \\icmp

On =93client=94, create some test input:

cat <<XXX >test.input
klop
alpha
nothing
tagi
line1
line2
line3
line4
XXX

Create a script
cat <<XXX >doit
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
do
     telnet 10.232.1.$i 7 <test.input &
done

When you run =93sh doit=94, all of the telnet requests to 10.232.1.x sh=
ould be=20
redirected, but the tcpdump running on "firewall" will only show some o=
f them.
