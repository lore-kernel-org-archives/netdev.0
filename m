From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: ipset: hash:*net* doesnt match after entry removal (both inet, inet6 families)
Date: Thu, 20 Jun 2013 15:09:53 +0300
Message-ID: <2813882.HseEuK1kWK@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:36298 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab3FTMQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 08:16:04 -0400
Received: from smtp44.i.mail.ru (smtp44.i.mail.ru [94.100.177.104])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 3D572E8C2E30
	for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 16:12:02 +0400 (MSK)
Received: from [195.234.68.4] (port=45165 helo=tuxracer.localnet)
	by smtp44.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1UpdiA-0003On-Qp
	for netdev@vger.kernel.org; Thu, 20 Jun 2013 16:11:35 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Deploying ip6?tables filtering rules on one of our server we spot following 
issue using Linux kernel 3.9.6 and ipset 6.19 as userlang and hash:*set* set 
type:

  Deleting previously added network prefix longer than any prefix, that already
  in set, causes future lookups on remaining prefixes not to match (both using 
  ipset(8) test command and ip6?tables(8) "set" match, on any hash:*net* set 
  type).

Tested on the following configurations:
  1. v3.9.6, ipset 6.19 (also 6.12.1)  : reproduced
  2. v3.8.13(EOL), ipset 6.12.1         : reproduced
  3. v3.2.46, ipset 6.12.1                  : not reproducable

Both IPv4 and IPv6 are affected.

Steps to reproduce (using ipset(8) test command for simplicity):
--------------------------------------------------------------------------------
#!/bin/bash -v

##  Create ipset for inet AFI
ipset create set-v4 hash:net family inet

## Add 192.168.1.0/24 prefix to set and check
ipset add set-v4 192.168.1.0/24
ipset test set-v4 192.168.1.0
192.168.1.0 is in set set-v4.
ipset test set-v4 192.168.1.255
192.168.1.255 is in set set-v4.

## Add 172.16.1.0/25 prefix to set and check
ipset add set-v4 172.16.1.0/25
ipset test set-v4 192.168.1.0
192.168.1.0 is in set set-v4.
ipset test set-v4 192.168.1.255
192.168.1.255 is in set set-v4.
ipset test set-v4 172.16.1.0
172.16.1.0 is in set set-v4.
ipset test set-v4 172.16.1.127
172.16.1.127 is in set set-v4.

## List set-v4 contents
ipset list set-v4
Name: set-v4
Type: hash:net
Header: family inet hashsize 1024 maxelem 65536 
Size in memory: 16824
References: 0
Members:
172.16.1.0/25
192.168.1.0/24

## Delete longer (more specific) prefix from the set
ipset del set-v4 172.16.1.0/25

## And test again remaining prefixes
ipset test set-v4 192.168.1.0
192.168.1.0 is NOT in set set-v4.
ipset test set-v4 192.168.1.255
192.168.1.255 is NOT in set set-v4.

## List set-v4 contents
ipset list set-v4
Name: set-v4
Type: hash:net
Header: family inet hashsize 1024 maxelem 65536 
Size in memory: 16824
References: 0
Members:
192.168.1.0/24

## Destroy set-v4
ipset destroy set-v4

-- 
SP5474-RIPE
Sergey Popovich
