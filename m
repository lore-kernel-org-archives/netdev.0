From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Wed, 01 Jul 2015 11:36:15 +0200
Message-ID: <5593B48F.2060403@iogearbox.net>
References: <20150630225255.GA22529@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59027 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbbGAJgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 05:36:25 -0400
In-Reply-To: <20150630225255.GA22529@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason,

On 07/01/2015 12:52 AM, Jason Gunthorpe wrote:
> It turns out the policy was defined but never actually checked,
> so lets check it.
>
> Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")

I would argue that the actual commit would be ...

Fixes: c02db8c6290b ("rtnetlink: make SR-IOV VF interface symmetric")

... since in ebc08a6f47ee, these members were part of ifla_policy[]
which has been validated (if we ignore the fact that it was NLA_BINARY).

So, commit c02db8c6290b moved it into a nested attribute (IFLA_VF_INFO)
where we indeed don't do further validation. Imho, we should pass the
parsed attribute table from nla_parse_nested() down into do_setvfinfo(),
something like the below; I can give it a test run on my ixgbe.

Cheers,
Daniel

  net/core/rtnetlink.c | 184 ++++++++++++++++++++++++++-------------------------
  1 file changed, 94 insertions(+), 90 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 01ced4a..7d63551 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1328,10 +1328,6 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
  	[IFLA_INFO_SLAVE_DATA]	= { .type = NLA_NESTED },
  };

-static const struct nla_policy ifla_vfinfo_policy[IFLA_VF_INFO_MAX+1] = {
-	[IFLA_VF_INFO]		= { .type = NLA_NESTED },
-};
-
  static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
  	[IFLA_VF_MAC]		= { .len = sizeof(struct ifla_vf_mac) },
  	[IFLA_VF_VLAN]		= { .len = sizeof(struct ifla_vf_vlan) },
@@ -1488,96 +1484,98 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
  	return 0;
  }

-static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
+static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
  {
-	int rem, err = -EINVAL;
-	struct nlattr *vf;
  	const struct net_device_ops *ops = dev->netdev_ops;
+	int err = -EINVAL;

-	nla_for_each_nested(vf, attr, rem) {
-		switch (nla_type(vf)) {
-		case IFLA_VF_MAC: {
-			struct ifla_vf_mac *ivm;
-			ivm = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_mac)
-				err = ops->ndo_set_vf_mac(dev, ivm->vf,
-							  ivm->mac);
-			break;
-		}
-		case IFLA_VF_VLAN: {
-			struct ifla_vf_vlan *ivv;
-			ivv = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_vlan)
-				err = ops->ndo_set_vf_vlan(dev, ivv->vf,
-							   ivv->vlan,
-							   ivv->qos);
-			break;
-		}
-		case IFLA_VF_TX_RATE: {
-			struct ifla_vf_tx_rate *ivt;
-			struct ifla_vf_info ivf;
-			ivt = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_get_vf_config)
-				err = ops->ndo_get_vf_config(dev, ivt->vf,
-							     &ivf);
-			if (err)
-				break;
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_rate)
-				err = ops->ndo_set_vf_rate(dev, ivt->vf,
-							   ivf.min_tx_rate,
-							   ivt->rate);
-			break;
-		}
-		case IFLA_VF_RATE: {
-			struct ifla_vf_rate *ivt;
-			ivt = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_rate)
-				err = ops->ndo_set_vf_rate(dev, ivt->vf,
-							   ivt->min_tx_rate,
-							   ivt->max_tx_rate);
-			break;
-		}
-		case IFLA_VF_SPOOFCHK: {
-			struct ifla_vf_spoofchk *ivs;
-			ivs = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_spoofchk)
-				err = ops->ndo_set_vf_spoofchk(dev, ivs->vf,
-							       ivs->setting);
-			break;
-		}
-		case IFLA_VF_LINK_STATE: {
-			struct ifla_vf_link_state *ivl;
-			ivl = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_link_state)
-				err = ops->ndo_set_vf_link_state(dev, ivl->vf,
-								 ivl->link_state);
-			break;
-		}
-		case IFLA_VF_RSS_QUERY_EN: {
-			struct ifla_vf_rss_query_en *ivrssq_en;
+	if (tb[IFLA_VF_MAC]) {
+		struct ifla_vf_mac *ivm = nla_data(tb[IFLA_VF_MAC]);

-			ivrssq_en = nla_data(vf);
-			err = -EOPNOTSUPP;
-			if (ops->ndo_set_vf_rss_query_en)
-				err = ops->ndo_set_vf_rss_query_en(dev,
-							    ivrssq_en->vf,
-							    ivrssq_en->setting);
-			break;
-		}
-		default:
-			err = -EINVAL;
-			break;
-		}
-		if (err)
-			break;
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_mac)
+			err = ops->ndo_set_vf_mac(dev, ivm->vf,
+						  ivm->mac);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_VLAN]) {
+		struct ifla_vf_vlan *ivv = nla_data(tb[IFLA_VF_VLAN]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_vlan)
+			err = ops->ndo_set_vf_vlan(dev, ivv->vf, ivv->vlan,
+						   ivv->qos);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_TX_RATE]) {
+		struct ifla_vf_tx_rate *ivt = nla_data(tb[IFLA_VF_TX_RATE]);
+		struct ifla_vf_info ivf;
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_get_vf_config)
+			err = ops->ndo_get_vf_config(dev, ivt->vf, &ivf);
+		if (err < 0)
+			return err;
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_rate)
+			err = ops->ndo_set_vf_rate(dev, ivt->vf,
+						   ivf.min_tx_rate,
+						   ivt->rate);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_RATE]) {
+		struct ifla_vf_rate *ivt = nla_data(tb[IFLA_VF_RATE]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_rate)
+			err = ops->ndo_set_vf_rate(dev, ivt->vf,
+						   ivt->min_tx_rate,
+						   ivt->max_tx_rate);
+		if (err < 0)
+			return err;
  	}
