From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] tipc: check minimum bearer MTU
Date: Wed, 30 Nov 2016 11:24:24 +0100
Message-ID: <20161130102424.GC19119@unicorn.suse.cz>
References: <20161130095702.DD033A0F14@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Qian Zhang <zhangqian-c@360.cn>
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130095702.DD033A0F14@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 10:57:02AM +0100, Michal Kubecek wrote:
> Qian Zhang (张谦) reported a potential socket buffer overflow in
> tipc_msg_build() which is also known as CVE-2016-8632: due to
> insufficient checks, a buffer overflow can occur if MTU is too short for
> even tipc headers. As anyone can set device MTU in a user/net namespace,
> this issue can be abused by a regular user.
> 
> As agreed in the discussion on Ben Hutchings' original patch, we should
> check the MTU at the moment a bearer is attached rather than for each
> processed packet. We also need to repeat the check when bearer MTU is
> adjusted to new device MTU. UDP case also needs a check to avoid
> overflow when calculating bearer MTU.
> 
> Fixes: b97bf3fd8f6a ("[TIPC] Initial merge")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> Reported-by: Qian Zhang (张谦) <zhangqian-c@360.cn>

Self-NACK.

Im sorry, while testing this, I overlooked that an attempt to change
MTU of an underlying device to low value issues a warning but it
succeeds anyway.

> @@ -624,6 +626,9 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
>  		tipc_reset_bearer(net, b);
>  		break;
>  	case NETDEV_CHANGEMTU:
> +		if (tipc_check_mtu(dev, 0))
> +			return -EINVAL;
> +		b->mtu = dev->mtu;
>  		tipc_reset_bearer(net, b);
>  		break;
>  	case NETDEV_CHANGEADDR:

This is a notifier so that error value needs to be encoded into notifier
error. I'll send v2 after retesting

Michal Kubecek
