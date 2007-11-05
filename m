From: "Ian Brown" <ianbrn@gmail.com>
Subject: A difficult question regarding problems due to neighboring subsystem state changes
Date: Mon, 5 Nov 2007 16:12:53 +0200
Message-ID: <d0383f90711050612i4a540bc0r4e7ff71561e6e227@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:58175 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365AbXKEOMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 09:12:54 -0500
Received: by py-out-1112.google.com with SMTP id u77so3051532pyb
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 06:12:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This might seem a little insane/crazy question; yet this is a real kernel
networking problem I encountered; I scratched my head a lot,
probed into the Linux kernel neighboring code, still could not
find an answer. And it still might be that the solution is a lot easier than
I can imagine in my wild dreams!

OK, this is the scenario:
I configure on machine B a second IP on eth0:1 ; this machine has a single nic.
This IP is the same as machine A has. (machines A and B are on
the same LANs). I disabled answering ARP requests
(ARPOP_REQUEST requests) on machine B with they query for that new address
(this can easily done by dropping arp request with NF_ARP_IN hook).

The reasons for using such an architecture are not so relevant here,
as this is part of a large project; but such configuration is indeed needed
in this case.

Now, I cannot ping to the original ip address of machine B from other machines
on the LAN. "ip neigh show" shows that, after adding the new IP
address on eth0:1 of machine B, that this address of machine B
is in a "FAILED" state. (this is due to a timer handler of the neighboring
system, which changes the state as a result of adding IP address to
machine B, as far as I can understand).
(I of course cannot ping the **new** IP address which I added on machine B
since ARPs are disabled on that new IP , as I said before)

Suppose, for example, that the original IP address (on eth0) of
machine B was 192.168.0.154.

The solution I found to this problem was this:
In order to enable pings (and opening sockets, etc) from other
machines to machine B ,I should add on these machines:
"ip neigh add 192.168.0.154 dev eth0 lladdr 00:0C:60:11:A8:12 nud permanent"
or:
"ip neigh change 192.168.0.154 dev eth0 lladdr 00:0C:60:11:A8:12 nud permanent"
in case there is already a (FAILED) entry for this IP in the neighbor (ARP)
table.
This solves the problem (and it could be that there are more (easier) solutions,
I am not an expert on that).

However,I cannot ping from machine A to B when I ping the original address of B!
And the "ip neigh add"/"ip neigh change" solution **can not** solve the
problem here!
The reason this cannot solve the problem here, as far as I can
understand, is this:
when I ping from machine A to B with the original IP of B, it reaches B.
B wants to send a reply to A . Alas, eth0:1 has the IP of A ! so it does not
send reply to A (and instead it gets the reply packets itself).
And of course on machines different than A this does not cause any
problems (becuase they have different IPs than eth0:1 of B, which is A
IP address)

Any ideas if I can enable pings from A to the original IP address of B in
such a case (where I ping the
original IP of B?)


Regards,
Ian
