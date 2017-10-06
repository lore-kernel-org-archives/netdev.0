From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] tcp: avoid noref dst leak on input path
Date: Fri, 06 Oct 2017 07:37:22 -0700
Message-ID: <1507300642.14419.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1507294365.git.pabeni@redhat.com>
         <77fd3b021d5a2f6dd4ad6b08e64f0643e3af95f4.1507294365.git.pabeni@redhat.com>
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
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <77fd3b021d5a2f6dd4ad6b08e64f0643e3af95f4.1507294365.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-10-06 at 14:57 +0200, Paolo Abeni wrote:
> Enabling CONFIG_RCU_NOREF_DEBUG gives the following splat when
> processing tcp packets:
> 
>            to-be-untracked noref entity ffff942cb71ea300 not found in cache
>            ------------[ cut here ]------------
>            WARNING: CPU: 24 PID: 178 at kernel/rcu/noref_debug.c:54 rcu_track_noref+0xa4/0xf0
>            Modules linked in: intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel crypto_simd glue_helper cryptd iTCO_wdt ipmi_ssif mei_me iTCO_vendor_support mei dcdbas lpc_ich ipmi_si mxm_wmi sg pcspkr ipmi_devintf ipmi_msghandler acpi_power_meter shpchp wmi nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod mgag200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm igb drm ixgbe mdio crc32c_intel ahci ptp i2c_algo_bit libahci pps_core i2c_core libata dca dm_mirror dm_region_hash dm_log dm_mod
>            CPU: 24 PID: 178 Comm: ksoftirqd/24 Not tainted 4.14.0-rc1.noref_route+ #1610
>            Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.4.3 01/17/2017
>            task: ffff940e48300000 task.stack: ffffaec406a20000
>            RIP: 0010:rcu_track_noref+0xa4/0xf0
>            RSP: 0018:ffffaec406a238e0 EFLAGS: 00010246
>            RAX: 0000000000000040 RBX: 0000000000000000 RCX: 0000000000000002
>            RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000292
>            RBP: ffffaec406a238e0 R08: 0000000000000000 R09: 0000000000000000
>            R10: 0000000000000001 R11: 0000000000000003 R12: 0000000000000000
>            R13: ffff942cb5110000 R14: 000000000000fe88 R15: ffff942cb1a20200
>            FS:  0000000000000000(0000) GS:ffff942cbee00000(0000) knlGS:0000000000000000
>            CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>            CR2: 00007febc072d140 CR3: 0000001feebd6002 CR4: 00000000003606e0
>            DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>            DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>            Call Trace:
>             tcp_data_queue+0x82a/0xce0

That is strange, since tcp_data_queue() starts with

	skb_dst_drop(skb); 

So this stack trace looks suspicious.

>             tcp_rcv_established+0x283/0x570
>             tcp_v4_do_rcv+0x102/0x1e0
>             tcp_v4_rcv+0xa9e/0xc10
>             ip_local_deliver_finish+0x128/0x380
>             ? ip_local_deliver_finish+0x41/0x380
>             ip_local_deliver+0x74/0x230
>             ip_rcv_finish+0x105/0x5e0
>             ip_rcv+0x2a7/0x540
>             __netif_receive_skb_core+0x3b9/0xe10
>             ? netif_receive_skb_internal+0x40/0x390
>             __netif_receive_skb+0x18/0x60
>             netif_receive_skb_internal+0x8d/0x390
>             ? netif_receive_skb_internal+0x40/0x390
>             napi_gro_complete+0x127/0x1d0
>             ? napi_gro_complete+0x2a/0x1d0
>             napi_gro_flush+0x5f/0x80
>             napi_complete_done+0x96/0x100
>             ixgbe_poll+0x5f8/0x7c0 [ixgbe]
>             net_rx_action+0x27d/0x520
>             __do_softirq+0xd1/0x4f5
>             run_ksoftirqd+0x25/0x70
>             smpboot_thread_fn+0x11a/0x1f0
>             kthread+0x155/0x190
>             ? sort_range+0x30/0x30
>             ? kthread_create_on_node+0x70/0x70
>             ret_from_fork+0x2a/0x40
>            Code: e9 83 c2 01 48 83 c0 18 83 fa 07 75 ef 80 3d b0 e5 ff 00 00 75 d2 48 c7 c7 50 54 07 9d 31 c0 c6 05 9e e5 ff 00 01 e8 ef af fe ff <0f> ff 5d c3 80 3d 8f e5 ff 00 00 75 b0 48 c7 c7 00 54 07 9d 31
> 
> we must clear the skb dst before enqueuing the skb somewhere,
> but currently the dst entry for packets delivered
> via tcp_rcv_established() -> tcp_queue_rcv() is not cleared.
> 
> Fix it by adding the explicit drop in tcp_queue_rcv() and moving
> the current skb_dst_drop() just before the other enqueuing
> operation, do avoid unneeded double skb_dst_drop() for some
> path.
> 
> The leak itself is not harmful, because the tcp recvmsg() code
> should not access such info.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/tcp_input.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c5d7656beeee..bf4e17edfe7a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4422,6 +4422,9 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
>  		return;
>  	}
>  
> +	/* drop the -possibly noref - dst before delivery the skb to ofo tree */
> +	skb_dst_drop(skb);
> +
>  	/* Stash tstamp to avoid being stomped on by rbnode */
>  	if (TCP_SKB_CB(skb)->has_rxtstamp)
>  		TCP_SKB_CB(skb)->swtstamp = skb->tstamp;
> @@ -4560,6 +4563,7 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
>  				  skb, fragstolen)) ? 1 : 0;
>  	tcp_rcv_nxt_update(tcp_sk(sk), TCP_SKB_CB(skb)->end_seq);
>  	if (!eaten) {
> +		skb_dst_drop(skb);
>  		__skb_queue_tail(&sk->sk_receive_queue, skb);
>  		skb_set_owner_r(skb, sk);
>  	}
> @@ -4626,7 +4630,6 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
>  		__kfree_skb(skb);
>  		return;
>  	}
> -	skb_dst_drop(skb);
>  	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
>  
>  	tcp_ecn_accept_cwr(tp, skb);
