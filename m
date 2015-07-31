From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/5] ipv6: Turn on auto IPv6 flow labels by default
Date: Fri, 31 Jul 2015 16:52:09 -0700
Message-ID: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36469 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751701AbbGaXzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:55:44 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6VNs4XF013370
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:55:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w0j9p8692-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:55:43 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a6a5049837df11e5a9b10002c9521c9e-fc7f02b0 for <netdev@vger.kernel.org>;	Fri,
 31 Jul 2015 16:55:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BSD (MacOS) has already turned on flow labels by default and this does
not seem to be causing any problems in the Internet. Let's go ahead
and turn them on by default. We'll continue to monitor for any devices
start choking on them.

Flow labels are important since they are the desired solution for
network devices to perform ECMP and RSS (RFC6437 and RFC6438).
Traditionally, devices perform a 5-tuple hash on packets that
includes port numbers. For the most part, these devices can only
compute 5-tuple hashes for TCP and UDP. This severely limits our ability
to get good network load balancing for other protocols (IPIP, GRE,ESP,
etc.), and hence we are limited in using other protocols. Unfortunately,
this method is accepted as the de facto standard to the extent that
there are several proposals to encapsulate protocols in UDP _just_ for
the purposes for getting ECMP to work. With hosts generating flow labels
and devices taking them as input into ECMP (several already do), we can
start to fix this fundamental problem. 

This patch set:
 - Changes IPV6_FLOWINFO sockopt to be opt-out of flow labels for
   connections rather than opt-in
 - Disable flow label state ranges sysctl by default
 - Enable auto flow labels sysctl by default

v2:
  - Added functions to create an skb->hash based on flowi4 and flowi6.
    These are called in output path when creating a packet
  - Call skb_get_hash_flowi6 in ip6_make_flowlabel
  - Implement the auto_flowlabels sysctl as a mode for auto flowlabels.
    There are four modes which correspond to flow labels being enabled
    and whether socket option can be used to opt in or opt out of
    using them

Tom Herbert (5):
  net: Add functions to get skb->hash based on flow structures
  ipv6: Call skb_get_hash_flowi6 to get skb->hash in ip6_make_flowlabel
  ipv6: Implement different admin modes for automatic flow labels
  ipv6: Disable flowlabel state ranges by default
  ipv6: Enable auto flow labels by default

 Documentation/networking/ip-sysctl.txt | 20 +++++++----
 include/linux/skbuff.h                 | 21 ++++++++++++
 include/net/ipv6.h                     | 62 ++++++++++++++++++++++++++--------
 net/core/flow_dissector.c              | 58 ++++++++++++++++++++++++++++---
 net/ipv6/af_inet6.c                    |  5 +--
 net/ipv6/ip6_gre.c                     |  5 +--
 net/ipv6/ip6_output.c                  |  4 +--
 net/ipv6/ip6_tunnel.c                  |  2 +-
 net/ipv6/sysctl_net_ipv6.c             |  7 +++-
 9 files changed, 151 insertions(+), 33 deletions(-)

-- 
1.8.5.6
