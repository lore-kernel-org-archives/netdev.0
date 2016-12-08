From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next] openvswitch: fix VxLAN-gpe port can't be
 created in ovs compat mode
Date: Thu, 8 Dec 2016 18:57:51 +0800
Message-ID: <20161208105750.GA14898@cran64.bj.intel.com>
References: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
 <20161208095401.3e4054c9@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@ovn.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:45272 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751862AbcLHLHf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 06:07:35 -0500
Content-Disposition: inline
In-Reply-To: <20161208095401.3e4054c9@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 09:54:00AM +0100, Jiri Benc wrote:
> On Thu,  8 Dec 2016 16:20:10 +0800, Yi Yang wrote:
> > In ovs compat mode, ovs won't use LWT in current kernel, this is to
> > make sure ovs can work on the old kernels, Linux kernel v4.7 includes
> > VxLAN-gpe support but many Linux distributions' kernels are odler than
> > v4.7, this fix will ensure that ovs can create VxLAN-gpe port correctly
> > on old kernels, it has been verified on Ubuntu 16.04 x86_64 with Linux
> > kernel 4.4.0-53-generic.
> 
> NAK. We do have a way to configure this and that's rtnetlink. Open
> vSwitch should use that to configure tunnels. Out of tree modules are
> on their own. Upstream kernel does not accommodate out of tree modules.
>
Jiri, this has used rtnetlink to confgiure, te below is my test code in ovs.
As Pravin mentioned, in compat mode, ovs won't use current in-kernel
module which is vxlan in upstream kernel, but ovs has its own vport_vxlan
module for this, it has different behaviour from LWT in upstream kernel.
If you try this in the kernels below v4.7, you will clearly know this.

ovs will port this patch into the below files in ovs soure code
datapath/linux/compat/include/linux/openvswitch.h and datapath/vport-vxlan.c once it is accepted,this is ovs upstream process, if Linux kernel doesn't include this, ovs won't accept it.

So ovs out of tree modules need to adapt to upstream kernel, any
kernel-related changes must be accepted by Linux kernel at first. Pravin
is a dedicated person doing such work, your L3 patches merged into
net-next will be ported into ovs out of tree modules by Pravin in the
same way.

diff --git a/lib/dpif-netlink.c b/lib/dpif-netlink.c
index 0d03334..7d8a0f4 100644
--- a/lib/dpif-netlink.c
+++ b/lib/dpif-netlink.c
@@ -1006,7 +1006,11 @@ netdev_vxlan_create(struct netdev *netdev)
     nl_msg_put_string(&request, IFLA_IFNAME, name);
     nl_msg_put_u32(&request, IFLA_MTU, UINT16_MAX);
     linkinfo_off = nl_msg_start_nested(&request, IFLA_LINKINFO);
+#ifdef USE_UPSTREAM_TUNNEL
         nl_msg_put_string(&request, IFLA_INFO_KIND, "vxlan");
+#else
+        nl_msg_put_string(&request, IFLA_INFO_KIND, "ovs_vxlan");
+#endif
         infodata_off = nl_msg_start_nested(&request, IFLA_INFO_DATA);
             nl_msg_put_u8(&request, IFLA_VXLAN_LEARNING, 0);
             nl_msg_put_u8(&request, IFLA_VXLAN_COLLECT_METADATA, 1);
