From: Ryan Hsu <ryanhsu@qti.qualcomm.com>
Subject: Re: WARN_ON_ONCE(work > weight) in napi_poll()
Date: Tue, 18 Jul 2017 06:47:09 +0000
Message-ID: <daa2fbf9-ac75-a7eb-f2b7-054dfae6fc56@qca.qualcomm.com>
References: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com>
 <87wp7oia6j.fsf@kamboji.qca.qualcomm.com>
 <952aefe1-6f6a-3978-e7e7-5e74076f26a3@virtuozzo.com>
 <b418d63d-d348-90b5-ea58-6478a1a037f5@qca.qualcomm.com>
 <8cb28d9b-41c9-043c-16ca-f0bea41944e9@virtuozzo.com>
 <3ce246b3-b110-dd50-bf29-45ee78985872@quantenna.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Networking <netdev@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3ce246b3-b110-dd50-bf29-45ee78985872@quantenna.com>
Content-Language: en-US
Content-ID: <6713E710B7DAC04A95820880533C9685@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2017 06:19 PM, Igor Mitsyanko wrote:

> On 07/11/2017 10:28 AM, Andrey Ryabinin wrote:
>>
>> It gave me this:
>>
>> [118648.825347] #1 quota too big 72 64 16
>> [118648.825351] #2 quota too big 72 64 16
>> [118648.825471] ------------[ cut here ]------------
>> [118648.825484] WARNING: CPU: 0 PID: 0 at ../net/core/dev.c:5274 net_rx_=
action+0x258/0x360
>>
>> So this means that we didn't met the condition bellow, i.e. skb_queue_em=
pty() returned true.
>>
>>          ath10k_htt_txrx_compl_task():
>>
>>                  if ((quota > ATH10K_NAPI_QUOTA_LIMIT) &&
>>                      !skb_queue_empty(&htt->rx_in_ord_compl_q)) {
>>                          resched_napi =3D true;
>>                          goto exit;
>>                  }
>>
>>> Also WLAN.RM.2.0-00180-QCARMSWPZ-1 firmware is a bit old, could you als=
o update firmware to give it a try?
>>> https://github.com/kvalo/ath10k-firmware/tree/master/QCA6174/hw3.0/4.4
>>>
>>
>> Will try.
>>
>
> Maybe ath10k_htt_rx_in_ord_ind() has to accept "budget_left" parameter an=
d use it to limit number of processed MSDUs in queued AMSDU and saving rest=
 for later (NAPI has to be rescheduled in this case).
> It seems natural that this problem happens with current logic, in case AM=
SDU in Rx queue has more elements then left in budget.

Thanks, likely in current logic, it does have chance to exceed the budget w=
hile dequeuing from the last list.

Can you give it a try this one? for QCA6174 reorder is offload, so this sho=
uld be good enough for your case to test, will have to check non-offload re=
order case... but let me know if you're seeing something different....

--
diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireles=
s/ath/ath10k/htt_rx.c
index 398dda9..e8697a1 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -1735,7 +1735,8 @@ static void ath10k_htt_rx_delba(struct ath10k *ar, st=
ruct htt_resp *resp)
 }
=20
 static int ath10k_htt_rx_extract_amsdu(struct sk_buff_head *list,
-                       struct sk_buff_head *amsdu)
+                       struct sk_buff_head *amsdu,
+                       int budget_left)
 {
     struct sk_buff *msdu;
     struct htt_rx_desc *rxd;
@@ -1746,8 +1747,9 @@ static int ath10k_htt_rx_extract_amsdu(struct sk_buff=
_head *list,
     if (WARN_ON(!skb_queue_empty(amsdu)))
         return -EINVAL;
=20
-    while ((msdu =3D __skb_dequeue(list))) {
+    while ((msdu =3D __skb_dequeue(list)) && budget_left) {
         __skb_queue_tail(amsdu, msdu);
+        budget_left--;
=20
         rxd =3D (void *)msdu->data - sizeof(*rxd);
         if (rxd->msdu_end.common.info0 &
@@ -1838,7 +1840,8 @@ static int ath10k_htt_rx_h_rx_offload(struct ath10k *=
ar,
     return num_msdu;
 }
=20
-static int ath10k_htt_rx_in_ord_ind(struct ath10k *ar, struct sk_buff *skb=
)
+static int ath10k_htt_rx_in_ord_ind(struct ath10k *ar, struct sk_buff *skb=
,
+                    int budget_left)
 {
     struct ath10k_htt *htt =3D &ar->htt;
     struct htt_resp *resp =3D (void *)skb->data;
@@ -1895,9 +1898,9 @@ static int ath10k_htt_rx_in_ord_ind(struct ath10k *ar=
, struct sk_buff *skb)
     if (offload)
         num_msdus =3D ath10k_htt_rx_h_rx_offload(ar, &list);
=20
-    while (!skb_queue_empty(&list)) {
+    while (!skb_queue_empty(&list) && budget_left) {
         __skb_queue_head_init(&amsdu);
-        ret =3D ath10k_htt_rx_extract_amsdu(&list, &amsdu);
+        ret =3D ath10k_htt_rx_extract_amsdu(&list, &amsdu, budget_left);
         switch (ret) {
         case 0:
             /* Note: The in-order indication may report interleaved
@@ -1907,6 +1910,7 @@ static int ath10k_htt_rx_in_ord_ind(struct ath10k *ar=
, struct sk_buff *skb)
              * should still give an idea about rx rate to the user.
              */
             num_msdus +=3D skb_queue_len(&amsdu);
+            budget_left -=3D skb_queue_len(&amsdu);
             ath10k_htt_rx_h_ppdu(ar, &amsdu, status, vdev_id);
             ath10k_htt_rx_h_filter(ar, &amsdu, status);
             ath10k_htt_rx_h_mpdu(ar, &amsdu, status);
@@ -2549,7 +2553,8 @@ int ath10k_htt_txrx_compl_task(struct ath10k *ar, int=
 budget)
         }
=20
         spin_lock_bh(&htt->rx_ring.lock);
-        num_rx_msdus =3D ath10k_htt_rx_in_ord_ind(ar, skb);
+        num_rx_msdus =3D ath10k_htt_rx_in_ord_ind(ar, skb,
+                            (budget - quota));
         spin_unlock_bh(&htt->rx_ring.lock);
         if (num_rx_msdus < 0) {
             resched_napi =3D true;
--

--=20
Ryan Hsu
