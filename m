From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 8/9] net: dsa: mv88e6xxx: add rx/tx
 timestamping support
Date: Sun, 8 Oct 2017 11:29:18 -0400
Message-ID: <20171008152917.6gc7qkany7zv6fb3@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-9-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:40AM -0500, Brandon Streiff wrote:
> +void mv88e6xxx_port_txtstamp(struct dsa_switch *ds, int port,
> +			     struct sk_buff *clone, unsigned int type)
> +{
> +	struct mv88e6xxx_chip *chip = ds->priv;
> +	struct mv88e6xxx_port_hwtstamp *ps = &chip->port_hwtstamp[port];
> +
> +	if (!chip->info->ptp_support)
> +		return;
> +
> +	if (port < 0 || port >= mv88e6xxx_num_ports(chip))
> +		goto out;
> +
> +	if (unlikely(skb_shinfo(clone)->tx_flags & SKBTX_HW_TSTAMP) &&
> +	    mv88e6xxx_should_tstamp(chip, port, clone, type)) {
> +		__be16 *seq_ptr = (__be16 *)(_get_ptp_header(clone, type) +
> +					     OFF_PTP_SEQUENCE_ID);
> +
> +		if (!test_and_set_bit_lock(MV88E6XXX_HWTSTAMP_TX_IN_PROGRESS,
> +					   &ps->state)) {
> +			ps->tx_skb = clone;
> +			ps->tx_tstamp_start = jiffies;
> +			ps->tx_seq_id = be16_to_cpup(seq_ptr);
> +
> +			/* Fetching the timestamp is high-priority work because
> +			 * 802.1AS bounds the time for a response.

Can you please use this?

commit d9535cb7b7603aeb549c697ecdf92024e4d0a650
Author: Grygorii Strashko <grygorii.strashko@ti.com>
Date:   Fri Jul 28 17:30:02 2017 -0500

    ptp: introduce ptp auxiliary worker
    
    Many PTP drivers required to perform some asynchronous or periodic work,
    like periodically handling PHC counter overflow or handle delayed timestamp
    for RX/TX network packets. In most of the cases, such work is implemented
    using workqueues. Unfortunately, Kernel workqueues might introduce
    significant delay in work scheduling under high system load and on -RT,
    which could cause misbehavior of PTP drivers due to internal counter
    overflow, for example, and there is no way to tune its execution policy and
    priority manuallly.
    
    Hence, The kthread_worker can be used insted of workqueues, as it create
    separte named kthread for each worker and its its execution policy and
    priority can be configured using chrt tool.

> +			 * No need to check result of queue_work(). ps->tx_skb
> +			 * check ensures work item is not pending (it may be
> +			 * waiting to exit)
> +			 */
> +			queue_work(system_highpri_wq, &ps->tx_tstamp_work);
> +			return;
> +		}
> +
> +		/* Otherwise we're already in progress... */
> +		dev_dbg(chip->dev,
> +			"p%d: tx timestamp already in progress, discarding",
> +			port);
> +	}
> +
> +out:
> +	/* We don't need it after all. */
> +	kfree_skb(clone);
> +}

Thanks,
Richard
