From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] net/ehea: bitops work on unsigned longs
Date: Tue, 6 Jan 2009 10:59:51 +1100
Message-ID: <20090106105951.62b0429d.sfr@canb.auug.org.au>
References: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
	<20081230.215156.151347026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:52292 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbZAFAAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 19:00:05 -0500
In-Reply-To: <20081230.215156.151347026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Tue, 30 Dec 2008 21:51:56 -0800 (PST) David Miller <davem@davemloft.net> wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 31 Dec 2008 14:18:53 +1100
> 
> > These changes will avoid several warnings when we change u64 to unsigned
> > long long.
> > 
> > Also, ehea_driver_flags is only used in ehca_main.c
> > 
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > ---
> 
> And also rejected, just like the previous two.
> 
> This is so much worse than the problems we had with
> printing u64's and it's being done as a result to
> the "fix" for that.

How is this worse than anything?  The only thing wrong with this patch is
the commit message ... Lets try this (if this doesn't address your
problems, then assume I am too dense for your original explanation):
---------------------------------------------------------------------------
net/ehea: bitops work on unsigned longs

The flags field of struct ehea_port is only used with test_bit(),
clear_bit() and set_bit() and these interfaces only work on
"unsigned long"s, so change the field to be an "unsigned long".  Also,
this field only has two bits defined for it (0 and 1) so will still be
fine if someone builds this driver for a 32 bit arch (at least as far as
this flags field is concerned).

Also note that ehea_driver_flags is only used in ehca_main.c, so make it
static in there.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ehea/ehea.h      |    3 +--
 drivers/net/ehea/ehea_main.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 9930d5f..6271b94 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -478,7 +478,7 @@ struct ehea_port {
 	int num_add_tx_qps;
 	int num_mcs;
 	int resets;
-	u64 flags;
+	unsigned long flags;
 	u64 mac_addr;
 	u32 logical_port_id;
 	u32 port_speed;
@@ -510,7 +510,6 @@ void ehea_set_ethtool_ops(struct net_device *netdev);
 int ehea_sense_port_attr(struct ehea_port *port);
 int ehea_set_portspeed(struct ehea_port *port, u32 port_speed);
 
-extern u64 ehea_driver_flags;
 extern struct work_struct ehea_rereg_mr_task;
 
 #endif	/* __EHEA_H__ */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a2f1905..e3131ea 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -99,7 +99,7 @@ MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 
 static int port_name_cnt;
 static LIST_HEAD(adapter_list);
-u64 ehea_driver_flags;
+static unsigned long ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
 static DEFINE_MUTEX(dlpar_mem_lock);
 struct ehea_fw_handle_array ehea_fw_handles;
-- 
1.6.0.5


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
