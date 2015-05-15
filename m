From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next] bridge: Fix setting a flag in
 br_fill_ifvlaninfo_range().
Date: Fri, 15 May 2015 18:45:43 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC35068365EC@ORSMSX101.amr.corp.intel.com>
References: <1431700047-22560-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: "Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:54161 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391AbbEOSqF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 14:46:05 -0400
In-Reply-To: <1431700047-22560-1-git-send-email-rami.rosen@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Rosen, Rami
>Sent: Friday, May 15, 2015 7:27 AM
>To: davem@davemloft.net
>Cc: netdev@vger.kernel.org; roopa@cumulusnetworks.com; Arad, Ronen; Rosen,
>Rami
>Subject: [PATCH net-next] bridge: Fix setting a flag in
>br_fill_ifvlaninfo_range().
>
>This patch fixes setting of vinfo.flags in the br_fill_ifvlaninfo_range(). The
>assignment of vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN has no effect
>without
>this patch, as vinfo.flags value is overriden by the
>vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END assignement,  which follows
>it immedialtely.
>
>Signed-off-by: Rami Rosen <rami.rosen@intel.com>
>---
> net/bridge/br_netlink.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>index 6b67ed3..fec65bb 100644
>--- a/net/bridge/br_netlink.c
>+++ b/net/bridge/br_netlink.c
>@@ -167,7 +167,7 @@ static int br_fill_ifvlaninfo_range(struct sk_buff *skb,
>u16 vid_start,
> 		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
>
> 		vinfo.vid = vid_end;
>-		vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END;
>+		vinfo.flags &= flags | BRIDGE_VLAN_INFO_RANGE_END;
> 		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
> 			    sizeof(vinfo), &vinfo))
> 			goto nla_put_failure;


The first part of " &= flags " has no impact as it reverts vinfo.flags to
just the bits set in the flags argument. This is exactly what
"vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN" does.

If original code was intended to indicate that the same flags are used for 
both start and end attributes except for the RANGE_BEGIN/RANGE_END flags
it would be sufficient to keep the line that clears RANGE_BEGIN bit and 
OR vinfo.flags with RANGE_END for the end attribute:

vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;

If we want the code to show what is actually been written into each
attribute, the fix should be to just delete the line which clears 
RANGE_BEGIN flag.

In either case the code as exists today is working as expected. A fix is
only needed to improve readability.
 
>--
>1.9.3
