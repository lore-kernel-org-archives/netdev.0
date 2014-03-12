From: Krishna Chaitanya <chaitanya.mgit@gmail.com>
Subject: Re: [mac80211_hwsim] BUG: unable to handle kernel paging request at ce1db404
Date: Thu, 13 Mar 2014 02:15:25 +0530
Message-ID: <CABPxzYLJA-gQjw2CwmL63dYEQ35h073k_vsp1uEM0B-sAmEwKQ@mail.gmail.com>
References: <20140305125703.GA7193@localhost> <20140305132317.GB10880@localhost>
 <20140308121138.GA8359@localhost> <20140312173446.GD2983@piware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Martin Pitt <martin.pitt@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140312173446.GD2983@piware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 11:04 PM, Martin Pitt <martin.pitt@ubuntu.com> wrote:
>
> Fengguang Wu [2014-03-08 20:11 +0800]:
> > [    4.429993] mac80211_hwsim: ieee80211_register_hw failed (-2)
> > [...]
> > [    4.431924]  [<c12377de>] get_device+0xf/0x17
> > [    4.431924]  [<c123a165>] driver_detach+0x38/0x8f
> > [    4.431924]  [<c1239433>] bus_remove_driver+0x53/0x66
> > [    4.431924]  [<c123a535>] driver_unregister+0x38/0x3d
> > [    4.431924]  [<c123b3aa>] platform_driver_unregister+0xb/0xd
> > [    4.431924]  [<c1c4ac9f>] init_mac80211_hwsim+0x3a5/0x3b6
>
>
> So that first message is from
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/wireless/mac80211_hwsim.c?id=9ea927748#n2428
>
> At this point we registered the platform driver and the class, and it
> should have created two devices (at least for the default radios=2).
> What's odd is that I don't see this printk in your kernel log:
>
>   mac80211_hwsim: Initializing radio %d
>
> If for some reasons "radio" is 0, it would not show this and not
> initialize data->dev, but then you shouldn't get to
> ieee80211_register_hw() either as it's in the same loop. So that's a
> bit of a mystery to me.
>
> On failure, above ieee80211_register_hw() jumps to the cleanup:
>
> | failed_hw:
> |       device_unregister(data->dev);
> | failed_drvdata:
> |       ieee80211_free_hw(hw);
> | failed:
> |       mac80211_hwsim_free();
> | failed_unregister_driver:
> |       driver_unregister(&mac80211_hwsim_driver);
> |       return err;
> | }
>
>
> The mac80211_hwsim_free() function again calls
> device_unregister(data->dev) for a list (not sure which, I'm not
> certain how to interpret
>
>   list_for_each_entry_safe(data, tmpdata, &tmplist, list)
>
> ) Could that be the double free causing the memory corruption?
>
> If you are in a position to do quick builds and tests, does the crash
> go away with this?
>
>                 printk(KERN_DEBUG "mac80211_hwsim: device_bind_driver failed (%d)\n",
>                        err);
> -               goto failed_hw;
> +               goto failed_drvdata;
>         }
>
> (I'm not claiming that this is correct, just taking a stab at
> understanding what happens) If not, does it go away with changing the
> goto to failed_unregister_driver()?
>
>From the logs it looks like "rate_control_alloc" is failed,
causing ieee80211_register_hw to fail triggering the crash.
what RC are u using? Default should be minstrel, i dont see
a reason for rc alloc to fail (remote reason kmalloc failure),
so did you disable RC completely? No prints either w.r.t RC either in
dmesg?
