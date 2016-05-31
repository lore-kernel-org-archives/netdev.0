From: Kalle Valo <kvalo@codeaurora.org>
Subject: ath9k gpio request
Date: Tue, 31 May 2016 10:31:02 +0300
Message-ID: <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>
References: <20160530132225.4d297678@canb.auug.org.au>
	<574C4851.9090201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <574C4851.9090201@gmail.com> (Sudip Mukherjee's message of "Mon,
	30 May 2016 19:34:01 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Changing subject to a more descriptive one, was "Re: linux-next: Tree
for May 30")

Sudip Mukherjee <sudipm.mukherjee@gmail.com> writes:

> Hi All,
> I have just built and booted with next-20160530 and my dmesg is full
> of warnings from ath9k. Last kernel tested was v4.6 and there was no
> problem with that.
>
> The traces are like:
> Call Trace:
>  [<ffffffff813b8ddc>] dump_stack+0x63/0x87
>  [<ffffffff8107a331>] __warn+0xd1/0xf0
>  [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
>  [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
>  [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
>  [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
>  [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
>  [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
>  [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
>  [<ffffffff817d6e92>] ? mutex_lock+0x12/0x2f
>  [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
>  [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
>  [<ffffffff81093183>] process_one_work+0x153/0x3f0
>  [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
>  [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
>  [<ffffffff81099129>] kthread+0xc9/0xe0
>  [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
>  [<ffffffff81099060>] ? kthread_park+0x60/0x60
> ---[ end trace 27eb5094a52869ea ]---
>
> Call Trace:
>  [<ffffffff813b8ddc>] dump_stack+0x63/0x87
>  [<ffffffff8107a331>] __warn+0xd1/0xf0
>  [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
>  [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
>  [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
>  [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
>  [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
>  [<ffffffff817c5514>] rfkill_poll+0x24/0x50
>  [<ffffffff81093183>] process_one_work+0x153/0x3f0
>  [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
>  [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
>  [<ffffffff81099129>] kthread+0xc9/0xe0
>  [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
>  [<ffffffff81099060>] ? kthread_park+0x60/0x60
> ---[ end trace 27eb5094a5286a3d ]---

The traces look incomplete to me, is there anything more before the
"Call Trace:" line? Full unedited logs are usually the best.

> If it is a known problem then great.. else i can debug and see what
> the problem is. There are only few patches added for GPIO, so should
> not be a problem to find out what is causing the error.

I haven't seen this kind of report before. My first suspect is the
commit below so adding Miaoqing.

commit b2d70d4944c1789bc64376ad97a811f37e230c87
Author: Miaoqing Pan <miaoqing@codeaurora.org>
Date:   Mon Mar 7 10:38:15 2016 +0800

    ath9k: make GPIO API to support both of WMAC and SOC
    
    commit 61b559dea40e ("ath9k: add extra GPIO led support")
    added ath9k to support access SOC's GPIOs, but implemented
    in a separated API: ath9k_hw_request_gpio().
    
    So this patch make the APIs more common, to support both
    of WMAC and SOC GPIOs. The new APIs as below,
    
    void ath9k_hw_gpio_request_in();
    void ath9k_hw_gpio_request_out();
    void ath9k_hw_gpio_free();
    
    NOTE, the BSP of the SOC chips(AR9340, AR9531, AR9550, AR9561)
    should set the corresponding MUX registers correctly.
    
    Signed-off-by: Miaoqing Pan <miaoqing@codeaurora.org>
    Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

-- 
Kalle Valo
