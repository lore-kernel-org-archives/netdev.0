From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 11:26:11 -0700
Message-ID: <1460399171.6473.562.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
	 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570BA8C7.1000905@axis.com>
	 <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570BC024.1070504@axis.com>
	 <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpWM0cce9PtvkenywGpvh0MEMe_0qvkKC00kYFAdFG=BxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <lars.persson@axis.com>,
	Lars Persson <larper@axis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWM0cce9PtvkenywGpvh0MEMe_0qvkKC00kYFAdFG=BxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-11 at 11:02 -0700, Cong Wang wrote:

> I am fine with either way as long as the loop stops on failure.
> Folding the test "if (skb)" into one also requires to retake the spinlock.

Adding the likely() in this path would probably help as well.

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f18c35024207..07202d9ac4f6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -159,12 +159,14 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
        if (validate)
                skb = validate_xmit_skb_list(skb, dev);
 
-       if (skb) {
+       if (likely(skb)) {
                HARD_TX_LOCK(dev, txq, smp_processor_id());
                if (!netif_xmit_frozen_or_stopped(txq))
                        skb = dev_hard_start_xmit(skb, dev, txq, &ret);
 
                HARD_TX_UNLOCK(dev, txq);
+       } else {
+               ... does all and return...
        }
        spin_lock(root_lock);