+
+	if (tb[IFLA_VF_SPOOFCHK]) {
+		struct ifla_vf_spoofchk *ivs = nla_data(tb[IFLA_VF_SPOOFCHK]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_spoofchk)
+			err = ops->ndo_set_vf_spoofchk(dev, ivs->vf,
+						       ivs->setting);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_LINK_STATE]) {
+		struct ifla_vf_link_state *ivl = nla_data(tb[IFLA_VF_LINK_STATE]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_link_state)
+			err = ops->ndo_set_vf_link_state(dev, ivl->vf,
+							 ivl->link_state);
+		if (err < 0)
+			return err;
+	}
+
+	if (tb[IFLA_VF_RSS_QUERY_EN]) {
+		struct ifla_vf_rss_query_en *ivrssq_en =
+					nla_data(tb[IFLA_VF_RSS_QUERY_EN]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_rss_query_en)
+			err = ops->ndo_set_vf_rss_query_en(dev, ivrssq_en->vf,
+							   ivrssq_en->setting);
+		if (err < 0)
+			return err;
+	}
+
  	return err;
  }

@@ -1773,14 +1771,20 @@ static int do_setlink(const struct sk_buff *skb,
  	}

  	if (tb[IFLA_VFINFO_LIST]) {
+		struct nlattr *vfinfo[IFLA_VF_MAX + 1];
  		struct nlattr *attr;
  		int rem;
+
  		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
  			if (nla_type(attr) != IFLA_VF_INFO) {
  				err = -EINVAL;
  				goto errout;
  			}
-			err = do_setvfinfo(dev, attr);
+			err = nla_parse_nested(vfinfo, IFLA_VF_MAX, attr,
+					       ifla_vf_policy);
+			if (err < 0)
+				goto errout;
+			err = do_setvfinfo(dev, vfinfo);
  			if (err < 0)
  				goto errout;
  			status |= DO_SETLINK_NOTIFY;
-- 
1.9.3
