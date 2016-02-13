From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH RFC 2/3] net: bridge: set forwarding state on port removal
Date: Sat, 13 Feb 2016 22:37:38 +0200
Message-ID: <20160213203738.GB17193@colbert.idosch.org>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1455312860-24666-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455312860-24666-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Feb 12, 2016 at 11:34:19PM IST, vivien.didelot@savoirfairelinux.com wrote:

Hi Vivien,

>When a port leaves a bridge, the bridge layer puts its STP state to
>Disabled. If the port is part of an hardware switch, the mode needs to
>be set to Forwarding in order to restore communication with the CPU.
>
>Call br_set_state() in del_nbp(), which only affects switchdev users.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---

If you have a LAG device in the bridge and one of the ports leaves the
LAG, then the bridge's teardown sequence isn't invoked and you need to
do the cleanup yourself, by calling your dsa_slave_bridge_port_leave()
function (just an example, I know you don't currently support this).

With this change, you'll have to call both the
dsa_slave_bridge_port_leave() function and dsa_slave_stp_update()
instead of always calling the same one when leaving a bridge.

Also, I think this kind of things should be done by drivers, as it's
specific to them. For example, in the case of a physical port, this
wouldn't benefit mlxsw at all, as STP state is a per-VLAN setting and
since VLANs were already flushed in nbp_vlan_flush(), then nothing would
happen.

Thanks!

> net/bridge/br_if.c | 5 +++++
> 1 file changed, 5 insertions(+)
>
>diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>index c367b3e..93e7b24 100644
>--- a/net/bridge/br_if.c
>+++ b/net/bridge/br_if.c
>@@ -251,6 +251,11 @@ static void del_nbp(struct net_bridge_port *p)
> 
> 	nbp_vlan_flush(p);
> 	br_fdb_delete_by_port(br, p, 0, 1);
>+
>+	/* If the port is part of an hardware switch, set its STP state to
>+	 * forwarding to restore communication with the CPU port.
>+	 */
>+	br_set_state(p, BR_STATE_FORWARDING);
> 	switchdev_deferred_process();
> 
> 	nbp_update_port_count(br);
>-- 
>2.7.1
>
