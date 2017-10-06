From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH 4/4] tcp: avoid noref dst leak on input path
Date: Fri, 06 Oct 2017 17:21:40 +0200
Message-ID: <1507303300.2793.25.camel@redhat.com>
References: <cover.1507294365.git.pabeni@redhat.com>
         <77fd3b021d5a2f6dd4ad6b08e64f0643e3af95f4.1507294365.git.pabeni@redhat.com>
         <1507300642.14419.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507300642.14419.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 2017-10-06 at 07:37 -0700, Eric Dumazet wrote:
> On Fri, 2017-10-06 at 14:57 +0200, Paolo Abeni wrote:
> > Enabling CONFIG_RCU_NOREF_DEBUG gives the following splat when
> > processing tcp packets:
> > 
> >            to-be-untracked noref entity ffff942cb71ea300 not found in cache
> >            ------------[ cut here ]------------
> >            WARNING: CPU: 24 PID: 178 at kernel/rcu/noref_debug.c:54 rcu_track_noref+0xa4/0xf0
> >            Modules linked in: intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel crypto_simd glue_helper cryptd iTCO_wdt ipmi_ssif mei_me iTCO_vendor_support mei dcdbas lpc_ich ipmi_si mxm_wmi sg pcspkr ipmi_devintf ipmi_msghandler acpi_power_meter shpchp wmi nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod mgag200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm igb drm ixgbe mdio crc32c_intel ahci ptp i2c_algo_bit libahci pps_core i2c_core libata dca dm_mirror dm_region_hash dm_log dm_mod
> >            CPU: 24 PID: 178 Comm: ksoftirqd/24 Not tainted 4.14.0-rc1.noref_route+ #1610
> >            Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.4.3 01/17/2017
> >            task: ffff940e48300000 task.stack: ffffaec406a20000
> >            RIP: 0010:rcu_track_noref+0xa4/0xf0
> >            RSP: 0018:ffffaec406a238e0 EFLAGS: 00010246
> >            RAX: 0000000000000040 RBX: 0000000000000000 RCX: 0000000000000002
> >            RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000292
> >            RBP: ffffaec406a238e0 R08: 0000000000000000 R09: 0000000000000000
> >            R10: 0000000000000001 R11: 0000000000000003 R12: 0000000000000000
> >            R13: ffff942cb5110000 R14: 000000000000fe88 R15: ffff942cb1a20200
> >            FS:  0000000000000000(0000) GS:ffff942cbee00000(0000) knlGS:0000000000000000
> >            CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >            CR2: 00007febc072d140 CR3: 0000001feebd6002 CR4: 00000000003606e0
> >            DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >            DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >            Call Trace:
> >             tcp_data_queue+0x82a/0xce0
> 
> That is strange, since tcp_data_queue() starts with
> 
> 	skb_dst_drop(skb); 
> 
> So this stack trace looks suspicious.

Thank you for the feedback.

I most probably messed-up while extracting the info from dmsg, as this
issue gives a couple of splats almost concurrently. Please let me re-do 
the test and post a more resonable dmsg.

The problem with the current code is that in the tcp_rcv_established()
-> tcp_queue_rcv() path, the skb_dst() is not cleared.

Thanks,

Paolo
