From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 5/6] bridge: new function to pack vlans using both
 IFLA_BRIDGE_VLAN_INFO and IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Mon, 29 Dec 2014 15:25:48 -0800
Message-ID: <CAE4R7bC63CpvpAuakFvEtEJvOsowjP40q1cs2eh0R=bf-F6w=Q@mail.gmail.com>
References: <1419887132-7084-6-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson kok <wkok@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:60806 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaL2XZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 18:25:49 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so24758826wib.5
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 15:25:48 -0800 (PST)
In-Reply-To: <1419887132-7084-6-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds new function to compress vlans into ranges.
> Vlans are compressed into ranges only if the fill request is called with
> RTEXT_FILTER_BRVLAN_COMPRESSED in filtermask.
>
> Old vlan packing code is moved to a new function and continues to be
> called when filter_mask is RTEXT_FILTER_BRVLAN
>
> Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/bridge/br_netlink.c |  157 +++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 137 insertions(+), 20 deletions(-)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 4c47ba0..16bdd5a 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -67,6 +67,133 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>         return 0;
>  }
>
> +static int br_fill_ifvlaninfo_bitmap(struct sk_buff *skb,
> +                                    const unsigned long *vlan_bmp, u16 flags)
> +{
> +       struct bridge_vlan_range_info vinfo_range;
> +       struct bridge_vlan_info vinfo;
> +       u16 vid, start = 0, end = 0;

One per line?

> +       u16 pvid;

Aren't you getting an "unused" compile warning on this ^^^?

> +
> +       /* handle the untagged */

This comment ^^^ doesn't make sense here.

> +       for_each_set_bit(vid, vlan_bmp, VLAN_N_VID) {
> +               if (start == 0) {
> +                       start = vid;
> +                       end = vid;
> +               }
> +               if ((vid - end) > 1) {
> +                       memset(&vinfo_range, 0, sizeof(vinfo_range));
> +                       vinfo_range.flags |= flags;
> +                       vinfo_range.vid = start;
> +                       vinfo_range.vid_end = end;
> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
> +                                   sizeof(vinfo_range), &vinfo_range))
> +                               goto nla_put_failure;
> +                       start = vid;
> +                       end = vid;
> +               } else {
> +                       end = vid;
> +               }
> +       }

What happens with this set {1-10, 12, 20-25, 30}?  On vid 12, will
that put a VLAN_RANGE_INFO with start=end=12?  Seems strange to use
RANGE_INFO for single vlan.

Can the algorithm be simplified?  Maybe there are other examples in
the kernel of finding ranges/singles from a bitmap we could borrow
code from?

> +       if (start != 0 && end != 0) {
> +               if (start != end) {
> +                       memset(&vinfo_range, 0, sizeof(vinfo_range));
> +                       vinfo_range.flags |= flags;
> +                       vinfo_range.vid = start;
> +                       vinfo_range.vid_end = end;
> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
> +                                   sizeof(vinfo_range), &vinfo_range))
> +                               goto nla_put_failure;
> +               } else {
> +                       memset(&vinfo, 0, sizeof(vinfo));
> +                       vinfo.flags |= flags;
> +                       vinfo.vid = start;
> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
> +                                   sizeof(vinfo), &vinfo))
> +                               goto nla_put_failure;

How many IFLA_BRIDGE_VLAN_INFOs can you fit into skb?   It seems the
worst case is you'll have 4094/2 = 2047 VLAN_INFOs if using all
even-numbered vids, for example.  Will that fit?  I guess the original
code had the same concern...wonder if anyone checked this worst-case?

> +               }
> +       }
> +
> +nla_put_failure:
> +       return -EMSGSIZE;
> +}
> +
> +static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
> +                                        const struct net_port_vlans *pv)
> +{
> +       unsigned long vlan_bmp_copy[BR_VLAN_BITMAP_LEN];
> +       unsigned long untagged_bmp_copy[BR_VLAN_BITMAP_LEN];

Lots of automatic space on the stack...can you use dynamic mem
(kzalloc) for these?

> +       struct bridge_vlan_range_info vinfo_range;
> +       struct bridge_vlan_info vinfo;
> +       u16 pvid;
> +
> +       memset(vlan_bmp_copy, 0,
> +              sizeof(unsigned long) * BR_VLAN_BITMAP_LEN);
> +       bitmap_copy(vlan_bmp_copy, pv->vlan_bitmap, VLAN_N_VID);
> +
> +       memset(untagged_bmp_copy, 0,
> +              sizeof(unsigned long) * BR_VLAN_BITMAP_LEN);
> +       bitmap_copy(untagged_bmp_copy, pv->untagged_bitmap, VLAN_N_VID);
> +
> +       /* send the pvid separately first */
> +       pvid = br_get_pvid(pv);
> +       if (pvid && (pvid != VLAN_N_VID)) {
> +               memset(&vinfo, 0, sizeof(vinfo));
> +               vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
> +               if (test_bit(pvid, untagged_bmp_copy)) {
> +                       vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
> +                       clear_bit(pvid, untagged_bmp_copy);
> +               }
> +               clear_bit(pvid, vlan_bmp_copy);
> +               vinfo.vid = pvid;
> +               if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
> +                           sizeof(vinfo), &vinfo))
> +                       goto nla_put_failure;
> +       }

