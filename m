From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/7] net: Eliminate calls to flow_dissector and introduce flow_keys_digest
Date: Fri, 1 May 2015 11:30:11 -0700
Message-ID: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49615 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751311AbbEASa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:28 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IRfKJ018495
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4djf861d-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:27 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 22ce8b72f03011e4b0b20002c95209d8-7f2dd240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch set we add skb_get_hash_perturb which gets the skbuff
hash for a packet and perturbs it using a provided key and jhash1.
This function is used in serveral qdiscs and eliminates many calls
to flow_dissector and jhash3 to get a perturbed hash for a packet.

To handle the sch_choke issue (passes flow_keys in skbuff cb) we
add flow_keys_digest which is a digest of a flow constructed
from a flow_keys structure.

This is the second version of these patches I posted a while ago,
and is prerequisite work to increasing the size of the flow_keys
structure and hashing over it (full IPv6 address, flow label, VLAN ID,
etc.).

Version 2:

- Add keyval parameter to __flow_hash_from_keys which allows caller to
  set the initval for jhash
- Perturb always does flow dissection and creates hash based on
  input perturb value which acts as the keyval to __flow_hash_from_keys
- Added a _flow_keys_digest_data which is used in make_flow_keys_digest.
  This fills out the digest by populating individual fields instead
  of copying the whole structure.

Tom Herbert (7):
  net: Add skb_get_hash_perturb
  sched: Call skb_get_hash_perturb in sch_fq_codel
  sched: Call skb_get_hash_perturb in sch_hhf
  sched: Call skb_get_hash_perturb in sch_sfb
  sched: Call skb_get_hash_perturb in sch_sfq
  net: Add flow_keys digest
  sch_choke: Use flow_keys_digest

 include/linux/skbuff.h    |  2 ++
 include/net/flow_keys.h   | 16 ++++++++++++
 net/core/flow_dissector.c | 65 +++++++++++++++++++++++++++++++++++++++++------
 net/sched/sch_choke.c     | 14 +++-------
 net/sched/sch_fq_codel.c  | 11 ++------
 net/sched/sch_hhf.c       | 19 +-------------
 net/sched/sch_sfb.c       | 24 ++++++-----------
 net/sched/sch_sfq.c       | 27 ++------------------
 8 files changed, 92 insertions(+), 86 deletions(-)

-- 
1.8.1
