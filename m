From: Vlad Maraev <maraevvb@gmail.com>
Subject: IPv4 header extension for IPv6 translation support
Date: Tue, 28 Aug 2012 11:59:12 +0400
Message-ID: <CAK617oRJypmo3025f8PZSv=Rehb3NjqyNp=bQjnRFWwaGjGXzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?0JLQu9Cw0LQg0JzQsNGA0LDQtdCy?= <maraevvb@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52128 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab2H1H7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 03:59:13 -0400
Received: by wibhr14 with SMTP id hr14so4408973wib.1
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 00:59:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I would be happy to get some feedback on my idea that is described below.
I need to tell that I'm a newbie in Linux kernel development but it
would be interesting for me to estimate complexity and to implement
this in practice.

Best Regards,
Vlad Maraev
State University of Telecommunications
St. Petersburg, Russia

-------------------------------------------------------

Why?
----------
During the process of transitioning to IPv6 segments that use
different versions of IP need to interconnect. On the ISP level it can
only be done with NATs. I mean only 6-4 or 4-6 connections, not 4-6-4
or 6-4-6 that can be achieved with tunnel or dual stack in the middle.

NATs have two major disadvantages: scalability and latency. NAT that
is connecting large network segments needs to maintain a huge
translation table. Search in such tables requires lots of CPU/memory
resources.

The protocol
----------
IPv4x (IPv4 eXtended) aims to solve this problem. I think the major
problem with IPv4 is that the IPv4 packet doesn't contain IPv6
address. If it would contain IPv6 address, the 4-6 interaction can be
provided by stateless algorithmic protocol translation without any NAT
tables.

IPv4x header inherits its structure from IPv4 with 3 additional 32-bit
fields after the Destination Address. This field will be used for
extending source or destination address to IPv6 format. IHL field is
also changed.

IPv6 address will be divided in two parts: 32 and 96 bits. First part
will be included in Source or Destination Address field (depending on
the frame direction). Remaining 96 bits will be placed after the
Destination Address.

The assignable Global Unicast Address space is defined
in as being the address block defined by the prefix 2000::/3. First
bits of this addresses are 0010 that means the network of A class in
IPv4 space that could lead to correlation with existing addresses. To
solve this first character is changed from `2` to `F`. First bits of
`F` (1111) will form IPv4 address of class E that is reserved and
could be defined for IPv6 transition. E-class

Example:
-------------------------
| 2001:0db8:cafe:3:2::2 |
-------------------------
      v
-------------
| F001:0db8 | (Destination address)
-------------
| cafe:0003 | (96 bits below)
| 0000:0000 |
| 0000:0002 |
-------------
	  v
----------------
| 240.1.13.184 | (Destination address - IPv4 format)
----------------
| cafe:0003    | (96 bits below)
| 0000:0000    |
| 0000:0002    |
----------------

Transmission of IPv4x packet
----------
IPv4 transmission of IPv4x packet can be processed using IPv4 routing.
Intermediate nodes don't need to implement IPv4x, hey will work with
IPv4x packet as a normal IPv4 packet. Border nodes must implement
IPv4x and provide algorithmic translation of IPv4x frame to IPv6.


Example:
-------------
| F001:0db8 | (Destination address)
-------------
| cafe:0003 | (96 bits below)
| 0000:0000	|
| 0000:0002 |
-------------	
	 v
-------------------------
| 64:ff9b::203.0.113.1  |  source address can be written using some prefix
-------------------------
| 2001:0db8:cafe:3:2::2 |  destination IPv6 address
-------------------------

Problems
----------
1. Intermediate nodes can look below the Destination Address for the
options if ihl>5 and will be confused with IPv4x data.
2. All the IPv4x packets would be routed to one node. But there can be
several different organization IPv6 networks connected to this node.

First steps
----------
1. IPv4x in linux kernel
2. ICMP with ping4x
3. Transmission testing. IPv4x ping request must be routed to node
with class E interface.