What if pvid is not in vlan_bmp_copy?  This statement block seems
slightly different than the original logic where BRIDGE_VLAN_INFO_PVID
was set only when looping thru vlan_bitmap and vid == pvid.  Now can
you send a IFLA_BRIDGE_VLAN_INFO with pvid even if pvid isn't in
vlan_bitmap?  Maybe pvid is always in vlan_bitmap, so it doesn't
matter.  But there is a subtle logic change here, so something to
consider.

> +
> +       /* fill untagged vlans */
> +       br_fill_ifvlaninfo_bitmap(skb, untagged_bmp_copy,
> +                                 BRIDGE_VLAN_INFO_UNTAGGED);

This might be doing more than original logic.  Original logic looped
thru vid in vlan_btimap and checked if vid was in untagged_bitmap.
Here you're dumping all bits in untagged_bitmap, without looking if
bit was set in vlan_bitmap.  Maybe you want to do an intersection of
sets vlan_bitmap and untagged_bitmap.

> +       for_each_set_bit(vid, untagged_bmp_copy, VLAN_N_VID)
> +               clear_bit(vid, vlan_bmp_copy);
> +
> +       /* fill tagged vlans */
> +       br_fill_ifvlaninfo_bitmap(skb, vlan_bmp_copy, 0);
> +
> +       return 0;
> +
> +nla_put_failure:
> +       return -EMSGSIZE;
> +}
> +
> +static int br_fill_ifvlaninfo(struct sk_buff *skb,
> +                             const struct net_port_vlans *pv)
> +{
> +       struct bridge_vlan_info vinfo;
> +       u16 pvid, vid;
> +
> +       pvid = br_get_pvid(pv);
> +       for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
> +               vinfo.vid = vid;
> +               vinfo.flags = 0;
> +               if (vid == pvid)
> +                       vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
> +
> +               if (test_bit(vid, pv->untagged_bitmap))
> +                       vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
> +
> +               if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
> +                           sizeof(vinfo), &vinfo))
> +                       goto nla_put_failure;
> +       }
> +
> +       return 0;
> +
> +nla_put_failure:
> +       return -EMSGSIZE;
> +}
> +
>  /*
>   * Create one netlink message for one interface
>   * Contains port and master info as well as carrier and bridge state.
> @@ -121,12 +248,11 @@ static int br_fill_ifinfo(struct sk_buff *skb,
>         }
>
>         /* Check if  the VID information is requested */
> -       if (filter_mask & RTEXT_FILTER_BRVLAN) {
> -               struct nlattr *af;
> +       if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
> +           (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
>                 const struct net_port_vlans *pv;
> -               struct bridge_vlan_info vinfo;
> -               u16 vid;
> -               u16 pvid;
> +               struct nlattr *af;
> +               int err;
>
>                 if (port)
>                         pv = nbp_get_vlan_info(port);
> @@ -140,21 +266,12 @@ static int br_fill_ifinfo(struct sk_buff *skb,
>                 if (!af)
>                         goto nla_put_failure;
>
> -               pvid = br_get_pvid(pv);
> -               for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
> -                       vinfo.vid = vid;
> -                       vinfo.flags = 0;
> -                       if (vid == pvid)
> -                               vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
> -
> -                       if (test_bit(vid, pv->untagged_bitmap))
> -                               vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
> -
> -                       if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
> -                                   sizeof(vinfo), &vinfo))
> -                               goto nla_put_failure;
> -               }
> -
> +               if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
> +                       err = br_fill_ifvlaninfo_compressed(skb, pv);
> +               else
> +                       err = br_fill_ifvlaninfo(skb, pv);
> +               if (err)
> +                       goto nla_put_failure;
>                 nla_nest_end(skb, af);
>         }
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
