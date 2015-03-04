From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 4/7] mpls: Basic support for adding and removing routes
Date: Wed, 04 Mar 2015 14:36:33 -0600
Message-ID: <87h9u0lctq.fsf@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<878ufdtvjr.fsf_-_@x220.int.ebiederm.org>
	<54F6BEAA.2080708@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55595 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbCDUkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:40:16 -0500
In-Reply-To: <54F6BEAA.2080708@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Wed, 04 Mar 2015 00:13:30
	-0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 3/3/15, 5:12 PM, Eric W. Biederman wrote:
>> mpls_route_add and mpls_route_del implement the basic logic for adding
>> and removing Next Hop Label Forwarding Entries from the MPLS input
>> label map.  The addition and subtraction is done in a way that is
>> consistent with how the existing routing table in Linux are
>> maintained.  Thus all of the work to deal with NLM_F_APPEND,
>> NLM_F_EXCL, NLM_F_REPLACE, and NLM_F_CREATE.
>>
>> Cases that are not clearly defined such as changing the interpretation
>> of the mpls reserved labels is not allowed.
>>
>> Because it seems like the right thing to do adding an MPLS route without
>> specifying an input label and allowing the kernel to pick a free label
>> table entry is supported.   The implementation is currently less than optimal
>> but that can be changed.
>>
>> As I don't have anything else to test with only ethernet and the loopback
>> device are the only two device types currently supported for forwarding
>> MPLS over.
>>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>   net/mpls/af_mpls.c | 133 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 133 insertions(+)
>>
>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>> index b097125dfa33..e432f092f2fb 100644
>> --- a/net/mpls/af_mpls.c
>> +++ b/net/mpls/af_mpls.c
>> @@ -16,6 +16,7 @@
>>   #include <net/netns/generic.h>
>>   #include "internal.h"
>>   +#define LABEL_NOT_SPECIFIED (1<<20)
>>   #define MAX_NEW_LABELS 2
>>     /* This maximum ha length copied from the definition of struct
>> neighbour */
>> @@ -211,6 +212,19 @@ static struct packet_type mpls_packet_type __read_mostly = {
>>   	.func = mpls_forward,
>>   };
>>   +struct mpls_route_config {
>> +	u32		rc_protocol;
>> +	u32		rc_ifindex;
>> +	u16		rc_via_family;
>> +	u16		rc_via_alen;
>> +	u8		rc_via[MAX_VIA_ALEN];
>> +	u32		rc_label;
>> +	u32		rc_output_labels;
>> +	u32		rc_output_label[MAX_NEW_LABELS];
>> +	u32		rc_nlflags;
>> +	struct nl_info	rc_nlinfo;
>> +};
>> +
>>   static struct mpls_route *mpls_rt_alloc(size_t alen)
>>   {
>>   	struct mpls_route *rt;
>> @@ -245,6 +259,125 @@ static void mpls_route_update(struct net *net, unsigned index,
>>   	mpls_rt_free(old);
>>   }
>>   +static unsigned find_free_label(struct net *net)
>> +{
>> +	unsigned index;
>> +	for (index = 16; index < net->mpls.platform_labels; index++) {
>> +		if (!net->mpls.platform_label[index])
>> +			return index;
>> +	}
>> +	return LABEL_NOT_SPECIFIED;
>> +}
>> +
>> +static int mpls_route_add(struct mpls_route_config *cfg)
>> +{
>> +	struct net *net = cfg->rc_nlinfo.nl_net;
>> +	struct net_device *dev = NULL;
>> +	struct mpls_route *rt, *old;
>> +	unsigned index;
>> +	int i;
>> +	int err = -EINVAL;
>> +
>> +	index = cfg->rc_label;
>> +
>> +	/* If a label was not specified during insert pick one */
>> +	if ((index == LABEL_NOT_SPECIFIED) &&
>> +	    (cfg->rc_nlflags & NLM_F_CREATE)) {
>> +		index = find_free_label(net);
>> +	}
>> +
>> +	/* The first 16 labels are reserved, and may not be set */
>> +	if (index < 16)
>> +		goto errout;
>> +
>> +	/* The full 20 bit range may not be supported. */
>> +	if (index >= net->mpls.platform_labels)
>> +		goto errout;
>> +
>> +	/* Ensure only a supported number of labels are present */
>> +	if (cfg->rc_output_labels > MAX_NEW_LABELS)
>> +		goto errout;
>> +
>> +	err = -ENODEV;
>> +	dev = dev_get_by_index(net, cfg->rc_ifindex);
>> +	if (!dev)
>> +		goto errout;
>> +
>> +	/* For now just support ethernet devices */
>> +	err = -EINVAL;
>> +	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
>> +		goto errout;
>> +
>> +	err = -EINVAL;
>> +	if ((cfg->rc_via_family == AF_PACKET) &&
>> +	    (dev->addr_len != cfg->rc_via_alen))
>> +		goto errout;
>> +
>> +	/* Append makes no sense with mpls */
>> +	err = -EINVAL;
>
> minor nit: should this be -ENOTSUPP in that case ? (NLM_F_REPLACE and NLM_F_APPEND are
> really operations. But, one can argue that they are an attribute of the msg and hence -EINVAL might be ok).
> I did not find any other such case for consistency check.

Yes.  IPv4 implements NLM_F_APPEND and IPv6 ignores it.

I will add a patch to change the error code.

Do you happen to know what NLM_F_APPEND means?  I couldn't figure out
when glancing through the IPv4 code.

NLM_F_REPLACE seems obvious.  Though it seems to have exactly the
oposite meaning of NLM_F_EXCL.  Which seems to make NLM_F_EXCL
redundant.

My hunch is that there are meanings here that apply when you are doing
longest prefix matching that don't quite apply when you are are doing
exact match routing.

Eric
