From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH v5 0/4] Provide netdev naming-policy via sysfs
Date: Fri, 28 Mar 2014 20:34:47 +0100
Message-ID: <CANq1E4TxaNnZoqfw5DiifAhk28hVq5HJJMd07ZDFAjdc68nKKg@mail.gmail.com>
References: <1395839117-20090-1-git-send-email-dh.herrmann@gmail.com>
	<20140328.145410.1817326821928803131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Tom Gundersen <teg@jklm.no>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140328.145410.1817326821928803131.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Fri, Mar 28, 2014 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
> udev can look at the device type, and policies can be defined that key
> off of that device type, entirely in userspace.

Regarding wifi-P2P devices, udev can indeed use nl80211 to get the
exact IF-type. An attribute would be much easier to read out, but I'm
ok if we don't want to replicate that information.

However, as mentioned in the discussions on v1, there're more
use-cases than that. Imagine a 3rd party initrd renames a
network-device early, if udev runs in the main system, we would rename
the device again. If we could detect the rename via NET_NAME_RENAMED,
we wouldn't break such setups. The only reason to rename devices in
udev is to get reliable names. If someone else already renamed a
device, we always expect them to provide better names than we do, so
udev should only touch devices that have kernel-enumerated names.
Of course, this can be fixed by requiring all the initrd developers to
somehow tag devices as already renamed. But this would replicate
information that the kernel already has.

Another example are dynamically created devices via RTM_NEWLINK. The
if-names are provided by user-space and udev should never try to do
any magic renaming on them (why would we? you can just easily fix the
code that created the device).

So it turns out, all we want to know is whether an interface-name was
chosen by the kernel via plain, simple enumeration, or whether it has
a user-space origin. Only in the former case we want to rename the
device. The name_assign_type attribute tells us exactly where a name
comes from and thus avoids maintaining blacklists in user-space that
skip renaming on such devices. I'm sorry, but I cannot see why such
blacklists (or whitelists) are preferred over a sysfs attribute.

Thanks
David
