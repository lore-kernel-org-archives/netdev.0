From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] net/mac80211/mesh_plink: Convert timers to use
Date: Thu, 5 Oct 2017 10:27:52 -0700
Message-ID: <CAGXu5jLMWz83XiBpVUdwxaTA9fY0X_OhPZtbEBefVzj7b3_7Wg@mail.gmail.com>
References: <20171005004952.GA23133@beast> <1507186052.2387.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507186052.2387.11.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 4, 2017 at 11:47 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2017-10-04 at 17:49 -0700, Kees Cook wrote:
>> In preparation for unconditionally passing the struct timer_list
>> pointer to all timer callbacks, switch to using the new timer_setup()
>> and from_timer() to pass the timer pointer explicitly. This requires
>> adding a pointer back to the sta_info since container_of() can't
>> resolve the sta_info.
>
> The subject seems to be lacking something ... :-)

Oh wonderful, all the subjects are cut off. *sigh* I wonder which
piece of my workflow broke that...

>> This requires commit 686fef928bba ("timer: Prepare to change timer
>> callback argument type") in v4.14-rc3, but should be otherwise
>> stand-alone.
>
> I still can't apply that because that's not in net-next right now.

Okay, I'll see if Dave brings that into net-next and resend after that.

>>  static inline void mesh_plink_timer_set(struct sta_info *sta, u32
>> timeout)
>>  {
>>       sta->mesh->plink_timer.expires = jiffies +
>> msecs_to_jiffies(timeout);
>> -     sta->mesh->plink_timer.data = (unsigned long) sta;
>> -     sta->mesh->plink_timer.function = mesh_plink_timer;
>> +     sta->mesh->plink_sta = sta;
>> +     sta->mesh->plink_timer.function =
>> (TIMER_FUNC_TYPE)mesh_plink_timer;
>>       sta->mesh->plink_timeout = timeout;
>>       add_timer(&sta->mesh->plink_timer);
>
> Wouldn't it be better to convert this to timer_setup() now?

The problem is that plink_timer is used in several places, and it's
originally initialized in net/mac80211/sta_info.c. The call to
mesh_plink_timer_set() does an update of the function field, so it
didn't look like it could get merged with the timer_setup(), but in
looking again, it seems that this is the _only_ update to
plink_timer.function, so it could probably get collapsed into the
timer_setup() call.

> That add_timer() should probably also be mod_timer() anyway?

Agreed. I'd avoided making those changes in most places, but I can do it here.

>> diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
>> index 69615016d5bf..5e5de9455e4e 100644
>> --- a/net/mac80211/sta_info.c
>> +++ b/net/mac80211/sta_info.c
>> @@ -332,7 +332,7 @@ struct sta_info *sta_info_alloc(struct
>> ieee80211_sub_if_data *sdata,
>>               spin_lock_init(&sta->mesh->plink_lock);
>>               if (ieee80211_vif_is_mesh(&sdata->vif) &&
>>                   !sdata->u.mesh.user_mpm)
>> -                     init_timer(&sta->mesh->plink_timer);
>> +                     timer_setup(&sta->mesh->plink_timer, NULL,
>> 0);
>>               sta->mesh->nonpeer_pm = NL80211_MESH_POWER_ACTIVE;
>>       }
>
> You just have to make mesh_plink_timer() non-static, put a prototype
> into mesh.h and then you can use the proper timer_setup() here with the
> function?
>
> Also, the sta->mesh->plink_sta assignment should be here I'd say, no
> point rewriting it all the time.

Sounds good. I'll get it cleaned up.

-Kees

-- 
Kees Cook
Pixel Security
