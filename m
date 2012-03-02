From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: u32 prio and hash tables
Date: Thu, 01 Mar 2012 22:17:20 -0500
Message-ID: <1330658240.4671.172.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:58444 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623Ab2CBDRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 22:17:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  Does linking to a hash table override the priority of a
filter?

I was surprised while analyzing some unexpected failures in filter
matching that my configured priorities seemed to change and be
overwritten with the priority of the linked hash table.  For example, I
have these filters:

# TCP hash table
${TC} filter ${ACTION} dev ${IIFB} parent ${IH}:0 protocol ip prio 2 handle ${IH}6: u32 divisor 1
${TC} filter ${ACTION} dev ${IIFB} parent ${IH}:0 protocol ip prio 2 u32 match ip protocol 6 0xff link ${IH}6: offset at 0 mask 0x0f00 shift 6 plus 0

${TC} filter ${ACTION} dev ${IIFB} parent ${IH}:0 protocol ip prio 6 u32 ht ${IH}6:0 match tcp dst 22 0xffff at nexthdr+2 flowid ${IH}:40

Note that the ssh filter is prio 6 but the TCP hash table is prio 2.
When I list the filters with tc -s filter show dev ifb0 parent 62:0, I
see:

filter protocol ip pref 2 u32
filter protocol ip pref 2 u32 fh 627: ht divisor 1
filter protocol ip pref 2 u32 fh 626::806 order 2054 key ht 626 bkt 0 flowid 62:40  (rule hit 0 success 0)
  match 00000016/0000ffff at nexthdr+0 (success 0 )
filter protocol ip pref 2 u32 fh 801::800 order 2048 key ht 801 bkt 0 link 626:  (rule hit 0 success 0)
  match 00060000/00ff0000 at 8 (success 0 )
    offset 0f00>>6 at 0

They are all pref 2.  The filter order in which the filters are listed
also does not appear to be the order in which they were created.  Thanks
- John
