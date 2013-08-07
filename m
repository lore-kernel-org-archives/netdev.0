From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: macvtap bug: using smp_processor_id() in preemptible code
Date: Wed, 07 Aug 2013 08:26:51 -0700
Message-ID: <1375889211.4004.28.camel@edumazet-glaptop>
References: <20130807164319.20aa2333@thhw500>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Huth <thuth@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35072 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab3HGP0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 11:26:54 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so2262871pab.25
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 08:26:54 -0700 (PDT)
In-Reply-To: <20130807164319.20aa2333@thhw500>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 16:43 +0200, Thomas Huth wrote:
> Hi,
> 
> I am using macvtap (via KVM/virsh) on a s390 box. With the latest
> kernel source from linux-next master branch, I suddenly get the
> following error messages in the dmesg output:
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: vhost-45891/45892
> caller is macvtap_do_read+0x45c/0x600 [macvtap]
> CPU: 1 PID: 45892 Comm: vhost-45891 Not tainted 3.11.0-bisecttest #13
>        000000010cab3a00 000000010cab3a10 0000000000000002 0000000000000000 
>        000000010cab3aa0 000000010cab3a18 000000010cab3a18 00000000001127b4 
>        0000000000000000 0000000000000001 0000000000000000 000000010000000b 
>        0000000000000060 000003fe00000008 0000000000000000 000000010cab3a70 
>        00000000006ea2f0 00000000001127b4 000000010cab3a00 000000010cab3a50 
> Call Trace:
> ([<00000000001126ee>] show_trace+0x126/0x144)
>  [<00000000001127d2>] show_stack+0xc6/0xd4
>  [<000000000068bcec>] dump_stack+0x74/0xd8
>  [<0000000000481066>] debug_smp_processor_id+0xf6/0x114
>  [<000003ff802e9a18>] macvtap_do_read+0x45c/0x600 [macvtap]
>  [<000003ff802e9c1c>] macvtap_recvmsg+0x60/0x88 [macvtap]
>  [<000003ff80318c5e>] handle_rx+0x5b2/0x800 [vhost_net]
>  [<000003ff8028f77c>] vhost_worker+0x15c/0x1c4 [vhost]
>  [<000000000015f3ac>] kthread+0xd8/0xe4
>  [<00000000006934a6>] kernel_thread_starter+0x6/0xc
>  [<00000000006934a0>] kernel_thread_starter+0x0/0xc
> 2 locks held by vhost-45891/45892:
>  #0:  (&vq->mutex){+.+...}, at: [<000003ff80318718>] handle_rx+0x6c/0x800 [vhost_net]
>  #1:  (rcu_read_lock){.+.+..}, at: [<000003ff802e98fe>] macvtap_do_read+0x342/0x600 [macvtap]
> 
> Apart from these "annoying" error messages (they are repeated
> continually while the KVM guest is running / macvtap is in use),
> everything still seems to work fine, though.
> 
> Since everything was still working fine in v3.10, I did some bisecting
> and it seems like this commit introduced this problem:
> 
>   commit: ac4e4af1e59e16a018527ffa58d9d3f30bb96ca9
>   Subject: macvtap: Consistently use rcu functions
> 
> I am not sure how to proceed here, this is my first bug report in this
> area, so advice is welcome...

Please try following fix :

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a98fb0e..1c7aab4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -912,8 +912,11 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 done:
 	rcu_read_lock();
 	vlan = rcu_dereference(q->vlan);
-	if (vlan)
+	if (vlan) {
+		preempt_disable();
 		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
+		preempt_enable();
+	}
 	rcu_read_unlock();
 
 	return ret ? ret : copied;
