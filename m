From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-05-21
Date: Fri, 22 May 2015 12:16:17 +0200
Message-ID: <CA+BoTQmukTiNFrsLA5rdiQe=Ga45JNuFzSmqQ4h-VJMW97f=_w@mail.gmail.com>
References: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k2w26oef.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 21 May 2015 at 15:39, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Hi Dave,
>
> here's a wireless-drivers pull request for 4.2. This time please pay
> extra attention to this pull as there are two problems:
>
> First of all as you can see the diffstat from git-pull-request in the
> end is just weird. I was long and hard trying to check everything and=
 to
> my understanding all the merges look ok and I cannot explain the reas=
on
> for the diffstat, but of course I might be missing something. Maybe
> git-request-pull is just buggy? At least with gitk everything looks t=
o
> be ok and the patch list below also looks valid.
>
> Secondly there's a non-trivial conflict in
> drivers/net/wireless/ath/ath10k/mac.c which is due to removal of
> FIF_PROMISC_IN_BSS in commit df1404650c. You need to remove more code
> than just the obvious conflicts shown by git. In the end of this mail=
 I
> added a git diff output after I fixed the conflict, hopefully that he=
lps
> you to fix it. The main points are that you remove
> ath10k_mac_should_disable_promisc() and the last ath10k_monitor_recal=
c()
> call from ath10k_vdev_start_restart() along with the obvious conflict
> fixes git points out.
>
> There's also a patch from Michal which will also help to fix the
> resolution. Michal, please double check the resolution proposal below=
 so
> that I didn't miss anything.
>
> https://patchwork.kernel.org/patch/6387631/

[...]

> diff --cc drivers/net/wireless/ath/ath10k/mac.c
> index fcd08b2f8d26,eaa0182e001d..000000000000
> --- a/drivers/net/wireless/ath/ath10k/mac.c
> +++ b/drivers/net/wireless/ath/ath10k/mac.c
> @@@ -766,9 -1031,68 +1031,48 @@@ static int ath10k_monitor_stop(struc=
t a
>         return 0;
>   }
>
>  -static bool ath10k_mac_should_disable_promisc(struct ath10k *ar)
>  -{
>  -      struct ath10k_vif *arvif;
>  -
>  -      if (!(ar->filter_flags & FIF_PROMISC_IN_BSS))
>  -              return true;
>  -
>  -      if (!ar->num_started_vdevs)
>  -              return false;
>  -
>  -      list_for_each_entry(arvif, &ar->arvifs, list)
>  -              if (arvif->vdev_type !=3D WMI_VDEV_TYPE_AP)
>  -                      return false;
>  -
>  -      ath10k_dbg(ar, ATH10K_DBG_MAC,
>  -                 "mac disabling promiscuous mode because vdev is st=
arted\n");
>  -      return true;
>  -}
>  -
> + static bool ath10k_mac_monitor_vdev_is_needed(struct ath10k *ar)
> + {
> +       int num_ctx;
> +
> +       /* At least one chanctx is required to derive a channel to st=
art
> +        * monitor vdev on.
> +        */
> +       num_ctx =3D ath10k_mac_num_chanctxs(ar);
> +       if (num_ctx =3D=3D 0)
> +               return false;
> +
> +       /* If there's already an existing special monitor interface t=
hen don't
> +        * bother creating another monitor vdev.
> +        */
> +       if (ar->monitor_arvif)
> +               return false;
> +
> +       return ar->monitor ||
>  -             !ath10k_mac_should_disable_promisc(ar) ||
> +              test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags);
> + }
> +
> + static bool ath10k_mac_monitor_vdev_is_allowed(struct ath10k *ar)
> + {
> +       int num_ctx;
> +
> +       num_ctx =3D ath10k_mac_num_chanctxs(ar);
> +
> +       /* FIXME: Current interface combinations and cfg80211/mac8021=
1 code
> +        * shouldn't allow this but make sure to prevent handling the=
 following
> +        * case anyway since multi-channel DFS hasn't been tested at =
all.
> +        */
> +       if (test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags) && num_ctx >=
 1)
> +               return false;
> +
> +       return true;
> + }
> +
>   static int ath10k_monitor_recalc(struct ath10k *ar)
>   {
> -       bool should_start;
> +       bool needed;
> +       bool allowed;
> +       int ret;
>
>         lockdep_assert_held(&ar->conf_mutex);
>

Looks good to me.

There's still some code left which is unnecessary (see 2 last hunks on
patchwork) because due to FIF_PROMISC_IN_BSS removal entire commit
548462133d98 becomes obsolete. Since these 2 hunk leftovers don't
break anything functionally I guess this can be cleaned up in a follow
up patch after the merge. Just my 2cc.


> @@@ -871,12 -1231,46 +1211,46 @@@ static void ath10k_recalc_radar_det=
ecti
>         }
>   }
>
> - static int ath10k_vdev_start_restart(struct ath10k_vif *arvif, bool=
 restart)
> + static int ath10k_vdev_stop(struct ath10k_vif *arvif)
> + {
> +       struct ath10k *ar =3D arvif->ar;
> +       int ret;
> +
> +       lockdep_assert_held(&ar->conf_mutex);
> +
> +       reinit_completion(&ar->vdev_setup_done);
> +
> +       ret =3D ath10k_wmi_vdev_stop(ar, arvif->vdev_id);
> +       if (ret) {
> +               ath10k_warn(ar, "failed to stop WMI vdev %i: %d\n",
> +                           arvif->vdev_id, ret);
> +               return ret;
> +       }
> +
> +       ret =3D ath10k_vdev_setup_sync(ar);
> +       if (ret) {
> +               ath10k_warn(ar, "failed to syncronise setup for vdev =
%i: %d\n",
> +                           arvif->vdev_id, ret);
> +               return ret;
> +       }
> +
> +       WARN_ON(ar->num_started_vdevs =3D=3D 0);
> +
> +       if (ar->num_started_vdevs !=3D 0) {
> +               ar->num_started_vdevs--;
> +               ath10k_recalc_radar_detection(ar);
> +       }
> +
> +       return ret;
> + }
> +
> + static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
> +                                    const struct cfg80211_chan_def *=
chandef,
> +                                    bool restart)
>   {
>         struct ath10k *ar =3D arvif->ar;
> -       struct cfg80211_chan_def *chandef =3D &ar->chandef;
>         struct wmi_vdev_start_request_arg arg =3D {};
>  -      int ret =3D 0, ret2;
>  +      int ret =3D 0;
>
>         lockdep_assert_held(&ar->conf_mutex);
>

Kalle, I'm not seeing this when I merge your pull tag on top of
net-next/master. Am I missing something?

Anyway FYI ath10k_vdev_stop() was moved up in the code to avoid
forward declaration in 822b7e0b633b.


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
