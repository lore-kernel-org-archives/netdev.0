From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 3/6] bridge: modify IFLA_AF_SPEC parser to parse IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Tue, 30 Dec 2014 06:17:45 -0800
Message-ID: <54A2B409.1010708@cumulusnetworks.com>
References: <1419887132-7084-4-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DD146F@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson kok <wkok@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49254 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaL3ORr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 09:17:47 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so19341191pdi.9
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 06:17:46 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DD146F@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/14, 12:40 AM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of roopa@cumulusnetworks.com
>> Sent: Monday, December 29, 2014 11:05 PM
>> To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com
>> Cc: Roopa Prabhu; Wilson kok
>> Subject: [PATCH 3/6] bridge: modify IFLA_AF_SPEC parser to parse
>> IFLA_BRIDGE_VLAN_RANGE_INFO
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_RANGE_INFO
>>
>> Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> net/bridge/br_netlink.c |   70 +++++++++++++++++++++++++++++++++-------------
>> -
>> 1 file changed, 49 insertions(+), 21 deletions(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index e7d1fc0..4c47ba0 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -227,48 +227,76 @@ static const struct nla_policy
>> ifla_br_policy[IFLA_MAX+1] = {
>> 			 .len = sizeof(struct bridge_vlan_range_info), },
>> };
>>
>> +static int br_afspec_vlan_add(struct net_bridge *br,
>> +			      struct net_bridge_port *p,
>> +			      u16 vid, u16 flags)
>> +{
>> +	int err = 0;
>> +
>> +	if (p) {
>> +		err = nbp_vlan_add(p, vid, flags);
>> +		if (err)
>> +			return err;
>> +
>> +		if (flags & BRIDGE_VLAN_INFO_MASTER)
>> +			err = br_vlan_add(p->br, vid, flags);
>> +	} else {
>> +		err = br_vlan_add(br, vid, flags);
>> +	}
>> +
>> +	return err;
>> +}
>> +
>> +static void br_afspec_vlan_del(struct net_bridge *br,
>> +			       struct net_bridge_port *p,
>> +			       u16 vid, u16 flags)
>> +{
>> +	if (p) {
>> +		nbp_vlan_delete(p, vid);
>> +		if (flags & BRIDGE_VLAN_INFO_MASTER)
>> +			br_vlan_delete(p->br, vid);
>> +	} else {
>> +		br_vlan_delete(br, vid);
>> +	}
>> +}
>> +
>> static int br_afspec(struct net_bridge *br,
>> 		     struct net_bridge_port *p,
>> 		     struct nlattr *af_spec,
>> 		     int cmd)
>> {
>> -	struct bridge_vlan_info *vinfo;
>> -	int err = 0;
>> +	struct bridge_vlan_range_info *vinfo;
>> 	struct nlattr *attr;
>> 	int err = 0;
>> 	int rem;
>> 	u16 vid;
>>
>> 	nla_for_each_nested(attr, af_spec, rem) {
>> -		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>> +		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO &&
>> +		    nla_type(attr) != IFLA_BRIDGE_VLAN_RANGE_INFO)
>> 			continue;
>> -
>> 		vinfo = nla_data(attr);
>> -		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
>> +
>> +		if (nla_type(attr) == IFLA_BRIDGE_VLAN_INFO)
>> +			vinfo->vid_end = vinfo->vid;
>> +
>> +		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK ||
>> +		    vinfo->vid_end >= VLAN_VID_MASK ||
>> +		    vinfo->vid > vinfo->vid_end)
>> 			return -EINVAL;
>>
>> 		switch (cmd) {
>> 		case RTM_SETLINK:
>> -			if (p) {
>> -				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>> +			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++) {
>> +				err = br_afspec_vlan_add(br, p, vid,
>> +							 vinfo->flags);
> vinfo->flags could have BRIDGE_VLAN_INFO_PVID set. It is really a port property and there could only be a single PVID for a port. The loop will make the port pvid set, in turn, to each vid in the range until it finally set to vid_end.
> This could be avoided by turning off this flag for all but the last vid in range:
>
> 				err = br_afspec_vlan_addr(br, p, vid,
>                                                      ((vid == vinfo->vid_end)
>                                                       ? vinfo->flags
>                                                       : vinfo->flags & ~BRIDGE_VLAN_INFO_PVID));
> Another alternative could be to add explicit pvid field to bridge_vlan_range_info and disallow PVID flag.
> This allows for setting the port pvid to any vid in the range.
>
> If both alternatives seem somewhat complex we could just disallow PVID flag in IFLA_BRIDGE_VLAN_RANGE_INFO and allow it only in IFLA_BRIDGE_VLAN_INFO.

I believe it is a user error to set PVID flag on a range of vlans using 
IFLA_BRIDGE_VLAN_RANGE_INFO
or for that matter using multiple IFLA_BRIDGE_VLAN_INFO with pvid flag 
set. Today, the last one probably sticks.
I will check current behavior and mimic that or return EINVAL when 
multiple attributes come in with the PVID flag.



>
>   
>> 				if (err)
>> 					break;
>> -
>> -				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> -					err = br_vlan_add(p->br, vinfo->vid,
>> -							  vinfo->flags);
>> -			} else
>> -				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>> -
>> +			}
>> 			break;
>> -
>> 		case RTM_DELLINK:
>> -			if (p) {
>> -				nbp_vlan_delete(p, vinfo->vid);
>> -				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>> -					br_vlan_delete(p->br, vinfo->vid);
>> -			} else
>> -				br_vlan_delete(br, vinfo->vid);
>> +			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++)
>> +				br_afspec_vlan_del(br, p, vid, vinfo->flags);
>> 			break;
>> 		}
>> 	}
>> --
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
