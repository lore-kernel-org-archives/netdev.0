From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] vlan: Simplify the code now that VLAN_FLAG_REORDER_HDR is always set
Date: Sat, 11 Jun 2011 23:17:10 -0700
Message-ID: <m1r56z1sm1.fsf@fess.ebiederm.org>
References: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<m14o4mjzh3.fsf_-_@fess.ebiederm.org>
	<m1y61yiktf.fsf_-_@fess.ebiederm.org>
	<20110609105900.GA11005@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCa?= =?utf-8?Q?n?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35409 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab1FLGRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 02:17:19 -0400
In-Reply-To: <20110609105900.GA11005@minipsycho.brq.redhat.com> (Jiri Pirko's
	message of "Thu, 9 Jun 2011 12:59:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> writes:

> Sun, May 22, 2011 at 09:42:20PM CEST, ebiederm@xmission.com wrote:
>>
>>Now that we no longer support clearing VLAN_FLAG_REORDER_HDR remove the
>>code that was needed to cope with the case when it was cleared.
>>
>>Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>>---
>> net/8021q/vlan_dev.c |   45 +++++----------------------------------------
>> 1 files changed, 5 insertions(+), 40 deletions(-)
>>
>>diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>>index 20629fe..2b3ca1e 100644
>>--- a/net/8021q/vlan_dev.c
>>+++ b/net/8021q/vlan_dev.c
>>@@ -96,63 +96,28 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
>> 				const void *daddr, const void *saddr,
>> 				unsigned int len)
>> {
>>-	struct vlan_hdr *vhdr;
>>-	unsigned int vhdrlen = 0;
>>-	u16 vlan_tci = 0;
>> 	int rc;
>> 
>>-	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR)) {
>>-		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
>>-
>>-		vlan_tci = vlan_dev_info(dev)->vlan_id;
>>-		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
>>-		vhdr->h_vlan_TCI = htons(vlan_tci);
>>-
>>-		/*
>>-		 *  Set the protocol type. For a packet of type ETH_P_802_3/2 we
>>-		 *  put the length in here instead.
>>-		 */
>>-		if (type != ETH_P_802_3 && type != ETH_P_802_2)
>>-			vhdr->h_vlan_encapsulated_proto = htons(type);
>>-		else
>>-			vhdr->h_vlan_encapsulated_proto = htons(len);
>>-
>>-		skb->protocol = htons(ETH_P_8021Q);
>>-		type = ETH_P_8021Q;
>>-		vhdrlen = VLAN_HLEN;
>>-	}
>>-
>> 	/* Before delegating work to the lower layer, enter our MAC-address */
>> 	if (saddr == NULL)
>> 		saddr = dev->dev_addr;
>> 
>> 	/* Now make the underlying real hard header */
>> 	dev = vlan_dev_info(dev)->real_dev;
>>-	rc = dev_hard_header(skb, dev, type, daddr, saddr, len + vhdrlen);
>>-	if (rc > 0)
>>-		rc += vhdrlen;
>>+	rc = dev_hard_header(skb, dev, type, daddr, saddr, len);
>> 	return rc;
>> }
>> 
>> static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
>> 					    struct net_device *dev)
>> {
>>-	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
>> 	unsigned int len;
>>+	u16 vlan_tci;
>> 	int ret;
>> 
>>-	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
>>-	 *
>>-	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
>>-	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
>>-	 */
>>-	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
> 	    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 	    		this should stay here.
>

I admit this is a change in behavior from today so we need to be careful
here.

At least the comment needs to change.

When this code was written the assumption was that everything would come
in tagged and this code was a special exception for pf_packet sockets.

Now everything comes in untagged this code becomes a special exception
for pf_packet sockets of not putting on a vlan header.

To me this special exception pf_packet sockets looks like a bug, that
should have been conditionality on VLAN_FLAG_REORDER_HDR but was over
looked.

Now maybe we want to be bug compatible, or do this as a separate patch.

I would expect sending tagged packets out a vlan device would result
in double tagged packets but apparently not always.


Eric
