From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] bridge: modify bridge af spec parser
 to accomodate vlan list and ranges
Date: Thu, 01 Jan 2015 02:01:34 -0800
Message-ID: <54A51AFE.2010005@cumulusnetworks.com>
References: <1420044533-16963-3-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DD2DE4@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hemminger@vyatta.com" <hemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59536 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbAAKBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 05:01:36 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so22518798pab.4
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 02:01:36 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DD2DE4@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/1/15, 12:54 AM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of roopa@cumulusnetworks.com
>> Sent: Wednesday, December 31, 2014 6:49 PM
>> To: netdev@vger.kernel.org; hemminger@vyatta.com; vyasevic@redhat.com
>> Cc: sfeldma@gmail.com; wkok@cumulusnetworks.com; Roopa Prabhu
>> Subject: [PATCH net-next v2 2/2] bridge: modify bridge af spec parser to
>> accomodate vlan list and ranges
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_INFO_LIST
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> net/bridge/br_netlink.c |  115 ++++++++++++++++++++++++++++++++++------------
>> -
>> 1 file changed, 85 insertions(+), 30 deletions(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 492ef6a..bcba9d2 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -226,53 +226,108 @@ static const struct nla_policy
>> ifla_br_policy[IFLA_MAX+1] = {
>> 	[IFLA_BRIDGE_VLAN_INFO_LIST] = { .type = NLA_NESTED, },
>> };
>>
>> +static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>> +			int cmd, struct bridge_vlan_info *vinfo)
>> +{
>> +	int err = 0;
>> +
>> +	switch (cmd) {
>> +	case RTM_SETLINK:
>> +		if (p) {
>> +			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>> +			if (err)
>> +				break;
>> +
>> +			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> +				err = br_vlan_add(p->br, vinfo->vid,
>> +						  vinfo->flags);
>> +		} else {
>> +			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>> +		}
>> +		break;
>> +
>> +	case RTM_DELLINK:
>> +		if (p) {
>> +			nbp_vlan_delete(p, vinfo->vid);
>> +			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> +				br_vlan_delete(p->br, vinfo->vid);
>> +		} else {
>> +			br_vlan_delete(br, vinfo->vid);
>> +		}
>> +		break;
>> +	}
>> +
>> +	return err;
>> +}
>> +
>> static int br_afspec(struct net_bridge *br,
>> 		     struct net_bridge_port *p,
>> 		     struct nlattr *af_spec,
>> 		     int cmd)
>> {
>> 	struct nlattr *tb[IFLA_BRIDGE_MAX+1];
>> +	struct nlattr *attr;
>> 	int err = 0;
>> +	int rem;
>>
>> 	err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
>> 	if (err)
>> 		return err;
>>
>> 	if (tb[IFLA_BRIDGE_VLAN_INFO]) {
>> -		struct bridge_vlan_info *vinfo;
>> -
>> -		vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
>> -
>> -		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
>> -			return -EINVAL;
>> -
>> -		switch (cmd) {
>> -		case RTM_SETLINK:
>> -			if (p) {
>> -				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>> -				if (err)
>> -					break;
>> -
>> -				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> -					err = br_vlan_add(p->br, vinfo->vid,
>> -							  vinfo->flags);
>> -			} else
>> -				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>> -
>> -			break;
>> -
>> -		case RTM_DELLINK:
>> -			if (p) {
>> -				nbp_vlan_delete(p, vinfo->vid);
>> -				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> -					br_vlan_delete(p->br, vinfo->vid);
>> -			} else
>> -				br_vlan_delete(br, vinfo->vid);
>> -			break;
>> +		attr = tb[IFLA_BRIDGE_VLAN_INFO];
>> +		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
>> +			goto err_inval;
>> +
>> +		err = br_vlan_info(br, p, cmd,
>> +				   (struct bridge_vlan_info *)nla_data(attr));
>> +
>> +	} else if (tb[IFLA_BRIDGE_VLAN_INFO_LIST]) {
>> +		struct bridge_vlan_info *vinfo_start = NULL;
>> +		struct bridge_vlan_info *vinfo = NULL;
>> +
>> +		nla_for_each_nested(attr, tb[IFLA_BRIDGE_VLAN_INFO_LIST], rem) {
>> +			if (nla_len(attr) != sizeof(struct bridge_vlan_info) ||
>> +			    nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>> +				goto err_inval;
>> +			vinfo = nla_data(attr);
>> +			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_START) {
>> +				if (vinfo_start)
>> +					goto err_inval;
>> +				vinfo_start = vinfo;
>> +				continue;
>> +			}
>> +
>> +			if (vinfo_start) {
>> +				int v;
>> +
>> +				if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
>> +					goto err_inval;
>> +
>> +				if (vinfo->vid < vinfo_start->vid)
> This check rejects inverted range. However it allows the RANGE_START and
> RANGE_END vinfos to have the same vid. Isn't it inconsistent with the rejection
> of a single vinfo with both RANGE_START and RANGE_END set?
sure, i will make it <= to error out if they are equal.
>> +					goto err_inval;
> Are additional validation such as consistency of flags between the RANGE_START
> and RANGE_END vinfos is needed here?
sure, i can add them (I have some of them in the iproute2 patch as well).
> The loop below applies flags (more precisely all data except for vid) from the
> RANGE_START vinfo to all vids in the range. All data from the RANGE_END vinfo
> is ignored.
>   
>> +
>> +				for (v = vinfo_start->vid; v <= vinfo->vid;
>> +					v++) {
>> +					vinfo_start->vid = v;
> This changes the vinfo with RANGE_START flag within the incoming message. Would
> it be better to left the input message unmodified and use a local copy of
> struct bridge_vlan_info?
agreed, I will make a copy.

>> +					err = br_vlan_info(br, p, cmd,
>> +							   vinfo_start);
>> +					if (err)
>> +						break;
>> +				}
>> +				vinfo_start = NULL;
>> +			} else {
>> +				err = br_vlan_info(br, p, cmd, vinfo);
>> +			}
>> +			if (err)
>> +				break;
>> 		}
>> 	}
>>
>> 	return err;
>> +
>> +err_inval:
>> +	return -EINVAL;
>> }
>>
>> static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
>> --
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
