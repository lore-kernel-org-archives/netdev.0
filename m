From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] bridge: modify bridge af spec parser
 to accomodate vlan list and ranges
Date: Sat, 03 Jan 2015 00:39:36 -0800
Message-ID: <54A7AAC8.2080009@cumulusnetworks.com>
References: <1420044533-16963-3-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DD2DE4@ORSMSX101.amr.corp.intel.com> <CAE4R7bCGC+hC1nR9YxbFB9+-cWvtkxmt1cs57kD-PpKnWk3RmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hemminger@vyatta.com" <hemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44009 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbbACIjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 03:39:39 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so25249705pab.7
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 00:39:38 -0800 (PST)
In-Reply-To: <CAE4R7bCGC+hC1nR9YxbFB9+-cWvtkxmt1cs57kD-PpKnWk3RmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/1/15, 11:34 AM, Scott Feldman wrote:
> On Thu, Jan 1, 2015 at 12:54 AM, Arad, Ronen <ronen.arad@intel.com> wrote:
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>> Behalf Of roopa@cumulusnetworks.com
>>> Sent: Wednesday, December 31, 2014 6:49 PM
>>> To: netdev@vger.kernel.org; hemminger@vyatta.com; vyasevic@redhat.com
>>> Cc: sfeldma@gmail.com; wkok@cumulusnetworks.com; Roopa Prabhu
>>> Subject: [PATCH net-next v2 2/2] bridge: modify bridge af spec parser to
>>> accomodate vlan list and ranges
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_INFO_LIST
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>> net/bridge/br_netlink.c |  115 ++++++++++++++++++++++++++++++++++------------
>>> -
>>> 1 file changed, 85 insertions(+), 30 deletions(-)
>>>
>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>> index 492ef6a..bcba9d2 100644
>>> --- a/net/bridge/br_netlink.c
>>> +++ b/net/bridge/br_netlink.c
>>> @@ -226,53 +226,108 @@ static const struct nla_policy
>>> ifla_br_policy[IFLA_MAX+1] = {
>>>        [IFLA_BRIDGE_VLAN_INFO_LIST] = { .type = NLA_NESTED, },
>>> };
>>>
>>> +static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>>> +                      int cmd, struct bridge_vlan_info *vinfo)
>>> +{
>>> +      int err = 0;
>>> +
>>> +      switch (cmd) {
>>> +      case RTM_SETLINK:
>>> +              if (p) {
>>> +                      err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>>> +                      if (err)
>>> +                              break;
>>> +
>>> +                      if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>>> +                              err = br_vlan_add(p->br, vinfo->vid,
>>> +                                                vinfo->flags);
>>> +              } else {
>>> +                      err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>>> +              }
>>> +              break;
>>> +
>>> +      case RTM_DELLINK:
>>> +              if (p) {
>>> +                      nbp_vlan_delete(p, vinfo->vid);
>>> +                      if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>>> +                              br_vlan_delete(p->br, vinfo->vid);
>>> +              } else {
>>> +                      br_vlan_delete(br, vinfo->vid);
>>> +              }
>>> +              break;
>>> +      }
>>> +
>>> +      return err;
>>> +}
>>> +
>>> static int br_afspec(struct net_bridge *br,
>>>                     struct net_bridge_port *p,
>>>                     struct nlattr *af_spec,
>>>                     int cmd)
>>> {
>>>        struct nlattr *tb[IFLA_BRIDGE_MAX+1];
>>> +      struct nlattr *attr;
>>>        int err = 0;
>>> +      int rem;
>>>
>>>        err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
>>>        if (err)
>>>                return err;
>>>
>>>        if (tb[IFLA_BRIDGE_VLAN_INFO]) {
>>> -              struct bridge_vlan_info *vinfo;
>>> -
>>> -              vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
>>> -
>>> -              if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
>>> -                      return -EINVAL;
>>> -
>>> -              switch (cmd) {
>>> -              case RTM_SETLINK:
>>> -                      if (p) {
>>> -                              err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>>> -                              if (err)
>>> -                                      break;
>>> -
>>> -                              if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>>> -                                      err = br_vlan_add(p->br, vinfo->vid,
>>> -                                                        vinfo->flags);
>>> -                      } else
>>> -                              err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>>> -
>>> -                      break;
>>> -
>>> -              case RTM_DELLINK:
>>> -                      if (p) {
>>> -                              nbp_vlan_delete(p, vinfo->vid);
>>> -                              if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>>> -                                      br_vlan_delete(p->br, vinfo->vid);
>>> -                      } else
>>> -                              br_vlan_delete(br, vinfo->vid);
>>> -                      break;
>>> +              attr = tb[IFLA_BRIDGE_VLAN_INFO];
>>> +              if (nla_len(attr) != sizeof(struct bridge_vlan_info))
>>> +                      goto err_inval;
>>> +
>>> +              err = br_vlan_info(br, p, cmd,
>>> +                                 (struct bridge_vlan_info *)nla_data(attr));
>>> +
>>> +      } else if (tb[IFLA_BRIDGE_VLAN_INFO_LIST]) {
>>> +              struct bridge_vlan_info *vinfo_start = NULL;
>>> +              struct bridge_vlan_info *vinfo = NULL;
>>> +
>>> +              nla_for_each_nested(attr, tb[IFLA_BRIDGE_VLAN_INFO_LIST], rem) {
>>> +                      if (nla_len(attr) != sizeof(struct bridge_vlan_info) ||
>>> +                          nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>>> +                              goto err_inval;
>>> +                      vinfo = nla_data(attr);
>>> +                      if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_START) {
>>> +                              if (vinfo_start)
>>> +                                      goto err_inval;
>>> +                              vinfo_start = vinfo;
>>> +                              continue;
>>> +                      }
>>> +
>>> +                      if (vinfo_start) {
>>> +                              int v;
>>> +
>>> +                              if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
>>> +                                      goto err_inval;
>>> +
>>> +                              if (vinfo->vid < vinfo_start->vid)
>> This check rejects inverted range. However it allows the RANGE_START and
>> RANGE_END vinfos to have the same vid. Isn't it inconsistent with the rejection
>> of a single vinfo with both RANGE_START and RANGE_END set?
> Allowing both START and END to be set on single vinfo might simplify
> the encoding of LIST, so maybe it should be allowed.

sorry, i did not understand this. How does it help ?.
>
> Roopa, I know you dropped the subsequent notification patches from the
> set, but I suspect now with these new START/END markers, the
> notification algorithm can be very close to the original loop, without
> having to make copies of the vlan_bitmap and untagged_bitmap.
>   Using
> both START/END on a single vinfo will keep the loop simple for adding
> single vids that are not in a range.
The way i am seeing it is, both, making copies of vlan_bitmap and using 
the existing loop can be used
with both old and the new proposed netlink attributes (unless i am 
missing something).
Our original in-house code used copies of vlan bitmap (not authored by 
me) and it was well tested,
  so it was safer to post that code in terms of testing effort.

But during the course of this review, i do realize that the existing 
loop can be used. And now i see that the existing loop
can be used with both the old proposed and the new netlink formats. I 
have coded up the patches. In the process of testing it. Will post the 
new series soon. Maybe you will spot something.
>
> (hmmm...START/STOP or BEGIN/END?  Seems START/END is mixing the two
> concepts...BEGIN/END seems best)
Sure, no preference there. I will use BEGIN/END.

Thanks,
Roopa
