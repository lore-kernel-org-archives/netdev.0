From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [Bug,
 PATCH and another Bug] Was: Fix refcounting problem with
 netif_rx_reschedule()
Date: Thu, 20 Sep 2007 11:12:28 -0700 (PDT)
Message-ID: <20070920.111228.76772435.davem@davemloft.net>
References: <20070919.090557.24612742.davem@davemloft.net>
	<OF8B3BDDEC.3F73CFD4-ON6525735C.001C8A0F-6525735C.001D2340@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF8B3BDDEC.3F73CFD4-ON6525735C.001C8A0F-6525735C.001D2340@in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 20 Sep 2007 10:48:15 +0530

> About the "list deletion occurs", isn't the race I mentioned still present?
> If done < budget, the driver does netif_rx_complete (at which time some
> other cpu can add this NAPI to their list). But the first cpu might do some more
> actions on the napi, like ipoib_poll() calls request_notify_cq(priv->cq),
> when other cpu might have started using this napi.
> 
> (net_rx_action's 'list_move' however will not execute since work != weight)

It is the driver's responsibility to adhere to the fact that once
netif_rx_complete() is called, the driver is explicitly relinquishing
ownership of the NAPI state.

It therefore must not access that NAPI state until it has successfully
acquired the NAPI_STATE_SCHED bit atomically, via a sched or resched.
