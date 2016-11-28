From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 10/11] qede: Add basic XDP support
Date: Mon, 28 Nov 2016 19:18:32 +0000
Message-ID: <20161128191832.46191e1c@jkicinski-Precision-T1700>
References: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
        <1480258273-24973-11-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:5140 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754216AbcK1TSh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 14:18:37 -0500
In-Reply-To: <1480258273-24973-11-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 27 Nov 2016 16:51:12 +0200, Yuval Mintz wrote:
> Add support for the ndo_xdp callback. This patch would support XDP_PASS,
> XDP_DROP and XDP_ABORTED commands.
> 
> This also adds a per Rx queue statistic which counts number of packets
> which didn't reach the stack [due to XDP].
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> ---
> [...]
> +static int qede_xdp_set(struct qede_dev *edev, struct bpf_prog *prog)
> +{
> +	bool reload_required = true;
> +	struct qede_reload_args args;
> +	int rc = 0;
> +
> +	/* Protect against various other internal-reload flows */
> +	__qede_lock(edev);
> +	if (edev->state != QEDE_STATE_OPEN) {
> +		rc = -EINVAL;
> +		goto out;
> +	}
> +
> +	/* If we're called, there was already a bpf reference increment */
> +	args.func = &qede_xdp_reload_func;
> +	args.u.new_prog = prog;
> +	if (reload_required)
> +		qede_reload(edev, &args, true);
> +	else
> +		args.func(edev, &args);
> +
> +out:
> +	__qede_unlock(edev);
> +	return rc;
> +}

Any particular reason not to allow the XDP prog being set while the
device is closed?  You seem to preserve the program across
close()/open() cycles so the edev->xdp_prog is alive and valid while
device is closed IIUC.  

I think other drivers are allowing setting XDP while closed and it
would be cool to keep the behaviour identical across drivers :)
