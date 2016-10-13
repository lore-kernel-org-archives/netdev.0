From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Thu, 13 Oct 2016 22:42:52 +0900
Message-ID: <20161013134252.GA583@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
 <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net>
 <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Andy Lutomirski <luto@amacapital.net>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476338524.4904.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/13/16 08:02), Johannes Berg wrote:
> On Wed, 2016-10-12 at 22:39 -0700, Andy Lutomirski wrote:
> 
> > In a pinch, I have these patches sitting around:
> > 
> > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=0a39cfa6fbb5d5635c85253cc7d6b44b54822afd
> > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=bf8cfa200b5a01383ea39fc8ce2f32909767baa8
> 
> That truly sounds like something we'd rather avoid in the TX/RX paths
> though, which should perform well.

didn't fix.

so I finally had some time to do a better bug-reporter job.

I added a bunch of printk-s and several virt_addr_valid()-s
to ieee80211_aes_ccm_encrypt().

and right befoe the Oops I see the following report from
virt_addr_valid()


 FAIL: 00004100002cba02 > ffffc900802cba02 || 1 -> (00004100002cba02 >> 39) == 130


which is basically failed '!phys_addr_valid(x)' in __virt_addr_valid()

		/* carry flag will be set if starting x was >= PAGE_OFFSET */
		if ((x > y) || !phys_addr_valid(x))
			return false;

backtrace

 ------------[ cut here ]------------
 WARNING: CPU: 7 PID: 246 at arch/x86/mm/physaddr.c:68 __virt_addr_valid+0xab/0xed
  ffffc900002cb6f0 ffffffff8122168c 0000000000000000 0000000000000000
  ffffc900002cb730 ffffffff810428d8 0000004400000198 ffff88041bd21022
  ffffc900002cba02 1ffff920000596ed ffff88041932d1e0 ffffc900002cba00
 Call Trace:
  [<ffffffff8122168c>] dump_stack+0x4f/0x65
  [<ffffffff810428d8>] __warn+0xc2/0xdd
  [<ffffffff81042963>] warn_slowpath_null+0x1d/0x1f
  [<ffffffff8103c226>] __virt_addr_valid+0xab/0xed
  [<ffffffff8146d31a>] ieee80211_aes_ccm_decrypt+0x8f/0x2da
  [<ffffffff812372de>] ? debug_smp_processor_id+0x17/0x19
  [<ffffffff810fb7e1>] ? __put_page+0x3c/0x3f
  [<ffffffff8145b879>] ? ccmp_special_blocks.isra.1+0x51/0x12d
  [<ffffffff8145c445>] ieee80211_crypto_ccmp_decrypt+0x204/0x298
  [<ffffffff81476dd1>] ieee80211_rx_handlers+0x7df/0x1c1d
  [<ffffffff814791c1>] ieee80211_prepare_and_rx_handle+0xdc2/0xe79
  [<ffffffff814793cc>] ? ieee80211_rx_napi+0x154/0x7a5
  [<ffffffff814796ec>] ieee80211_rx_napi+0x474/0x7a5
  [<ffffffffa01fce3b>] iwl_mvm_rx_rx_mpdu+0x6e6/0x751 [iwlmvm]
  [<ffffffffa01f6c49>] iwl_mvm_rx+0x7e/0x98 [iwlmvm]
  [<ffffffffa01c0bca>] iwl_pcie_rx_handle+0x523/0x698 [iwlwifi]
  [<ffffffffa01c2015>] iwl_pcie_irq_handler+0x45d/0x64d [iwlwifi]
  [<ffffffff81089411>] ? irq_finalize_oneshot+0xd4/0xd4
  [<ffffffff8108942e>] irq_thread_fn+0x1d/0x34
  [<ffffffff810896a2>] irq_thread+0xe6/0x1bb
  [<ffffffff81089527>] ? wake_threads_waitq+0x2c/0x2c
  [<ffffffff810895bc>] ? irq_thread_dtor+0x95/0x95
  [<ffffffff8105d7a3>] kthread+0xfc/0x104
  [<ffffffff8107d3ad>] ? put_lock_stats.isra.9+0xe/0x20
  [<ffffffff8105d6a7>] ? kthread_create_on_node+0x3f/0x3f
  [<ffffffff8105d6a7>] ? kthread_create_on_node+0x3f/0x3f
  [<ffffffff8105d6a7>] ? kthread_create_on_node+0x3f/0x3f
  [<ffffffff814b2952>] ret_from_fork+0x22/0x30

	-ss
