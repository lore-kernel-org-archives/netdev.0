From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 06:01:22 -0700
Message-ID: <1364562082.5113.16.camel@edumazet-glaptop>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
	 <20130329094856.GB1677@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130329094856.GB1677@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

On Fri, 2013-03-29 at 10:48 +0100, Jiri Pirko wrote:

> Hmm. I think that this might be issue introduced by:
> commit a9b3cd7f323b2e57593e7215362a7b02fc933e3a
> Author: Stephen Hemminger <shemminger@vyatta.com>
> Date:   Mon Aug 1 16:19:00 2011 +0000
> 
>     rcu: convert uses of rcu_assign_pointer(x, NULL) to RCU_INIT_POINTER
> 
> 
> Because, if rcu_dereference(dev->rx_handler) is null,
> rcu_dereference(dev->rx_handler_data) is never done. Therefore I believe
> we are hitting following scenario:
> 
> 
>    CPU0				CPU1
>    ----				----
>   			    dev->rx_handler_data = NULL
>  rcu_read_lock()
>  			    dev->rx_handler = NULL
> 
> 
> CPU0 will see rx_handler set and yet, rx_handler_data nulled. Write
> barrier in rcu_assign_pointer() might prevent this reorder from happening.
> Therefore I suggest:
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0caa38e..c16b829 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3332,8 +3332,8 @@ void netdev_rx_handler_unregister(struct net_device *dev)
>  {
>  
>  	ASSERT_RTNL();
> -	RCU_INIT_POINTER(dev->rx_handler, NULL);
> -	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
> +	rcu_assign_pointer(dev->rx_handler, NULL);
> +	rcu_assign_pointer(dev->rx_handler_data, NULL);
>  }
>  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>  
> 

Nope this changes nothing at all.

However, we can fix the bug in a different way, if we want to avoid a
test in fast path.

With following patch, we can make sure that a reader seeing a non NULL
rx_handler has a guarantee to see a non NULL rx_handler_data

Thanks

[PATCH] net: add a synchronize_net() in netdev_rx_handler_unregister()

commit 35d48903e97819 (bonding: fix rx_handler locking) added a race
in bonding driver, reported by Steven Rostedt who did a very good
diagnosis :

<quoting Steven>

I'm currently debugging a crash in an old 3.0-rt kernel that one of our
customers is seeing. The bug happens with a stress test that loads and
unloads the bonding module in a loop (I don't know all the details as
I'm not the one that is directly interacting with the customer). But the
bug looks to be something that may still be present and possibly present
in mainline too. It will just be much harder to trigger it in mainline.

In -rt, interrupts are threads, and can schedule in and out just like
any other thread. Note, mainline now supports interrupt threads so this
may be easily reproducible in mainline as well. I don't have the ability
to tell the customer to try mainline or other kernels, so my hands are
somewhat tied to what I can do.

But according to a core dump, I tracked down that the eth irq thread
crashed in bond_handle_frame() here:

        slave = bond_slave_get_rcu(skb->dev);
        bond = slave->bond; <--- BUG


the slave returned was NULL and accessing slave->bond caused a NULL
pointer dereference.

Looking at the code that unregisters the handler:

void netdev_rx_handler_unregister(struct net_device *dev)
{

        ASSERT_RTNL();
        RCU_INIT_POINTER(dev->rx_handler, NULL);
        RCU_INIT_POINTER(dev->rx_handler_data, NULL);
}

Which is basically:
        dev->rx_handler = NULL;
        dev->rx_handler_data = NULL;

And looking at __netif_receive_skb() we have:

        rx_handler = rcu_dereference(skb->dev->rx_handler);
        if (rx_handler) {
                if (pt_prev) {
                        ret = deliver_skb(skb, pt_prev, orig_dev);
                        pt_prev = NULL;
                }
                switch (rx_handler(&skb)) {

My question to all of you is, what stops this interrupt from happening
while the bonding module is unloading?  What happens if the interrupt
triggers and we have this:


        CPU0                    CPU1
        ----                    ----
  rx_handler = skb->dev->rx_handler

                        netdev_rx_handler_unregister() {
                           dev->rx_handler = NULL;
                           dev->rx_handler_data = NULL;

  rx_handler()
   bond_handle_frame() {
    slave = skb->dev->rx_handler;
    bond = slave->bond; <-- NULL pointer dereference!!!


What protection am I missing in the bond release handler that would
prevent the above from happening?

</quoting Steven>

We can fix bug this in two ways. First is adding a test in
bond_handle_frame() and others to check if rx_handler_data is NULL.

A second way is adding a synchronize_net() in
netdev_rx_handler_unregister() to make sure that a rcu protected reader
has the guarantee to see a non NULL rx_handler_data.

The second way is better as it avoids an extra test in fast path.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: Paul E. McKenney <paulmck@us.ibm.com>
---
 net/core/dev.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index b13e5c7..56932a4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3314,6 +3314,7 @@ int netdev_rx_handler_register(struct net_device *dev,
 	if (dev->rx_handler)
 		return -EBUSY;
 
+	/* Note: rx_handler_data must be set before rx_handler */
 	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
 	rcu_assign_pointer(dev->rx_handler, rx_handler);
 
@@ -3334,6 +3335,11 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 
 	ASSERT_RTNL();
 	RCU_INIT_POINTER(dev->rx_handler, NULL);
+	/* a reader seeing a non NULL rx_handler in a rcu_read_lock()
+	 * section has a guarantee to see a non NULL rx_handler_data
+	 * as well.
+	 */
+	synchronize_net();
 	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
