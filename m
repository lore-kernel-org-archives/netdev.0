From: Robert Dolca <robert.dolca@gmail.com>
Subject: Re: [linux-nfc] [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Wed, 1 Apr 2015 18:35:31 +0300
Message-ID: <CAFPB+Yf1jWX=tv+feZRonZEprjXwHdD8mMXAupdm5XrDaYvWMA@mail.gmail.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-9-git-send-email-robert.dolca@intel.com> <20150326003025.GE10954@ribalta.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Dolca <robert.dolca@intel.com>, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150326003025.GE10954@ribalta.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2015 at 2:30 AM, Samuel Ortiz <sameo@linux.intel.com> wrote:
>> +     /* If a patch was applied the new version is checked */
>> +     if (patched) {
>> +             r = nci_init(ndev);
>> +             if (r)
>> +                     goto error;
>> +
>> +             r = fdp_nci_get_versions(ndev);
>> +             if (r)
>> +                     goto error;
>> +
>> +             if (info->otp_version != info->otp_patch_version ||
>> +                 info->ram_version != info->ram_patch_version) {
>> +                     pr_err("FRP firmware update failed");
>> +                     r = -EINVAL;
>> +             }
>> +     }
>> +
>> +     /* Check if the device has VSC */
>> +     if (fdp_post_fw_vsc_cfg[0]) {
>> +             /* Set the vendor specific configuration */
>> +             r = fdp_nci_set_production_data(ndev, fdp_post_fw_vsc_cfg[3],
>> +                                             &fdp_post_fw_vsc_cfg[4]);
>> +             if (r)
>> +                     goto error;
>> +     }
>> +
>> +     /* Set clock type and frequency */
>> +     r = fdp_nci_set_clock(ndev, 0, 26000);
>> +     if (r)
>> +             goto error;
> The version checking, production data setting and clock setting should
> be part of a post setup notification call. Please add an nci_dev
> notify() ops that could get called on certain events, for example when
> NCI is up. Bluetooth's HCI does something along those lines already.
> From this notification hook you could implement this post setup stage.
>
> The idea is for your setup routine to only do firmware update and
> nothing else. It will make it shorter, and thus easier to read as well.

Hi Samuel,

If the RAM patch wasn't applied successfully the device can't be used
so the setup function should fail.
If the production data (specifically the clock frequency) is not set
the device can not be used. If the user space tries to start polling
before the notification is sent the polling will fail. Having it
called later would mean introducing a race condition.

Cheers,
Robert
