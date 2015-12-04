From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 4/4] net: mvneta: Spread out the TX queues
 management on all CPUs
Date: Fri, 04 Dec 2015 11:12:30 -0800
Message-ID: <1449256350.25029.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1449254700-32685-1-git-send-email-gregory.clement@free-electrons.com>
	 <1449254700-32685-5-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449254700-32685-5-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-12-04 at 19:45 +0100, Gregory CLEMENT wrote:
> With this patch each CPU is associated with its own set of TX queues. In
> the same time the SKB received in mvneta_tx is bound to the queue
> associated to the CPU sending the data. Thanks to this the next IRQ will
> be received on the same CPU allowing sending more data.
> 
> It will also allow to have a more predictable behavior regarding
> throughput and latency when having multiple threads sending out data on
> different CPUs.
> 
> As an example on Armada XP GP, with an iperf bound to a CPU and a ping
> bound to another CPU, without this patch the ping round trip was about
> 2.5ms (and could reach 3s!), whereas with this patch it was around
> 0.7ms (and sometime it went to 1.2ms).

This really looks like you need something smarter than pfifo_fast qdisc,
and maybe BQL (I did not check if this driver already implements this)

> 
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

...

> @@ -1824,13 +1835,16 @@ error:
>  static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct mvneta_port *pp = netdev_priv(dev);
> -	u16 txq_id = skb_get_queue_mapping(skb);
> +	u16 txq_id = smp_processor_id() % txq_number;
>  	struct mvneta_tx_queue *txq = &pp->txqs[txq_id];
>  	struct mvneta_tx_desc *tx_desc;
>  	int len = skb->len;
>  	int frags = 0;
>  	u32 tx_cmd;
>  
> +	/* Use the tx queue bound to this CPU */
> +	skb_set_queue_mapping(skb, txq_id);
> +


We certainly do not want every driver implementing its own hacks.

We have a standard way to handle this, it is called XPS, and eventually
ndo_select_queue()

Documentation/networking/scaling.txt contains some hints.
