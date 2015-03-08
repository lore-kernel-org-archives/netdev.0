From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vlan: allow changing VLAN id and protocol
Date: Sun, 8 Mar 2015 11:06:24 -0700
Message-ID: <20150308110624.5ab6f662@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:38021 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998AbbCHSGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 14:06:33 -0400
Received: by pabrd3 with SMTP id rd3so42776527pab.5
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 11:06:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The VLAN netlink interface allows changing the ID and protocol of an existing
VLAN, but it was being ignored. Move the initialization of the proto and
id into the change function to fix that.

Example of the problem:
  # modprobe dummy
  # ip li set dev dummy0 up
  # ip li add link dummy0 name dummy0.10 type vlan id 100
  # ip li set dummy0.10 type vlan id 111
  # ip -d li show dev dummy0.10
19: dummy0.10@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT 
    link/ether be:d3:7c:7f:86:18 brd ff:ff:ff:ff:ff:ff
    vlan id 100 <REORDER_HDR> 
            ^^^ should be 111

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/8021q/vlan_netlink.c	2015-03-08 09:38:48.519551748 -0700
+++ b/net/8021q/vlan_netlink.c	2015-03-08 09:42:16.332512289 -0700
@@ -89,10 +89,30 @@ static int vlan_validate(struct nlattr *
 static int vlan_changelink(struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct ifla_vlan_flags *flags;
 	struct ifla_vlan_qos_mapping *m;
 	struct nlattr *attr;
-	int rem;
+	__be16 proto;
+	int err, rem;
+	u16 id;
+
+	if (data[IFLA_VLAN_PROTOCOL])
+		proto = nla_get_be16(data[IFLA_VLAN_PROTOCOL]);
+	else
+		proto = htons(ETH_P_8021Q);
+
+	if (data[IFLA_VLAN_ID])
+		id = nla_get_u16(data[IFLA_VLAN_ID]);
+	else
+		id = vlan->vlan_id;
+
+	err = vlan_check_real_dev(vlan->real_dev, proto, id);
+	if (err < 0)
+		return err;
+
+	vlan->vlan_id = id;
+	vlan->vlan_proto = proto;
 
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
@@ -118,7 +138,6 @@ static int vlan_newlink(struct net *src_
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
-	__be16 proto;
 	int err;
 
 	if (!data[IFLA_VLAN_ID])
@@ -130,20 +149,9 @@ static int vlan_newlink(struct net *src_
 	if (!real_dev)
 		return -ENODEV;
 
-	if (data[IFLA_VLAN_PROTOCOL])
-		proto = nla_get_be16(data[IFLA_VLAN_PROTOCOL]);
-	else
-		proto = htons(ETH_P_8021Q);
-
-	vlan->vlan_proto = proto;
-	vlan->vlan_id	 = nla_get_u16(data[IFLA_VLAN_ID]);
 	vlan->real_dev	 = real_dev;
 	vlan->flags	 = VLAN_FLAG_REORDER_HDR;
 
-	err = vlan_check_real_dev(real_dev, vlan->vlan_proto, vlan->vlan_id);
-	if (err < 0)
-		return err;
-
 	if (!tb[IFLA_MTU])
 		dev->mtu = real_dev->mtu;
 	else if (dev->mtu > real_dev->mtu)
