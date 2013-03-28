From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Crash with NULL pointer dereference in bond_handle_frame
 in -rt (possibly mainline)
Date: Thu, 28 Mar 2013 10:29:52 -0700
Message-ID: <1364491792.15753.47.camel@edumazet-glaptop>
References: <1364490997.6345.237.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364490997.6345.237.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-28 at 13:16 -0400, Steven Rostedt wrote:
> Hi,
> 
> I'm currently debugging a crash in an old 3.0-rt kernel that one of our
> customers is seeing. The bug happens with a stress test that loads and
> unloads the bonding module in a loop (I don't know all the details as
> I'm not the one that is directly interacting with the customer). But the
> bug looks to be something that may still be present and possibly present
> in mainline too. It will just be much harder to trigger it in mainline.
> 
> In -rt, interrupts are threads, and can schedule in and out just like
> any other thread. Note, mainline now supports interrupt threads so this
> may be easily reproducible in mainline as well. I don't have the ability
> to tell the customer to try mainline or other kernels, so my hands are
> somewhat tied to what I can do.
> 
> But according to a core dump, I tracked down that the eth irq thread
> crashed in bond_handle_frame() here:
> 
> 	slave = bond_slave_get_rcu(skb->dev);
> 	bond = slave->bond; <--- BUG
> 
> 
> the slave returned was NULL and accessing slave->bond caused a NULL
> pointer dereference.
> 
> Looking at the code that unregisters the handler:
> 
> void netdev_rx_handler_unregister(struct net_device *dev)
> {
> 
>         ASSERT_RTNL();
>         RCU_INIT_POINTER(dev->rx_handler, NULL);
>         RCU_INIT_POINTER(dev->rx_handler_data, NULL);
> }
> 
> Which is basically:
> 	dev->rx_handler = NULL;
> 	dev->rx_handler_data = NULL;
> 
> And looking at __netif_receive_skb() we have:
> 
>         rx_handler = rcu_dereference(skb->dev->rx_handler);
>         if (rx_handler) {
>                 if (pt_prev) {
>                         ret = deliver_skb(skb, pt_prev, orig_dev);
>                         pt_prev = NULL;
>                 }
>                 switch (rx_handler(&skb)) {
> 
> My question to all of you is, what stops this interrupt from happening
> while the bonding module is unloading?  What happens if the interrupt
> triggers and we have this:
> 
> 
> 	CPU0			CPU1
> 	----			----
>   rx_handler = skb->dev->rx_handler
> 
> 			netdev_rx_handler_unregister() {
> 			   dev->rx_handler = NULL;
> 			   dev->rx_handler_data = NULL;
> 
>   rx_handler()
>    bond_handle_frame() {
>     slave = skb->dev->rx_handler;
>     bond = slave->bond; <-- NULL pointer dereference!!!
> 
> 
> What protection am I missing in the bond release handler that would
> prevent the above from happening?

Nothing :(

bug introduced in commit 35d48903e9781975e823b359ee85c257c9ff5c1c
(bonding: fix rx_handler locking)

CC Jiri

Fix seems simple :

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6bbd90e..7956ca5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1457,6 +1457,8 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	*pskb = skb;
 
 	slave = bond_slave_get_rcu(skb->dev);
+	if (!slave)
+		return ret;
 	bond = slave->bond;
 
 	if (bond->params.arp_interval)
