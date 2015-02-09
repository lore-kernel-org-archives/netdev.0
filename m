From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 9 Feb 2015 14:47:56 +0100
Message-ID: <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	<1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	<1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	<1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	<1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:37648 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759882AbbBINr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 08:47:58 -0500
Received: by mail-we0-f169.google.com with SMTP id k48so5978760wev.0
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 05:47:56 -0800 (PST)
In-Reply-To: <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 February 2015 at 15:09, Michal Kazior <michal.kazior@tieto.com> wr=
ote:
> On 6 February 2015 at 14:53, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
>> On Fri, 2015-02-06 at 05:40 -0800, Eric Dumazet wrote:
>>
>>> tcp_wfree() could maintain in tp->tx_completion_delay_ms an EWMA
>>> of TX completion delay. But this would require yet another expensiv=
e
>>> call to ktime_get() if HZ < 1000.
>>>
>>> Then tcp_write_xmit() could use it to adjust :
>>>
>>>    limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >> 9);
>>>
>>> to
>>>
>>>    amount =3D (2 + tp->tx_completion_delay_ms) * sk->sk_pacing_rate
>>>
>>>    limit =3D max(2 * skb->truesize, amount / 1000);
>>>
>>> I'll cook a patch.
>>
>> Hmm... doing this in all protocols would be too expensive,
>> and we do not want to include time spent in qdiscs.
>>
>> wifi could eventually do that, providing in skb->tx_completion_delay=
_us
>> the time spent in wifi driver.
>>
>> This way, we would have no penalty for network devices doing normal =
skb
>> orphaning (loopback interface, ethernet, ...)
>
> I'll play around with this idea and report back later.

I'm able to get 600mbps with 5 flows and 250mbps with 1 flow, i.e.
same as before the regression. I'm attaching the patch at the end of
my mail - is this approach viable?

I wonder if there's anything that can be done to allow 600mbps (line
rate) on 1 flow with ath10k without tweaking tcp_limit_output_bytes
(you can't expect end-users to tweak this).

Perhaps tcp_limit_output_bytes should also consider tx_completion_delay=
, e.g.:

  amount =3D sk->sk_tx_completion_delay_us;
  amount *=3D sk->sk_pacing_rate >> 10;
  limit =3D max(2 * skb->truesize, amount >> 10);
  max_limit =3D sysctl_tcp_limit_output_bytes;
  max_limit *=3D 1 + (sk->sk_tx_completion_delay_us / USEC_PER_MSEC);
  limit =3D min(u32, limit, max_limit);

With this I get ~400mbps on 1 flow. If I add the original 1ms extra
delay from your formula to tx_completion_delay I fill in ath10k I get
nearly line rate in 1 flow (almost 600mbps; it hops between 570-620).
Decreasing tcp_limit_output_bytes decreases throughput (e.g. 64K gives
300mbps, 32K gives 180mbps, 16K gives 110mbps). Multiple flows in
iperf seem unbalanced with 128K limit, but look okay with 32K).


Micha=C5=82


diff --git a/drivers/net/wireless/ath/ath10k/core.h
b/drivers/net/wireless/ath/ath10k/core.h
index 3be3a59..4ff0ae8 100644
--- a/drivers/net/wireless/ath/ath10k/core.h
+++ b/drivers/net/wireless/ath/ath10k/core.h
@@ -82,6 +82,7 @@ struct ath10k_skb_cb {
        dma_addr_t paddr;
        u8 eid;
        u8 vdev_id;
+       ktime_t stamp;

        struct {
                u8 tid;
diff --git a/drivers/net/wireless/ath/ath10k/mac.c
b/drivers/net/wireless/ath/ath10k/mac.c
index 15e47f4..5efb2a7 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -2620,6 +2620,7 @@ static void ath10k_tx(struct ieee80211_hw *hw,
        if (info->flags & IEEE80211_TX_CTL_NO_CCK_RATE)
                ath10k_dbg(ar, ATH10K_DBG_MAC,
"IEEE80211_TX_CTL_NO_CCK_RATE\n");

+       ATH10K_SKB_CB(skb)->stamp =3D ktime_get();
        ATH10K_SKB_CB(skb)->htt.is_offchan =3D false;
        ATH10K_SKB_CB(skb)->htt.tid =3D ath10k_tx_h_get_tid(hdr);
        ATH10K_SKB_CB(skb)->vdev_id =3D ath10k_tx_h_get_vdev_id(ar, vif=
);
diff --git a/drivers/net/wireless/ath/ath10k/txrx.c
b/drivers/net/wireless/ath/ath10k/txrx.c
index 3f00cec..0d5539b 100644
--- a/drivers/net/wireless/ath/ath10k/txrx.c
+++ b/drivers/net/wireless/ath/ath10k/txrx.c
@@ -15,6 +15,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */

+#include <net/sock.h>
 #include "core.h"
 #include "txrx.h"
 #include "htt.h"
@@ -82,6 +83,13 @@ void ath10k_txrx_tx_unref(struct ath10k_htt *htt,

        ath10k_report_offchan_tx(htt->ar, msdu);

+       if (msdu->sk) {
+               ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_us) =3D
+                               ktime_to_ns(ktime_sub(ktime_get(),
+                                                     skb_cb->stamp)) /
+                               NSEC_PER_USEC;
+       }
+
        info =3D IEEE80211_SKB_CB(msdu);
        memset(&info->status, 0, sizeof(info->status));
        trace_ath10k_txrx_tx_unref(ar, tx_done->msdu_id);
diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec..6b15d71 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -390,6 +390,7 @@ struct sock {
        int                     sk_wmem_queued;
        gfp_t                   sk_allocation;
        u32                     sk_pacing_rate; /* bytes per second */
+       u32                     sk_tx_completion_delay_us;
        u32                     sk_max_pacing_rate;
        netdev_features_t       sk_route_caps;
        netdev_features_t       sk_route_nocaps;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 65caf8b..5e249bf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1996,6 +1996,7 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
        max_segs =3D tcp_tso_autosize(sk, mss_now);
        while ((skb =3D tcp_send_head(sk))) {
                unsigned int limit;
+               unsigned int amount;

                tso_segs =3D tcp_init_tso_segs(sk, skb, mss_now);
                BUG_ON(!tso_segs);
@@ -2053,7 +2054,9 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
                 * of queued bytes to ensure line rate.
                 * One example is wifi aggregation (802.11 AMPDU)
                 */
-               limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >> =
10);
+               amount =3D sk->sk_tx_completion_delay_us *
+                        (sk->sk_pacing_rate >> 10);
+               limit =3D max(2 * skb->truesize, amount >> 10);
                limit =3D min_t(u32, limit, sysctl_tcp_limit_output_byt=
es);

                if (atomic_read(&sk->sk_wmem_alloc) > limit) {
