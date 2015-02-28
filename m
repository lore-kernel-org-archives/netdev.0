From: Filip Ayazi <filipayazi@gmail.com>
Subject: Re: [PATCH] iwlwifi: mvm: check time event is over before disconnecting
Date: Sat, 28 Feb 2015 21:46:38 +0100
Message-ID: <54F2292E.5000803@gmail.com>
References: <1425078600-29882-1-git-send-email-filipayazi@gmail.com> <CANUX_P22MQEVkFsC_ToYiSTMVSB+QpSOMCb=d3+AH4224nhocw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANUX_P22MQEVkFsC_ToYiSTMVSB+QpSOMCb=d3+AH4224nhocw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/28/2015 08:55 PM, Emmanuel Grumbach wrote:
> On Sat, Feb 28, 2015 at 1:10 AM, Filip Ayazi <filipayazi@gmail.com> wrote:
>> On the 7260 time event was often ended before end_time and connections failed
>> with "No association and the time event is over already...".
>> This checks that the time event is actually over before disconnecting.
>>
>> Signed-off-by: Filip Ayazi <filipayazi@gmail.com>
> While this patch is wrong I'd like to know if it helps.
It helped here (7260 on Lenovo E440).
I get a TE with unknown action message and successful connection now,
used to be TE ended with current time < end time and a disconnect,
even on networks with excellent signal strength. It used to happen
about 30% of the time with no apparent pattern, sometimes restarting
the interface fixed the issue.
> The patch is wrong because even if the driver thinks the time event
> should still be running, if the firmware indicates it has already
> ended, we should still disconnect. The reason for the disconnection is
> that we can't be sure that the firmware will have the proper timing
> for the beacon and hence for the DTIM. Both are critical to get a
> decent behavior while saving power.
You are right, few hours ago, after waking from suspend, I could not switch
the interface on (ifconfig said SIOCSIFFLAGS: Input/output error), reloading
iwlmvm module helped, so this was likely the cause.
> In any case, I doubt this patch does actually something because the
> firmware and the driver should really be close in their timings. If
> they aren't, it is fundamental bug in the firmware. While the firmware
> does have bugs just like any piece of software, I doubt it has such
> big ones :)
I do not see any other explanation apart from faulty hardware,
which doesn't seem likely :)
>
>> ---
>>   drivers/net/wireless/iwlwifi/mvm/time-event.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wireless/iwlwifi/mvm/time-event.c
>> index 54fafbf..b0aa892 100644
>> --- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
>> +++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
>> @@ -256,7 +256,8 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mvm,
>>                  }
>>          }
>>
>> -       if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END) {
>> +       if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END &&
>> +           time_after(jiffies, te_data->end_jiffies)) {
>>                  IWL_DEBUG_TE(mvm,
>>                               "TE ended - current time %lu, estimated end %lu\n",
>>                               jiffies, te_data->end_jiffies);
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
