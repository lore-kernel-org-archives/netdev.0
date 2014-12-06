From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Fri, 05 Dec 2014 18:46:23 -0800
Message-ID: <54826DFF.6090906@gmail.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com> <54815883.80909@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com> <E4CD12F19ABA0C4D8729E087A761DC3505D8436D@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:60329 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaLFCq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:46:56 -0500
Received: by mail-ob0-f181.google.com with SMTP id gq1so1488670obb.12
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:46:56 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D8436D@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2014 05:04 PM, Arad, Ronen wrote:
> I have another case of propagation which is not covered by the proposed patch.
> A recent patch introduced default_pvid attribute for a bridge (so far supported only via sysfs and not via netlink).
> When a port joins a bridge, it inherits a PVID from the default_pvid of the bridge.
> The bridge driver propagates that to the newly created net_bridge_port. This is done in br_vlan.c:
>
> int nbp_vlan_init(struct net_bridge_port *p)
> {
> 	int rc = 0;
>
> 	if (p->br->default_pvid) {
> 		rc = nbp_vlan_add(p, p->br->default_pvid,
> 				  BRIDGE_VLAN_INFO_PVID |
> 				  BRIDGE_VLAN_INFO_UNTAGGED);
> 	}
>
> 	return rc;
> }
>
> When L2 switching is offloaded to the HW, this PVID setting need to be propagated. However, it does not come via ndo_bridge_setlink. The proposed propagation at br_setlink or an up level one at rtnetlink are not capable of handling this case.
> One possible way for handling that is to replace the call to nbp_vlan_add with a call to a new function let's say
> int br_propagate_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
> This function will compose a netlink message with VLAN filtering information (i.e. AF_SPEC with VLAN_INFO) and call br_setlink - leveraging the offload support proposed by Roopa.
>

No, we shouldn't be crafting netlink messages in the kernel just
re-inject them into an interface. Really the setlink/dellink interface
should be cleaned up so that it no longer consumes raw netlink messages.

Then either (a) add another parameter to the setlink ops or (b) create
a new op for it.

I think cleaning up the setlink/dellink hooks is on the TBD list
already.


> If this is an acceptable course of action, I could work on such patch.
>
>

[...]

Thanks,
John

-- 
John Fastabend         Intel Corporation
