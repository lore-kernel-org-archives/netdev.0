From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 15 Jan 2015 10:05:19 +0100
Message-ID: <3098312.6ZisxMKXt6@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <3131780.HetDHI4Cfl@wuerfel> <54B72BE0.7040403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org,
	agraf@suse.de, sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:60423 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbbAOJG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 04:06:26 -0500
In-Reply-To: <54B72BE0.7040403@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2015 10:54:24 Ding Tianhong wrote:
> On 2015/1/14 16:53, Arnd Bergmann wrote:
> > On Wednesday 14 January 2015 14:34:14 Ding Tianhong wrote:
> >> +#define HIP04_MAX_TX_COALESCE_USECS    200
> >> +#define HIP04_MIN_TX_COALESCE_USECS    100
> >> +#define HIP04_MAX_TX_COALESCE_FRAMES   200
> >> +#define HIP04_MIN_TX_COALESCE_FRAMES   100
> > 
> > It's not important, but in case you are creating another version of the
> > patch, maybe the allowed range can be extended somewhat. The example values
> > I picked when I sent my suggestion were really made up. It's great if
> > they work fine, but users might want to  tune this far more depending on
> > their workloads,  How about these
> > 
> > #define HIP04_MAX_TX_COALESCE_USECS    100000
> > #define HIP04_MIN_TX_COALESCE_USECS    1
> > #define HIP04_MAX_TX_COALESCE_FRAMES   (TX_DESC_NUM - 1)
> > #define HIP04_MIN_TX_COALESCE_FRAMES   1
> > 
> 
> Is it really ok that the so big range may break the driver and hip04 could not work fine?
> I am not sure it is ok, I will fix it in next version.

Obviously, performance will suffer when you pick a bad setting for
a given workload. If the numbers are too low, you will increase
the CPU load but get better latency, so I see nothing wrong in
allowing '1' as the minimum. For the descriptor number, you can't
go above TX_DESC_NUM, but there is nothing wrong in going close to
it, it will just mean that the timer should fire before you get
there and you again get more interrupts.

The 100ms maximum delay is a bit extreme, and will definitely impact
TX latency in some workloads if a user sets this, but the system
will should still be usable, and I couldn't think of a better
limit. Feel free to set this to e.g. 10ms or 1ms if you feel more
comfortable with that.

For reference, with TX_DESC_NUM=256 and 1500 byte frames, you have
up to 300ms worth of data in a full tx queue on a 10mbit link,
or 3ms respectively for a 1gbit link. Because of BQL, the actual
queue length will normally be much shorter than this, but on a
tx-only workload won't shrink below the currently used
tx_coalesce_usecs value.

	Arnd
