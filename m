From: Shaw <shawvrana@gmail.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Wed, 26 Apr 2006 17:14:57 -0700
Message-ID: <7bb8b8de0604261714h2471420xa06bb6639ddb6cea@mail.gmail.com>
References: <1145578214.3195.6.camel@rh4>
	 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
	 <20060421024024.GA29644@gondor.apana.org.au>
	 <1145582676.3195.18.camel@rh4>
	 <20060421132758.GA26161@gospo.rdu.redhat.com>
	 <1145633287.3194.10.camel@rh4>
	 <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
	 <1145646031.3843.5.camel@rh4>
	 <bdfc5d6e0604211346n50b15f56g4ebc2fe5fe88a63a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_9816_32757967.1146096897566"
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.201]:33146 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S964819AbWD0AO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 20:14:58 -0400
Received: by nz-out-0102.google.com with SMTP id 40so1674454nzk
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 17:14:57 -0700 (PDT)
To: "Andy Gospodarek" <andy@greyhouse.net>
In-Reply-To: <bdfc5d6e0604211346n50b15f56g4ebc2fe5fe88a63a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_9816_32757967.1146096897566
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 4/21/06, Andy Gospodarek <andy@greyhouse.net> wrote:
> On 4/21/06, Michael Chan <mchan@broadcom.com> wrote:
> > On Fri, 2006-04-21 at 16:01 -0400, Andy Gospodarek wrote:
> >
> > > I just hate to see extra resources used to solve problems that good
> > > coding can solve (not that my suggestion is necessarily a 'good' one)=
,
> > > so I was trying to think of a way to resolve this without explicitly
> > > adding another workqueue.
> >
> > If you don't want to add another workqueue, then look at tg3, bnx2, and
> > one of the smc drivers on how to effectively wait for the driver's
> > workqueue task to finish without deadlocking with linkwatch_event.
> >
>
> I agree 100%.  I just hope others can manage to figure that out too.

Ok, here's another attempt.  The goal here is to serialize attempts to
clean the tx and rx buffers, and ensure that e1000_close is called
after the tx_timeout_task has completed running and/or that the task
is safe to run after e1000_close hasrun.

I'm concerned about the addition of the netif_running check to
e1000_down.  While something like this is needed, I'm not familiar
enough w/ the code to know if this is okay.
All explanations and comments are greatly appreciated.

Thanks,
Shaw

------=_Part_9816_32757967.1146096897566
Content-Type: text/x-patch; name=e1000.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_emiceq70
Content-Disposition: attachment; filename="e1000.patch"

diff -u -uprN -X linux-2.6.16.11/Documentation/dontdiff linux-2.6.16.11/drivers/net/e1000/e1000.h linux-2.6.16.11.e1000_patch/drivers/net/e1000/e1000.h
--- linux-2.6.16.11/drivers/net/e1000/e1000.h	2006-04-24 13:20:24.000000000 -0700
+++ linux-2.6.16.11.e1000_patch/drivers/net/e1000/e1000.h	2006-04-26 16:23:46.475842000 -0700
@@ -358,5 +358,8 @@ struct e1000_adapter {
 #ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
 #endif
+	uint32_t flags;
+#define E1000_CLEANING 0x00000001
+	spinlock_t clean_lock;
 };
 #endif /* _E1000_H_ */
diff -u -uprN -X linux-2.6.16.11/Documentation/dontdiff linux-2.6.16.11/drivers/net/e1000/e1000_main.c linux-2.6.16.11.e1000_patch/drivers/net/e1000/e1000_main.c
--- linux-2.6.16.11/drivers/net/e1000/e1000_main.c	2006-04-24 13:20:24.000000000 -0700
+++ linux-2.6.16.11.e1000_patch/drivers/net/e1000/e1000_main.c	2006-04-26 16:59:48.742905000 -0700
@@ -525,6 +525,16 @@ e1000_down(struct e1000_adapter *adapter
 	boolean_t mng_mode_enabled = (adapter->hw.mac_type >= e1000_82571) &&
 				     e1000_check_mng_mode(&adapter->hw);
 
+	spin_lock_bh(&adapter->clean_lock);
+	adapter->flags |= E1000_CLEANING;
+
+	if (!netif_running(netdev)) {
+	    adapter->flags &= ~E1000_CLEANING;
+	    spin_unlock_bh(&adapter->clean_lock);
+	    return;
+	}
+	spin_unlock_bh(&adapter->clean_lock);
+
 	e1000_irq_disable(adapter);
 #ifdef CONFIG_E1000_MQ
 	while (atomic_read(&adapter->rx_sched_call_data.count) != 0);
@@ -549,8 +559,12 @@ e1000_down(struct e1000_adapter *adapter
 	netif_stop_queue(netdev);
 
 	e1000_reset(adapter);
+
+	spin_lock_bh(&adapter->clean_lock);
 	e1000_clean_all_tx_rings(adapter);
 	e1000_clean_all_rx_rings(adapter);
+	adapter->flags &= ~E1000_CLEANING;
+	spin_unlock_bh(&adapter->clean_lock);
 
 	/* Power down the PHY so no link is implied when interface is down *
 	 * The PHY cannot be powered down if any of the following is TRUE *
@@ -1109,6 +1123,8 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
+	spin_lock_init(&adapter->clean_lock);
+	adapter->flags = 0;
 
 	return 0;
 }
@@ -1269,10 +1285,18 @@ e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
+	/* Calling flush_scheduled_work() may deadlock because
+	 * linkwatch_event() may be on the workqueue and it will 
+	 * try to get the rtnl_lock which we are holding. */
+	while (adapter->flags & E1000_CLEANING) 
+	    msleep(1);
+
 	e1000_down(adapter);
 
+	spin_lock_bh(&adapter->clean_lock);
 	e1000_free_all_tx_resources(adapter);
 	e1000_free_all_rx_resources(adapter);
+	spin_unlock_bh(&adapter->clean_lock);
 
 	if ((adapter->hw.mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {



------=_Part_9816_32757967.1146096897566--
