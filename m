From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [RFC PATCH net-next 4/5] bridge: vlan lwt and dst_metadata
 netlink support
Date: Mon, 23 Jan 2017 00:22:00 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F93D495F16@HASMSX110.ger.corp.intel.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
 <1484977616-1541-5-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
        "tgraf@suug.ch" <tgraf@suug.ch>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "pshelar@ovn.org" <pshelar@ovn.org>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "hadi@mojatatu.com" <hadi@mojatatu.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40160 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdAWAWF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 19:22:05 -0500
In-Reply-To: <1484977616-1541-5-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Roopa,

Two minor comments:

The parameter br is not used in the br_add_vlan_tunnel_info() method, it should be removed:

+static int br_add_vlan_tunnel_info(struct net_bridge *br,
+				   struct net_bridge_port *p, int cmd,
+				   u16 vid, u32 tun_id)
+{
+	int err;
+
+	switch (cmd) {
+	case RTM_SETLINK:
+		if (p) {
+			/* if the MASTER flag is set this will act on the global
+			 * per-VLAN entry as well
+			 */
+			err = nbp_vlan_tunnel_info_add(p, vid, tun_id);
+			if (err)
+				break;
+		} else {
+			return -EINVAL;
+		}
+
+		break;
+
+	case RTM_DELLINK:
+		if (p)
+			nbp_vlan_tunnel_info_delete(p, vid);
+		else
+			return -EINVAL;
+		break;
+	}
+
+	return 0;
+}
+

The parameter br is used inside br_process_vlan_tunnel_info() only in the two 
Cases, when br_add_vlan_tunnel_info() is invoked. Since we saw earlier that it should be removed from br_add_vlan_tunnel_info(), it should also be removed from br_process_vlan_tunnel_info() as it is not needed anymore:

+static int br_process_vlan_tunnel_info(struct net_bridge *br,
+				       struct net_bridge_port *p, int cmd,
+				       struct vtunnel_info *tinfo_curr,
+				       struct vtunnel_info *tinfo_last) {
+	int t, v;
+	int err;
+
+	if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+		if (tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+			return -EINVAL;
+		memcpy(tinfo_last, tinfo_curr, sizeof(struct vtunnel_info));
+	} else if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_END) {
+		if (!(tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN))
+			return -EINVAL;
+		if ((tinfo_curr->vid - tinfo_last->vid) !=
+		    (tinfo_curr->tunid - tinfo_last->tunid))
+			return -EINVAL;
+		/* XXX: tun id and vlan id attrs must be same
+		 */
+		t = tinfo_last->tunid;
+		for (v = tinfo_last->vid; v <= tinfo_curr->vid; v++) {
+			err = br_add_vlan_tunnel_info(br, p, cmd,
+							  v, t);
+			if (err)
+				return err;
+			t++;
+		}
+		memset(tinfo_last, 0, sizeof(struct vtunnel_info));
+		memset(tinfo_curr, 0, sizeof(struct vtunnel_info));
+	} else {
+		err = br_add_vlan_tunnel_info(br, p, cmd,
+					      tinfo_curr->vid,
+					      tinfo_curr->tunid);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+

Regards,
Rami Rosen
