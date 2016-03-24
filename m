From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFCv2 2/3] ath10k: report per-station tx/rate rates to mac80211
Date: Thu, 24 Mar 2016 13:31:32 +0100
Message-ID: <CA+BoTQkX=USr1d_0NCNgjK+_P8Ae0GqxTzVMAqRHFm4incxXXA@mail.gmail.com>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
	<1458123478-1795-3-git-send-email-michal.kazior@tieto.com>
	<20160324071923.GB23410@atheros-ThinkPad-T61>
	<CA+BoTQmRBog+oSMCKUUzTV1Jm_Mip0ZA9mnpkZ14hDUq32Dszg@mail.gmail.com>
	<20160324122317.GB30872@atheros-ThinkPad-T61>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
To: Mohammed Shafi Shajakhan <mohammed-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160324122317.GB30872@atheros-ThinkPad-T61>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 24 March 2016 at 13:23, Mohammed Shafi Shajakhan
<mohammed-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> On Thu, Mar 24, 2016 at 08:49:12AM +0100, Michal Kazior wrote:
>> On 24 March 2016 at 08:19, Mohammed Shafi Shajakhan
>> <mohammed-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>> > Hi Michal,
>> >
>> > On Wed, Mar 16, 2016 at 11:17:57AM +0100, Michal Kazior wrote:
>> >> The rate control is offloaded by firmware so it's
>> >> challanging to provide expected throughput value
>> >> for given station.
>> >>
>> >> This approach is naive as it reports last tx rate
>> >> used for given station as provided by firmware
>> >> stat event.
>> >>
>> >> This should be sufficient for airtime estimation
>> >> used for fq-codel-in-mac80211 tx scheduling
>> >> purposes now.
>> >>
>> >> This patch uses a very hacky way to get the stats.
>> >> This is sufficient for proof-of-concept but must
>> >> be cleaned up properly eventually.
>> >>
>> >> Signed-off-by: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
>> >> ---
>> >>  drivers/net/wireless/ath/ath10k/core.h  |  5 +++
>> >>  drivers/net/wireless/ath/ath10k/debug.c | 61 +++++++++++++++++++=
++++++++++----
>> >>  drivers/net/wireless/ath/ath10k/mac.c   | 26 ++++++++------
>> >>  drivers/net/wireless/ath/ath10k/wmi.h   |  2 +-
>> >>  4 files changed, 76 insertions(+), 18 deletions(-)
>> >>
>> >> diff --git a/drivers/net/wireless/ath/ath10k/core.h b/drivers/net=
/wireless/ath/ath10k/core.h
>> >> index 23ba03fb7a5f..3f76669d44cf 100644
>> >> --- a/drivers/net/wireless/ath/ath10k/core.h
>> >> +++ b/drivers/net/wireless/ath/ath10k/core.h
>> >> @@ -331,6 +331,9 @@ struct ath10k_sta {
>> >>       /* protected by conf_mutex */
>> >>       bool aggr_mode;
>> >>       u64 rx_duration;
>> >> +
>> >> +     u32 tx_rate_kbps;
>> >> +     u32 rx_rate_kbps;
>> >>  #endif
>> >>  };
>> >>
>> >> @@ -372,6 +375,8 @@ struct ath10k_vif {
>> >>       s8 def_wep_key_idx;
>> >>
>> >>       u16 tx_seq_no;
>> >> +     u32 tx_rate_kbps;
>> >> +     u32 rx_rate_kbps;
>> >>
>> >>       union {
>> >>               struct {
>> >> diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/ne=
t/wireless/ath/ath10k/debug.c
>> >> index 076d29b53ddf..cc7ebf04ae00 100644
>> >> --- a/drivers/net/wireless/ath/ath10k/debug.c
>> >> +++ b/drivers/net/wireless/ath/ath10k/debug.c
>> >> @@ -316,6 +316,58 @@ static void ath10k_debug_fw_stats_reset(stru=
ct ath10k *ar)
>> >>       spin_unlock_bh(&ar->data_lock);
>> >>  }
>> >>
>> >> +static void ath10k_mac_update_txrx_rate_iter(void *data,
>> >> +                                          u8 *mac,
>> >> +                                          struct ieee80211_vif *=
vif)
>> >> +{
>> >> +     struct ath10k_fw_stats_peer *peer =3D data;
>> >> +     struct ath10k_vif *arvif;
>> >> +
>> >> +     if (memcmp(vif->addr, peer->peer_macaddr, ETH_ALEN))
>> >> +             return;
>> >> +
>> >> +     arvif =3D (void *)vif->drv_priv;
>> >> +     arvif->tx_rate_kbps =3D peer->peer_tx_rate;
>> >> +     arvif->rx_rate_kbps =3D peer->peer_rx_rate;
>> >> +}
>> >> +
>> >> +static void ath10k_mac_update_txrx_rate(struct ath10k *ar,
>> >> +                                     struct ath10k_fw_stats *sta=
ts)
>> >> +{
>> >> +     struct ieee80211_hw *hw =3D ar->hw;
>> >> +     struct ath10k_fw_stats_peer *peer;
>> >> +     struct ath10k_sta *arsta;
>> >> +     struct ieee80211_sta *sta;
>> >> +     const u8 *localaddr =3D NULL;
>> >> +
>> >> +     rcu_read_lock();
>> >> +
>> >> +     list_for_each_entry(peer, &stats->peers, list) {
>> >> +             /* This doesn't account for multiple STA connected =
on different
>> >> +              * vifs. Unfortunately there's no way to derive tha=
t from the available
>> >> +              * information.
>> >> +              */
>> >> +             sta =3D ieee80211_find_sta_by_ifaddr(hw,
>> >> +                                                peer->peer_macad=
dr,
>> >> +                                                localaddr);
>> >> +             if (!sta) {
>> >> +                     /* This tries to update multicast rates */
>> >> +                     ieee80211_iterate_active_interfaces_atomic(
>> >> +                                     hw,
>> >> +                                     IEEE80211_IFACE_ITER_NORMAL=
,
>> >> +                                     ath10k_mac_update_txrx_rate=
_iter,
>> >> +                                     peer);
>> >> +                     continue;
>> >> +             }
>> >> +
>> >> +             arsta =3D (void *)sta->drv_priv;
>> >> +             arsta->tx_rate_kbps =3D peer->peer_tx_rate;
>> >> +             arsta->rx_rate_kbps =3D peer->peer_rx_rate;
>> >> +     }
>> >> +
>> >> +     rcu_read_unlock();
>> >> +}
>> >> +
>> >>  void ath10k_debug_fw_stats_process(struct ath10k *ar, struct sk_=
buff *skb)
>> >>  {
>> >>       struct ath10k_fw_stats stats =3D {};
>> >> @@ -335,6 +387,8 @@ void ath10k_debug_fw_stats_process(struct ath=
10k *ar, struct sk_buff *skb)
>> >>               goto free;
>> >>       }
>> >>
>> >> +     ath10k_mac_update_txrx_rate(ar, &stats);
>> >> +
>> >>       /* Stat data may exceed htc-wmi buffer limit. In such case =
firmware
>> >>        * splits the stats data and delivers it in a ping-pong fas=
hion of
>> >>        * request cmd-update event.
>> >> @@ -351,13 +405,6 @@ void ath10k_debug_fw_stats_process(struct at=
h10k *ar, struct sk_buff *skb)
>> >>       if (peer_stats_svc)
>> >>               ath10k_sta_update_rx_duration(ar, &stats.peers);
>> >>
>> >> -     if (ar->debug.fw_stats_done) {
>> >> -             if (!peer_stats_svc)
>> >> -                     ath10k_warn(ar, "received unsolicited stats=
 update event\n");
>> >> -
>> >> -             goto free;
>> >> -     }
>> >> -
>> >
>> > [shafi] As you had suggested previously, should we completely clea=
n up this ping
>> > - pong response approach for f/w stats, (or) this should be retain=
ed to support
>> > backward compatibility and also for supporting ping - pong respons=
e when user
>> > cats for fw-stats (via debugfs) (i did see in the commit message t=
his needs to
>> > be cleaned up)
>>
>> I think it makes sense to remove the ping-pong logic and rely on
>> periodic updates alone, including fw_stats and ethstats handling.
>>
>>
>> >> -     if (test_bit(WMI_SERVICE_PEER_STATS, ar->wmi.svc_map)) {
>> >> -             param =3D ar->wmi.pdev_param->peer_stats_update_per=
iod;
>> >> -             ret =3D ath10k_wmi_pdev_set_param(ar, param,
>> >> -                                             PEER_DEFAULT_STATS_=
UPDATE_PERIOD);
>> >> -             if (ret) {
>> >> -                     ath10k_warn(ar,
>> >> -                                 "failed to set peer stats perio=
d : %d\n",
>> >> -                                 ret);
>> >> -                     goto err_core_stop;
>> >> -             }
>> >> +     param =3D ar->wmi.pdev_param->peer_stats_update_period;
>> >> +     ret =3D ath10k_wmi_pdev_set_param(ar, param,
>> >> +                                     PEER_DEFAULT_STATS_UPDATE_P=
ERIOD);
>> >> +     if (ret) {
>> >> +             ath10k_warn(ar,
>> >> +                         "failed to set peer stats period : %d\n=
",
>> >> +                         ret);
>> >> +             goto err_core_stop;
>> >>       }
>> >
>> > [shafi] If i am correct this change requires 'PEER_STATS' to be en=
abled by
>> > default.
>>
>> No, it does not. Periodic stats have been available since forever.
>
> [shafi] Michal, sorry i was talking about enabling WMI_PEER_STATS fea=
ture for
> 10.2, and we have a patch pushed recently to reduce the number of pee=
rs if
> 'WMI_PEER_STATS' feature is enabled(avoiding f/w crash due to memory
> constraints) . But this patch requires the feature to be
> turned ON always (with periodic stats update as well for evey 100ms).=
 Please
> correct me if my understanding is wrong.

Periodic stats and extended stats are two separate things.

WMI_PEER_STATS is a feature which prompts firmware to gather more
statistics and then report them to host via stat update event and
includes, e.g. rx_duration. Due to how rx_duration was designed in
firmware it needs to be combined with reading out the stats often to
make it usable. Periodic stats were used instead of explicit
ping-pong.

Periodic stats is just one of two ways (the other being ping-pong)
asking firmware for stat update event. It has been in firmware since
forever.


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
