From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 3 Feb 2015 09:44:26 +0100
Message-ID: <CA+BoTQ=JLRbGfhZZLQShQFxeGCfhdu4XPt5FPv4gSqEc_sSOOw@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:64746 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933181AbbBCIo2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 03:44:28 -0500
Received: by mail-we0-f173.google.com with SMTP id w62so43589942wes.4
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 00:44:26 -0800 (PST)
In-Reply-To: <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 February 2015 at 19:52, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Mon, 2015-02-02 at 11:27 +0100, Michal Kazior wrote:
>
>> While testing I've had my internal GRO patch for ath10k and no stret=
ch
>> ack patches.
>
> Thanks for the data, I took a look at it.
>
> I am afraid this GRO patch might be the problem.

The entire performance drop happens without the GRO patch as well. I
tested with it included because I intended to upstream it later. I'll
run without it in future tests.


[...]
> Could you make again your experiments using upstream kernel (David
> Miller net tree) ?

Sure.


> You also could post the GRO patch so that we can comment on it.

(You probably want to see mac80211 patch as well:
06d181a8fd58031db9c114d920b40d8820380a6e "mac80211: add NAPI support
back")

diff --git a/drivers/net/wireless/ath/ath10k/core.c
b/drivers/net/wireless/ath/ath10k/core.c
index 36a8fcf..367e896 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1147,6 +1147,12 @@ err:
 }
 EXPORT_SYMBOL(ath10k_core_start);

+static int ath10k_core_napi_dummy_poll(struct napi_struct *napi, int b=
udget)
+{
+       WARN_ON(1);
+       return 0;
+}
+
 int ath10k_wait_for_suspend(struct ath10k *ar, u32 suspend_opt)
 {
        int ret;
@@ -1414,6 +1420,10 @@ struct ath10k *ath10k_core_create(size_t
priv_size, struct device *dev,
        INIT_WORK(&ar->register_work, ath10k_core_register_work);
        INIT_WORK(&ar->restart_work, ath10k_core_restart);

+       init_dummy_netdev(&ar->napi_dev);
+       ieee80211_napi_add(ar->hw, &ar->napi, &ar->napi_dev,
+                          ath10k_core_napi_dummy_poll, 64);
+
        ret =3D ath10k_debug_create(ar);
        if (ret)
                goto err_free_wq;
@@ -1434,6 +1444,7 @@ void ath10k_core_destroy(struct ath10k *ar)
 {
        flush_workqueue(ar->workqueue);
        destroy_workqueue(ar->workqueue);
+       netif_napi_del(&ar->napi);

        ath10k_debug_destroy(ar);
        ath10k_mac_destroy(ar);
diff --git a/drivers/net/wireless/ath/ath10k/core.h
b/drivers/net/wireless/ath/ath10k/core.h
index 2d9f871..b5a8847 100644
--- a/drivers/net/wireless/ath/ath10k/core.h
+++ b/drivers/net/wireless/ath/ath10k/core.h
@@ -623,6 +623,9 @@ struct ath10k {

        struct dfs_pattern_detector *dfs_detector;

+       struct net_device napi_dev;
+       struct napi_struct napi;
+
 #ifdef CONFIG_ATH10K_DEBUGFS
        struct ath10k_debug debug;
 #endif
diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c
b/drivers/net/wireless/ath/ath10k/htt_rx.c
index c1da44f..7e58b38 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -2061,5 +2061,7 @@ static void ath10k_htt_txrx_compl_task(unsigned l=
ong ptr)
                ath10k_htt_rx_in_ord_ind(ar, skb);
                dev_kfree_skb_any(skb);
        }
+
+       napi_gro_flush(&htt->ar->napi, false);
        spin_unlock_bh(&htt->rx_ring.lock);
 }

So that you can quickly get an understanding how ath10k Rx works:
first tasklet (not visible in the patch) picks up smallish event
buffers from firmware and puts them into ath10k queue for latter
processing by another tasklet (the last hunk). Each such event buffer
is just some metainfo but can "carry" tens of frames (both Rx and Tx
completions). The count is arbitrary and depends on fw/hw combo and
air conditions. The GRO flush is called after all queued small event
buffers are processed (frames delivered up to mac80211 which can in
turn perform aggregation reordering in case some frames were
re-transmitted in the meantime before handing them to net subsystem).


Micha=C5=82
