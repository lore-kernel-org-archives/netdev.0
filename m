From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/3] TCP connection repair (v3)
Date: Wed, 28 Mar 2012 19:36:01 +0400
Message-ID: <4F732FE1.9040906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47244 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756518Ab2C1PgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 11:36:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Attempt #3 with transparent TCP connection hijacking
(previous one is here http://lists.openwall.net/netdev/2012/03/06/65).


Changes since v2:

* The CAP_NET_ADMIN is required to turn repair on, not CAP_SYS_ADMIN

* Changed read queue seq sockoption to work on the rcv_nxt, not the
  copied_seq to address the issue with syn flag in the fake header
  (see below).

* Resolved issues with syn and fin flags in fake headers.

  Fin can and should be dropped. The repair mode is currently allowed
  only for closed and established sockets and thus we cannot meet an 
  skb with this flag in the original socket (queuing fin to receive
  queue switches the established state to the close-wait one).

  Syn can also be dropped. This flag in the recv queue's skb means the
  respective skb's seq is off-by-one relative to the actual amount of 
  data on it. Thus, removing the flag from fake skb and fixing the seq 
  respectively solves the issue.

  However, in order to do so it's not enough to know the copied_seq and
  recv queue length only (rcv_nxt should be copied_seq plus data length
  plus "syn-is-there"). Thus, the rcv queue seq get/set sockoption is
  changed to work on the rcv_nxt itself. IOW I emulate the situation
  when the packet with data and syn is splitted into two -- a packet with
  syn and a packet with data and the former one is already "eaten".


Thanks,
Pavel
