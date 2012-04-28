From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Sat, 28 Apr 2012 18:07:06 -0400
Message-ID: <4F9C6A0A.5090109@tilera.com>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204101042.39877.arnd@arndb.de> <4F8763E1.1020605@tilera.com> <201204131034.03544.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204131034.03544.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/13/2012 6:34 AM, Arnd Bergmann wrote:
> On Thursday 12 April 2012, Chris Metcalf wrote:
>> On 4/10/2012 6:42 AM, Arnd Bergmann wrote:
>>> Ok, but please remove tile_net_devs then.
>>> I think a better abstraction for tile_net_devs_for_channel would be
>>> some interface that lets you add private data to a channel so when
>>> you get data from a channel, you can extract that pointer from the driver
>>> using the channel.
>> I think what would be clearer is to document how and why we are using this
>> additional data structure.  We do access via both arrays where it is
>> efficient to do so, so getting rid of either of them doesn't seem right. 

In the latest round of changes (to be mailed shortly), we eliminated one of
the arrays entirely.  We now just have an array of net_device pointers
indexed by channel, which we need since we get packets from the hardware
and are only given the channel.  To get the device, we have to look it up
in the array.

Since this is now the only array of net_device pointers, I eliminated the
bychannel*() API I discussed in the previous email, since its use didn't
seem as compelling any more.

>> Let's keep the "normal" tile_net_devs[] as is, indexed by devno, and make
>> the tile_net_devs_for_channel[] more abstracted by using the following code:
> The tile_net_devs still feels dirty. You basically only
> use it in tile_net_handle_egress_timer(), but there you don't
> actually take the mutex that protects addition and removal from
> the array, so it's racy in case of hotplug.

We don't free the net_device structures themselves, so it's safe to do a
lookup in the array and then dereference the net_device pointer even if we
are doing an "ifconfig down" in another thread.  The only way you could
imagine the net_device getting structures getting freed was via module
unload, but it turns out that was pretty broken anyway, so I've just
removed it altogether in the latest version of the patch.  So once you have
a net_device pointer, it remains valid.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
