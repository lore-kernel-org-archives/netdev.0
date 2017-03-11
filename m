From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: regression (4.10) - interface remove uevents not generated
Date: Sat, 11 Mar 2017 11:50:48 -0800
Message-ID: <20170311195047.GA10561@outlook.office365.com>
References: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
To: Mantas =?utf-8?Q?Mikul=C4=97nas?= <grawity@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20096.outbound.protection.outlook.com ([40.107.2.96]:15787
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754128AbdCKTvG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Mar 2017 14:51:06 -0500
Content-Disposition: inline
In-Reply-To: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Mantas,

Thank you for the report. Could you try out the attached patch?

On Sat, Mar 11, 2017 at 05:10:22PM +0200, Mantas Mikulėnas wrote:
> Hello,
> 
> It seems that commit 002d8a1a6c11b9b2a8ac615095589111dd52749b ("net:
> skip genenerating uevents for network namespaces that are exiting")
> broke 'remove' uevents for *all* network interfaces, even for those in
> the main/default namespace.
> 
> Other than breaking some of my udev rules, this also causes problems for
> NetworkManager, which apparently relies on those uevents to update its
> interface information cache. (I ended up reverting that commit locally
> just so I could connect to VPNs again.)
> 
> This problem is present in both v4.10.1 and current master
> (v4.11-rc1-290-g434fd6353b4c).
> 
> -- 
> Mantas Mikulėnas <grawity@gmail.com>

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset="koi8-r"
Content-Disposition: attachment; filename="patch"

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 3c4bbec..20c48cf 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -34,6 +34,7 @@ EXPORT_SYMBOL_GPL(net_namespace_list);
 
 struct net init_net = {
 	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
+	.exit_list = LIST_HEAD_INIT(init_net.exit_list),
 };
 EXPORT_SYMBOL(init_net);
 
@@ -286,6 +287,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
 	spin_lock_init(&net->nsid_lock);
+	INIT_LIST_HEAD(&net->exit_list);
 
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);

--y0ulUmNC+osPPQO6--
