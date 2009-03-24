From: Patrick McHardy <kaber@trash.net>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 17:38:49 +0100
Message-ID: <49C90C99.30805@trash.net>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>	 <49C9087C.5070907@trash.net> <ac3eb2510903240928s6c42bc32pa0cd8a7f0e69b731@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <ac3eb2510903240928s6c42bc32pa0cd8a7f0e69b731@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kay Sievers wrote:
> On Tue, Mar 24, 2009 at 17:21, Patrick McHardy <kaber@trash.net> wrote:
>> Matt Domsch wrote:
>>>   c) udev may not always be able to change a device's name.  If udev
>>>      uses the kernel assignment namespace (ethN), then a rename of
>>>      eth0->eth1 may require renaming eth1->eth0 (or something else).
>>>      Udev operates on a single device instance at a time, it becomes
>>>      difficult to switch names around for multiple devices, within
>>>      the single namespace.
>> I would classify this as a bug, especially the fact that udev doesn't
>> undo a failed rename, so you end up with ethX_rename. Virtual devices
>> using the same MAC address trigger this reliably unless you add
>> exceptions to the udev rules.
> 
> This is handled in most cases. Virtual interfaces claiming a
> configured name and created before the "hardware" interface are not
> handled, that's right, but pretty uncommon.

I don't remember the exact circumstances, but I've seen it quite a few
times. I'll gather some information next time.

>> You state that it only operates on one device at a time. If that is
>> correct, I'm not sure why the _rename suffix is used at all instead
>> of simply trying to assign the final name, which would avoid this
>> problem.
> 
> How? The kernel assignes the names and the configured names may
> conflict. So you possibly can not rename a device to the target name
> when it's name is already taken. I don't see how to avoid this.

Sure, you can't rename it when the name is taken. But what udev
apparently does when renaming a device is:

- rename eth0 to eth0_rename
- rename eth0_rename to eth2
- rename returns -EEXISTS: udev keeps eth0_rename

What it could do is:

- rename eth0 to eth2
- rename returns -EEXISTS: device at least still has a proper name

Alternatively it should unroll the rename and hope that the
old name is still free. But I don't see why the _rename step
would do any good, assuming only a single device is handled at
a time, it can't prevent clashes.
