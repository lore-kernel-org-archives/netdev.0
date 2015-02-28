From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH] iwlwifi: mvm: check time event is over before disconnecting
Date: Sat, 28 Feb 2015 21:55:17 +0200
Message-ID: <CANUX_P22MQEVkFsC_ToYiSTMVSB+QpSOMCb=d3+AH4224nhocw@mail.gmail.com>
References: <1425078600-29882-1-git-send-email-filipayazi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Filip Ayazi <filipayazi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425078600-29882-1-git-send-email-filipayazi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2015 at 1:10 AM, Filip Ayazi <filipayazi@gmail.com> wrote:
> On the 7260 time event was often ended before end_time and connections failed
> with "No association and the time event is over already...".
> This checks that the time event is actually over before disconnecting.
>
> Signed-off-by: Filip Ayazi <filipayazi@gmail.com>

While this patch is wrong I'd like to know if it helps.
The patch is wrong because even if the driver thinks the time event
should still be running, if the firmware indicates it has already
ended, we should still disconnect. The reason for the disconnection is
that we can't be sure that the firmware will have the proper timing
for the beacon and hence for the DTIM. Both are critical to get a
decent behavior while saving power.
In any case, I doubt this patch does actually something because the
firmware and the driver should really be close in their timings. If
they aren't, it is fundamental bug in the firmware. While the firmware
does have bugs just like any piece of software, I doubt it has such
big ones :)

> ---
>  drivers/net/wireless/iwlwifi/mvm/time-event.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wireless/iwlwifi/mvm/time-event.c
> index 54fafbf..b0aa892 100644
> --- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
> +++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
> @@ -256,7 +256,8 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mvm,
>                 }
>         }
>
> -       if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END) {
> +       if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END &&
> +           time_after(jiffies, te_data->end_jiffies)) {
>                 IWL_DEBUG_TE(mvm,
>                              "TE ended - current time %lu, estimated end %lu\n",
>                              jiffies, te_data->end_jiffies);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
