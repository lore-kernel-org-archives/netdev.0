From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 0/4] ipv6: datagram: Update dst cache of a connected udp sk during pmtu update
Date: Mon, 11 Apr 2016 15:29:33 -0700
Message-ID: <1460413777-177662-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:62975 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbcDKW3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:29:50 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3BMTMTH031440
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 226wda2mmj-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:29:49 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 e63a7f70003411e692140002c9dfb610-147fc3f0 for <netdev@vger.kernel.org>;	Mon,
 11 Apr 2016 15:29:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
~ Protect __sk_dst_get() operations with rcu_read_lock in
  release_cb() because another thread may do ip6_dst_store()
  for a udp sk without taking the sk lock (e.g. in sendmsg).
~ Do a ipv6_addr_v4mapped(&sk->sk_v6_daddr) check before
  calling ip6_datagram_dst_update() in patch 3 and 4.  It is
  similar to how __ip6_datagram_connect handles it.
~ One fix in ip6_datagram_dst_update() in patch 2.  It needs
  to check (np->flow_label & IPV6_FLOWLABEL_MASK) before
  doing fl6_sock_lookup.  I was confused with the naming
  of IPV6_FLOWLABEL_MASK and IPV6_FLOWINFO_MASK.
~ Check dst->obsolete just on the safe side, although I think it
  should at least have DST_OBSOLETE_FORCE_CHK by now.
~ Add Fixes tag to patch 3 and 4
~ Add some points from the previous discussion about holding
  sk lock to the commit message in patch 3.

v1:
There is a case in connected UDP socket such that
getsockopt(IPV6_MTU) will return a stale MTU value. The reproducible
sequence could be the following:
1. Create a connected UDP socket
2. Send some datagrams out
3. Receive a ICMPV6_PKT_TOOBIG
4. No new outgoing datagrams to trigger the sk_dst_check()
   logic to update the sk->sk_dst_cache.
5. getsockopt(IPV6_MTU) returns the mtu from the invalid
   sk->sk_dst_cache instead of the newly created RTF_CACHE clone.

Patch 1 and 2 are the prep work.
Patch 3 and 4 are the fixes.
