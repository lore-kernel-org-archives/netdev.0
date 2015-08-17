From: David Miller <davem@davemloft.net>
Subject: Re: [v1 0/6] *** nps_enet fixups ***
Date: Mon, 17 Aug 2015 10:36:07 -0700 (PDT)
Message-ID: <20150817.103607.1737876155019074073.davem@davemloft.net>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com, talz@ezchip.com
To: noamc@ezchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>
Date: Mon, 17 Aug 2015 08:58:33 +0300

> This patch set is a bunch of fixes to make nps_enet work correctly with
> all platforms, i.e. real device, emulation system, and simulation system.
> The main trigger for this patch set was that in our emulation system
> the TX end interrupt is "edge-sensitive" and therefore we cannot use the
> cause register since it is not sticky.
> Also:
> TX is handled during HW interrupt context and not NAPI job.
> race with TX done was fixed.
> added acknowledge for TX when device is "level sensitive".
> enable drop of control frames which is not needed for regular usage.
> 
> So most of this patch set is about TX handling, which is now more complete.

You should not move TX completion out of NAPI handling, NAPI poll is
exactly where it belongs.

If you handle it in hardware interrupt context you have to use
dev_kfree_skb_irq() which defers the operation to software interrupt
context anyways and is thus expensive.

Whereas if you keep TX completion in your NAPI handler the kfree is
handled synchronously and efficiently, as well as making SKB's
potentially available for RX reclaim.

I'm not applying this series, you are doing with TX handling exactly
what we tell people not to do.
