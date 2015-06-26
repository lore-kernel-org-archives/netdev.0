From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: [PATCH] - vxlan: gro not effective for intel 82599
Date: Thu, 25 Jun 2015 17:03:55 -0700
Message-ID: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pradeeps@linux.vnet.ibm.com,
	jkidambi@us.ibm.com
To: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:36132 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbFZAD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 20:03:59 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Thu, 25 Jun 2015 18:03:59 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D9E5C3E4003B
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 18:03:56 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5Q03Hkd42926304
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 17:03:17 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5Q03tSW014032
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 18:03:56 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem:
-------

GRO is enabled on the interfaces in the following test,
but GRO does not take effect for vxlan-encapsulated tcp streams. The 
root
cause of why GRO does not take effect is described below.

VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|

Because gro is not effective, the throughput for vxlan-encapsulated
tcp-stream is around 3 Gbps.

With the proposed patch, gro takes effect for vxlan-encapsulated tcp 
streams,
and performance in the same test is around 8.6 Gbps.


Root Cause:
----------


At entry to udp4_gro_receive(), the gro parameters are set as follows:

     skb->ip_summed  == 0 (CHECKSUM_NONE)
     NAPI_GRO_CB(skb)->csum_cnt == 0
     NAPI_GRO_CB(skb)->csum_valid == 0

     UDH header checksum is 0.

static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
					 struct sk_buff *skb)
{

          <snip>

	if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
						 inet_gro_compute_pseudo))

>>>             This calls __skb_incr_checksum_unnecessary which sets
>>>                     skb->ip_summed to  CHECKSUM_UNNECESSARY
>>> 

		goto flush;
	else if (uh->check)
		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
					     inet_gro_compute_pseudo);
skip:
	NAPI_GRO_CB(skb)->is_ipv6 = 0;
	return udp_gro_receive(head, skb, uh);

}

struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff 
*skb,
				 struct udphdr *uh)
{
	struct udp_offload_priv *uo_priv;
	struct sk_buff *p, **pp = NULL;
	struct udphdr *uh2;
	unsigned int off = skb_gro_offset(skb);
	int flush = 1;

	if (NAPI_GRO_CB(skb)->udp_mark ||
	    (skb->ip_summed != CHECKSUM_PARTIAL &&
	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
	     !NAPI_GRO_CB(skb)->csum_valid))
		goto out;
>>> 
>>>      vxlan GRO gets skipped due to the above condition because here,:
>>>          skb->ip_summed == CHECKSUM_UNNECESSARY
>>>          NAPI_GRO_CB(skb)->csum_cnt == 0
>>>          NAPI_GRO_CB(skb)->csum_valid == 0

There is no reason for skipping vxlan gro in the above combination of 
conditions,
because, tcp4_gro_receive() validates the inner tcp checksum anyway !


Patch:
------

Signed-off-by: Ramu Ramamurthy <ramu.ramamurthy@us.ibm.com>
---
  net/ipv4/udp_offload.c |    1 +
  1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f938616..17fc12b 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -301,6 +301,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff 
**head, struct sk_buff *skb,

  	if (NAPI_GRO_CB(skb)->udp_mark ||
  	    (skb->ip_summed != CHECKSUM_PARTIAL &&
+	     skb->ip_summed != CHECKSUM_UNNECESSARY &&
  	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
  	     !NAPI_GRO_CB(skb)->csum_valid))
  		goto out;
-- 
1.7.1





Notes:
-------

The above gro fix applies to all udp-encapsulation protocols (vxlan, 
geneve)
