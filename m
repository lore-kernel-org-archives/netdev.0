From: Laura Abbott <labbott@redhat.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Wed, 20 May 2015 16:42:44 -0700
Message-ID: <555D1BF4.8020600@redhat.com>
References: <s5hwq04zypv.wl-tiwai@suse.de>	<Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>	<s5hpp5wtrrp.wl-tiwai@suse.de>	<1432057375.3970.4.camel@suse.com>	<s5h7fs3u5gy.wl-tiwai@suse.de>	<1432111237.8287.3.camel@suse.com>	<9BCD6CFF-0356-4A0F-97D4-776C0A2E436A@holtmann.org> <s5hbnhfifka.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>, Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5hbnhfifka.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2015 05:44 AM, Takashi Iwai wrote:
> At Wed, 20 May 2015 11:46:31 +0200,
> Marcel Holtmann wrote:
>>
>> Hi Oliver,
>>
>>>> The data is cached in RAM.  More specifically, the former loaded
>>>> firmware files are reloaded and saved at suspend for each device
>>>> object.  See fw_pm_notify() in firmware_class.c.
>>>
>>> OK, this may be a stupid idea, but do we know the firmware
>>> was successfully loaded in the first place?
>>> Also btusb is in the habit of falling back to a generic
>>> firmware in some places. It seems to me that caching
>>> firmware is conceptually not enough, but we'd also need
>>> to record the absence of firmware images.
>>
>> in a lot of cases the firmware is optional. The device will operate fine without the firmware. There are a few devices where the firmware is required, but for many it just contains patches.
>>
>> It would be nice if we could tell request_firmware() if it is optional or mandatory firmware. Or if it should just cache the status of a missing firmware as well.
>
> OK, below is a quick hack to record the failed f/w files, too.
> Not sure whether this helps, though.  Proper tests are appreciated.
>
>

This doesn't quite work. We end up with the name on fw_names but
the firmware isn't actually on the firmware cache list.

If request_firmware fails to get the firmware from the filesystem,
release firmware will be called which is going to free the
firmware_buf which has been marked as failed anyway. The only
way to make this work would be to always piggy back and increase
the ref so it always stays around. But this also marks the firmware
as a permanent failure. There would need to be a hook somewhere
to force a cache drop, else there would be no way to add new
firmware to a running system without a reboot.

Perhaps we split the difference: keep a list of firmware images
that failed to load in the past and if one is requested during
a time when usermodehelper isn't available, silently return an
error? This way, if correct firmware is loaded at a regular time
the item can be removed from the list.

Thanks,
Laura
