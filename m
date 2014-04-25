From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net v2] bridge: Handle IFLA_ADDRESS correctly when
 creating bridge device
Date: Fri, 25 Apr 2014 17:01:18 +0900
Message-ID: <1398412878.3920.7.camel@ubuntu-vm-makita>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
	<CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
	<1398341177.4171.11.camel@ubuntu-vm-makita>
	<1398341787.4171.16.camel@ubuntu-vm-makita>
	<20140424113827.6d27ec5b@nehalam.linuxnetplumber.net>
	<1398412451.3920.3.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Gundersen <teg@jklm.no>, netdev <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>,
	"C. R. Oldham" <cr@saltstack.com>
To: "David S. Miller" <davem@davemloft.net>, Stephen Hemminger
	<stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1398412451.3920.3.camel@ubuntu-vm-makita>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When bridge device is created with IFLA_ADDRESS, we are not calling
br_stp_change_bridge_id(), which leads to incorrect local fdb
management and bridge id calculation, and prevents us from receiving
frames on the bridge device.

Reported-by: Tom Gundersen <teg@jklm.no>
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---

v1->v2:
- Remove variable "err" and directly return register_netdevice().

 net/bridge/br_netlink.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e74b6d53..e8844d9 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -445,6 +445,20 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int br_dev_newlink(struct net *src_net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	if (tb[IFLA_ADDRESS]) {
+		spin_lock_bh(&br->lock);
+		br_stp_change_bridge_id(br, nla_data(tb[IFLA_ADDRESS]));
+		spin_unlock_bh(&br->lock);
+	}
+
+	return register_netdevice(dev);
+}
+
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
 	struct net_port_vlans *pv;
@@ -473,6 +487,7 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.priv_size	= sizeof(struct net_bridge),
 	.setup		= br_dev_setup,
 	.validate	= br_validate,
+	.newlink	= br_dev_newlink,
 	.dellink	= br_dev_delete,
 };
 
-- 
1.8.1.2
