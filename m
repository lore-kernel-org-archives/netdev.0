From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC][net-next-2.6 PATCH v2] 8021q: set hard_header_len when
 VLAN offload features are toggled
Date: Wed, 27 Oct 2010 14:40:10 -0700
Message-ID: <4CC89C3A.7000209@intel.com>
References: <20101026215933.2339.45454.stgit@jf-dev1-dcblab> <AANLkTi=9tL5yrVGWsOagcgyKte5z8R9ADdz5n-Uf2Lsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14729 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932477Ab0J0VkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 17:40:11 -0400
In-Reply-To: <AANLkTi=9tL5yrVGWsOagcgyKte5z8R9ADdz5n-Uf2Lsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 7:05 PM, Jesse Gross wrote:
> On Tue, Oct 26, 2010 at 2:59 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
>> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
>> This results in pskb_expand_head() being used unnecessarily.
>>
>> This add a check in vlan_transfer_features  to catch the ETH_FLAG_TXVLAN
>> flag and set the header length. This requires drivers to add the
>> ETH_FLAG_TXVLAN to vlan_features.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> I think this addresses all of the original problems.  However, I don't
> think that we want to have drivers claim to support vlan offloading as
> a feature for vlan packets.  That implies some type of QinQ
> functionality to me.  In addition, if the vlan device claims to
> support offloading and a second vlan device is stacked on top of it,
> then the two will clobber skb->vlan_tci.  It's probably simpler to
> just keep track of whether vlan offloading is currently enabled so we
> can find out whether it changed.
> 

Agreed. Rather then trying to be clever this is probably the easiest.

--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -334,6 +334,12 @@ Hunk #1, a/net/8021q/vlan.c static void vlan_transfer_features(struct net_device *dev,
        vlandev->features &= ~dev->vlan_features;
        vlandev->features |= dev->features & dev->vlan_features;
        vlandev->gso_max_size = dev->gso_max_size;
+
+       if (dev->features & NETIF_F_HW_VLAN_TX)
+               vlandev->hard_header_len = dev->hard_header_len;
+       else
+               vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
+
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
        vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif


>> ---
>>
>>  net/8021q/vlan.c |   10 ++++++++++
>>  1 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index 05b867e..825011b 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -334,6 +334,16 @@ static void vlan_transfer_features(struct net_device *dev,
>>        vlandev->features &= ~dev->vlan_features;
>>        vlandev->features |= dev->features & dev->vlan_features;
>>        vlandev->gso_max_size = dev->gso_max_size;
>> +
>> +       /* is ETH_FLAGS_TXVLAN being toggled */
>> +       if ((vlandev->features & ETH_FLAG_TXVLAN) ^
>> +           (old_features & ETH_FLAG_TXVLAN)) {
>> +               if (vlandev->features & ETH_FLAG_TXVLAN)
>> +                       vlandev->hard_header_len -= VLAN_HLEN;
>> +               else
>> +                       vlandev->hard_header_len += VLAN_HLEN;
>> +       }
> 
> The correct flag for dev->features is NETIF_F_HW_VLAN_TX.
> ETH_FLAGS_TXVLAN is an ethtool construct (that happens to have the
> same value).
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

