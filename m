From: Jason Wang <jasowang@redhat.com>
Subject: Re: [REGRESSION] 362899b ("macvtap: switch to use skb array") causes
 oops during teardown
Date: Thu, 11 Aug 2016 15:49:12 +0800
Message-ID: <c78f4930-dae0-8cde-be6b-8975a1081d6f@redhat.com>
References: <20160810184032.51f5429e.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160810184032.51f5429e.cornelia.huck@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年08月11日 00:40, Cornelia Huck wrote:
> I'm hitting the following oops during shutdown (halt command in guest)
> of a libvirt-managed qemu guest 100% of the time:
>
> [  108.920486] Unable to handle kernel pointer dereference in virtual kernel address space
> [  108.920492] Failing address: 6b6b6b6b6b6b6000 TEID: 6b6b6b6b6b6b6803
> [  108.920495] Fault in home space mode while using kernel ASCE.
> [  108.920504] AS:0000000000e20007 R3:0000000000000024
> [  108.920588] Oops: 0038 ilc:2 [#1] PREEMPT SMP
> [  108.920592] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc ghash_s390 prng ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 sha_common lockd grace vhost_net tun vhost macvtap macvlan kvm sunrpc dm_multipath dm_mod autofs4
> [  108.920628] CPU: 8 PID: 2648 Comm: qemu-system-s39 Not tainted 4.8.0-rc1-00031-gd3d312e #25
> [  108.920630] Hardware name: IBM              2964 NC9              704              (LPAR)
> [  108.920634] Krnl PSW : 0704e00180000000 000000000064a3e8 (kfree_skb+0x38/0x288)
> [  108.920640]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 RI:0 EA:3
> Krnl GPRS: 000000009fb04a5f 00000007a7a37d48 6b6b6b6b6b6b6b6b 000003ff80721af0
> [  108.920645]            000000000078d626 00000007a7a34000 0000000000000000 0000000000000008
> [  108.920647]            00000007b0f04210 00000007bde65718 000003ff80721afa 6b6b6b6b6b6b6b6b
> [  108.920648]            00000007bde65698 0000000000807180 000003ff80721afa 00000007a7a37d08
> [  108.920656] Krnl Code: 000000000064a3da: b90400ae            lgr     %r10,%r14
>             000000000064a3de: b90400b2           lgr     %r11,%r2
>            #000000000064a3e2: ec280121007c       cgij    %r2,0,8,64a624
>            >000000000064a3e8: 581020e4           l       %r1,228(%r2)
>             000000000064a3ec: ec160005017e       cij     %r1,1,6,64a3f6
>             000000000064a3f2: a7f4000b           brc     15,64a408
>             000000000064a3f6: a718ffff           lhi     %r1,-1
>             000000000064a3fa: eb1120e400f8       laa     %r1,%r1,228(%r2)
> [  108.920673] Call Trace:
> [  108.920675] ([<00000007a7a37d28>] 0x7a7a37d28)
> [  108.920679] ([<000003ff80721afa>] macvtap_sock_destruct+0x92/0xa8 [macvtap])
> [  108.920681] ([<0000000000647026>] __sk_destruct+0x3e/0x1f0)
> [  108.920684] ([<000003ff80723ed8>] macvtap_release+0x150/0x1b0 [macvtap])
> [  108.920688] ([<000000000031bd72>] __fput+0x132/0x230)
> [  108.920691] ([<000000000015f7aa>] task_work_run+0xb2/0xe8)
> [  108.920695] ([<000000000078e494>] system_call+0xdc/0x270)
> [  108.920697] INFO: lockdep is turned off.
> [  108.920698] Last Breaking-Event-Address:
> [  108.920700]  [<000003ff80721100>] 0x3ff80721100
> [  108.920703]  Kernel panic - not syncing: Fatal exception: panic_on_oops
>
> s390 host with a qeth device as the sole networking interface, one
> network interface in the guest, using vhost (I can try to figure out
> what libvirt is doing, if needed).
>
> If I revert 362899b ("macvtap: switch to use skb array") and its
> companion patch 0d7eacb ("macvtap: correctly free skb during socket
> destruction"), starting a guest via libvirt and halting it again from
> the guest works 100% of the time again.
>
> I'm willing to collect debug info if you tell me what you need.
>

Thanks for the reporting.

This looks like a use-after-free. Could you pls try the following patch 
to see it if fixes your issue?

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a38c0da..070e329 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -275,7 +275,6 @@ static void macvtap_put_queue(struct macvtap_queue *q)
         rtnl_unlock();

         synchronize_rcu();
-       skb_array_cleanup(&q->skb_array);
         sock_put(&q->sk);
  }

@@ -533,10 +532,8 @@ static void macvtap_sock_write_space(struct sock *sk)
  static void macvtap_sock_destruct(struct sock *sk)
  {
         struct macvtap_queue *q = container_of(sk, struct 
macvtap_queue, sk);
-       struct sk_buff *skb;

-       while ((skb = skb_array_consume(&q->skb_array)) != NULL)
-               kfree_skb(skb);
+       skb_array_cleanup(&q->skb_array);
  }

  static int macvtap_open(struct inode *inode, struct file *file)
