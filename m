From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-05-21
Date: Fri, 22 May 2015 15:27:36 +0300
Message-ID: <87r3q84x1j.fsf@kamboji.qca.qualcomm.com>
References: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
	<CA+BoTQmukTiNFrsLA5rdiQe=Ga45JNuFzSmqQ4h-VJMW97f=_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQmukTiNFrsLA5rdiQe=Ga45JNuFzSmqQ4h-VJMW97f=_w@mail.gmail.com>
	(Michal Kazior's message of "Fri, 22 May 2015 12:16:17 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org> writes:

> On 21 May 2015 at 15:39, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>
>> Secondly there's a non-trivial conflict in
>> drivers/net/wireless/ath/ath10k/mac.c which is due to removal of
>> FIF_PROMISC_IN_BSS in commit df1404650c. You need to remove more code
>> than just the obvious conflicts shown by git. In the end of this mail I
>> added a git diff output after I fixed the conflict, hopefully that helps
>> you to fix it. The main points are that you remove
>> ath10k_mac_should_disable_promisc() and the last ath10k_monitor_recalc()
>> call from ath10k_vdev_start_restart() along with the obvious conflict
>> fixes git points out.
>>
>> There's also a patch from Michal which will also help to fix the
>> resolution. Michal, please double check the resolution proposal below so
>> that I didn't miss anything.
>>
>> https://patchwork.kernel.org/patch/6387631/

[...]

> Looks good to me.

Thanks for checking.

> There's still some code left which is unnecessary (see 2 last hunks on
> patchwork) because due to FIF_PROMISC_IN_BSS removal entire commit
> 548462133d98 becomes obsolete. Since these 2 hunk leftovers don't
> break anything functionally I guess this can be cleaned up in a follow
> up patch after the merge. Just my 2cc.

Just to avoid any confusion, these are the hunks you mean (copypaste
from patchwork, whitespace damage likely):

@@ -1267,7 +1250,7 @@  static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
 {
 	struct ath10k *ar = arvif->ar;
 	struct wmi_vdev_start_request_arg arg = {};
-	int ret = 0, ret2;
+	int ret = 0;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
@@ -1326,16 +1309,6 @@  static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
 	ar->num_started_vdevs++;
 	ath10k_recalc_radar_detection(ar);
 
-	ret = ath10k_monitor_recalc(ar);
-	if (ret) {
-		ath10k_warn(ar, "mac failed to recalc monitor for vdev %i restart %d: %d\n",
-			    arg.vdev_id, restart, ret);
-		ret2 = ath10k_vdev_stop(arvif);
-		if (ret2)
-			ath10k_warn(ar, "mac failed to stop vdev %i restart %d: %d\n",
-				    arg.vdev_id, restart, ret2);
-	}
-
 	return ret;
 }

Yeah, these needs to be removed. For some reason 'git diff' doesn't show
these hunks after the conflicts are fixed.

>> + static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
>> +                                    const struct cfg80211_chan_def *chandef,
>> +                                    bool restart)
>>   {
>>         struct ath10k *ar = arvif->ar;
>> -       struct cfg80211_chan_def *chandef = &ar->chandef;
>>         struct wmi_vdev_start_request_arg arg = {};
>>  -      int ret = 0, ret2;
>>  +      int ret = 0;
>>
>>         lockdep_assert_held(&ar->conf_mutex);
>>
>
> Kalle, I'm not seeing this when I merge your pull tag on top of
> net-next/master. Am I missing something?

You lost me, you are not seeing what? I think we have a misunderstanding
here, let me explain how I created that diff:

git clone --reference ~/linux-2.6/ git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
cd net-next/
git pull git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-05-21
emacs drivers/net/wireless/ath/ath10k/mac.c
git diff > resolution.txt

> Anyway FYI ath10k_vdev_stop() was moved up in the code to avoid
> forward declaration in 822b7e0b633b.

Didn't understand this either.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
