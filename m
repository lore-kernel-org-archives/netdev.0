From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [RFC PATCH 2/5] netfilter: Factor out nf_ct_get_info().
Date: Wed, 21 Oct 2015 14:38:35 -0700
Message-ID: <720547DD-AEFE-4FE0-B718-B9A9D425998E@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com> <1445379629-112880-2-git-send-email-jrajahalme@nicira.com> <20151021104556.GC2135@salvia>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34016 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbbJUVij convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 17:38:39 -0400
Received: by padhk11 with SMTP id hk11so65709720pad.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 14:38:38 -0700 (PDT)
In-Reply-To: <20151021104556.GC2135@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 21, 2015, at 3:45 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 
> On Tue, Oct 20, 2015 at 03:20:26PM -0700, Jarno Rajahalme wrote:
>> Define a new inline function to map conntrack status to enum
>> ip_conntrack_info.  This removes the need to otherwise duplicate this
>> code in a later patch.
> 
> Where is that later patch that justifies this update?
> 

It is in patch 5/5, ovs_ct_find_existing(). The intent it to locate an existing conntrack entry without modifying it, if such an entry exists. This is needed in a case where we first go through the conntrack (calling nf_conntrack_in), then recirculate (to match on the state bits), but do not find a matching flow entry in the flow table. In this case we issue an upcall and let the OVS userspace compute a new flow entry. When the packet gets back to kernel we have lost the skb (as we do not buffer it in the kernel after issuing the upcall). ovs_ct_find_existing() can then be used to populate the nfct and nfctinfo fields of the new skb, as if this skb had gone through the nf_conntrack_in() call. This allows us to pass the packet through NAT after such an upcall without passing the packet thro
 ugh nf_conntrack_in() twice.

ovs_ct_find_existing() is intended to be used only when we have evidence in the OVS flow key that the packet actually went through nf_conntrack_in() prior to the upcall. In the current version of the patches I do not have a test case for this, and I intend to separate out this change into a separate patch before the NAT patch for the next (non-RFC) version.

I could implement ovs_ct_find_existing() using exported conntrack APIs apart from this mapping from conntrack status to enum ip_conntrack_info. ovs_ct_find_existing() is in no way OVS specific, though, so it could be added to the conntrack proper as well, if so desired.

  Jarno

>> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
>> ---
>> include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
>> net/netfilter/nf_conntrack_core.c    | 22 +++-------------------
>> 2 files changed, 18 insertions(+), 19 deletions(-)
>> 
>> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
>> index fde4068..b3de10e 100644
>> --- a/include/net/netfilter/nf_conntrack.h
>> +++ b/include/net/netfilter/nf_conntrack.h
>> @@ -125,6 +125,21 @@ nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
>> 			    tuplehash[hash->tuple.dst.dir]);
>> }
>> 
>> +static inline enum ip_conntrack_info
>> +nf_ct_get_info(const struct nf_conntrack_tuple_hash *h)
>> +{
>> +	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
>> +
>> +	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
>> +		return IP_CT_ESTABLISHED_REPLY;
>> +	/* Once we've had two way comms, always ESTABLISHED. */
>> +	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
>> +		return IP_CT_ESTABLISHED;
>> +	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
>> +		return IP_CT_RELATED;
>> +	return IP_CT_NEW;
>> +}
> 
> I would really like to see how you want to use this.
