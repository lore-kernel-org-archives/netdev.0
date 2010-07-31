From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: iw reg set does not work because udev and crda do not respond to
	boot-time request.
Date: Sat, 31 Jul 2010 14:05:24 -0700
Message-ID: <AANLkTimA8JH2Ctw+dDtLMX3AUH-GKrEHtQQmMd-q7=0x@mail.gmail.com>
References: <201007311448.06959.d.haid@gogi.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kay Sievers <kay.sievers@suse.de>
To: Daniel Haid <d.haid@gogi.tv>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007311448.06959.d.haid@gogi.tv>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netlink / udev folks, please review.

On Sat, Jul 31, 2010 at 5:48 AM, Daniel Haid <d.haid@gogi.tv> wrote:
> Hello,
>
> the driver of my wireless card seems to ask for "US"
> regulatory data during boot, but since udev is not
> running at that point (I think not even the root filesystem
> is mounted) crda does not respond.

CRDA is not the only thing called by the kernel where there would be
an issue due to a delay with udev during bootup to react to a message.
The kernel calls CRDA for udev through kobject_uevent_env(). Uevent
messages are now broadcasted through
netlinknetlink_broadcast_filtered() since the old method of using a
direct call to /sbin/hotplug would lead to many processes being
spawned and in some cases OOM. You can still use this though through
CONFIG_UEVENT_HELPER_PATH which will issue call_usermodehelper()
during early boot on an initramfs for example, if you so need it.

I am not sure though if netlink broadcast messages would be reissued
by the kernel during early boot if no one replied back to the send
message but it is worth looking into. As far as I can tell you would
be the first to notice this. In fact we actually had reports of two
consecutive messages being being sent to userspace when only one was
being sent to userspace so it may indeed be in fact true that messages
are rebroadcasted somehow, I am just not sure so Cc'ing netdev and
lkml.

> The effect is that "iw reg set" does not work, because
> the kernel seems to be still waiting for the "US"
> regulatory data. Running
> COUNTRY="US" crda
> manually once fixes the problem (until the next reboot).

iw reg set will be ignored by net/wireless/reg.c as it is still
waiting for last_request to be processed. It seems in your case the
assumption that the request will be reissued in case udev is running
at early boot is incorrect and we need to further understand exactly
how these messages get queued and perhaps reissued or not.

I considered recently changing the way we handle requests to userspace
to use a completion handler but that would sit idle there for a while
blocking on the reg_mutex... so decided against it. But could take a
look again.

> What is the correct way of solving this? Should udev not
> pick up the request later when it is started?

We need a better understanding of how netlink broadcast messages get
processed during early boot. Right now cfg80211 will drop duplicate
requests or any request while we're still pending for the last one.
Once we find out more details about how netlink broadcast messages get
processed during early boot we can then rework things a bit. In the
meantime can you try using CONFIG_UEVENT_HELPER_PATH during the
initramfs?

  Luis
