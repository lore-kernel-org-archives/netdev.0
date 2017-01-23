From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 09:08:05 +0100
Message-ID: <20170123080805.GB1831@nanopsycho.orion>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33550 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAWIII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 03:08:08 -0500
Received: by mail-wm0-f66.google.com with SMTP id r144so24467166wme.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 00:08:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 21, 2017 at 06:46:51AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>High level summary:
>lwt and dst_metadata/collect_metadata have enabled vxlan l3 deployments
>to use a single vxlan netdev for multiple vnis eliminating the scalability
>problem with using a single vxlan netdev per vni. This series tries to
>do the same for vxlan netdevs in pure l2 bridged networks.
>Use-case/deployment and details are below.
>
>Deployment scerario details:
>As we know VXLAN is used to build layer 2 virtual networks across the
>underlay layer3 infrastructure. A VXLAN tunnel endpoint (VTEP)
>originates and terminates VXLAN tunnels. And a VTEP can be a TOR switch
>or a vswitch in the hypervisor. This patch series mainly
>focuses on the TOR switch configured as a Vtep. Vxlan segment ID (vni)
>along with vlan id is used to identify layer 2 segments in a vxlan
>overlay network. Vxlan bridging is the function provided by Vteps to terminate
>vxlan tunnels and map the vxlan vni to traditional end host vlan. This is
>covered in the "VXLAN Deployment Scenarios" in sections 6 and 6.1 in RFC 7348.
>To provide vxlan bridging function, a vtep has to map vlan to a vni. The rfc
>says that the ingress VTEP device shall remove the IEEE 802.1Q VLAN tag in
>the original Layer 2 packet if there is one before encapsulating the packet
>into the VXLAN format to transmit it through the underlay network. The remote
>VTEP devices have information about the VLAN in which the packet will be
>placed based on their own VLAN-to-VXLAN VNI mapping configurations.
>
>Existing solution:
>Without this patch series one can deploy such a vtep configuration by
>by adding the local ports and vxlan netdevs into a vlan filtering bridge.
>The local ports are configured as trunk ports carrying all vlans.
>A vxlan netdev per vni is added to the bridge. Vlan mapping to vni is
>achieved by configuring the vlan as pvid on the corresponding vxlan netdev.
>The vxlan netdev only receives traffic corresponding to the vlan it is mapped
>to. This configuration maps traffic belonging to a vlan to the corresponding
>vxlan segment.
>
>          -----------------------------------
>         |              bridge               |
>         |                                   |
>          -----------------------------------
>            |100,200       |100 (pvid)    |200 (pvid)
>            |              |              |
>           swp1          vxlan1000      vxlan2000
>                    
>This provides the required vxlan bridging function but poses a
>scalability problem with using a single vxlan netdev for each vni.
>
>Solution in this patch series:
>The Goal is to use a single vxlan device to carry all vnis similar
>to the vxlan collect metadata mode but vxlan driver still carrying all
>the forwarding information.
>- vxlan driver changes:
>    - enable collect metadata mode device to be used with learning,
>      replication, fdb
>    - A single fdb table hashed by (mac, vni)
>    - rx path already has the vni
>    - tx path expects a vni in the packet with dst_metadata and vxlan
>      driver has all the forwarding information for the vni in the
>      dst_metadata.
>
>- Bridge driver changes: per vlan LWT and dst_metadata support:
>    - Our use case is vxlan and 1-1 mapping between vlan and vni, but I have
>      kept the api generic for any tunnel info
>    - Uapi to configure/unconfigure/dump per vlan tunnel data
>    - new bridge port flag to turn this feature on/off. off by default
>    - ingress hook:
>        - if port is a lwt tunnel port, use tunnel info in
>          attached dst_metadata to map it to a local vlan
>    - egress hook:
>        - if port is a lwt tunnel port, use tunnel info attached to vlan
>          to set dst_metadata on the skb
>
>Other approaches tried and vetoed:
>- tc vlan push/pop and tunnel metadata dst:
>    - posses a tc rule scalability problem (2 rules per vni)

Why it is a problem?


>    - cannot handle the case where a packet needs to be replicated to
>      multiple vxlan remote tunnel end-points.. which the vxlan driver
>      can do today by having multiple remote destinations per fdb.

Can't you just extend the tc to support this?


To me, looks like the tc is the correct place to hangle this. Then, the
user can use it for multiple cases of forwarding, including bridge,
tc-mirred, ovs and others. Putting this in bridge somehow seems wrong in
this light. Also, the bridge code is polluted enough as it is. I this we
should be super-picky to add another code there.

Can you please elaborate more why can't have this as a re-usable TC solution?


Thanks.
