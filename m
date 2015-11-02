From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net-next] net/core: initial support for stacked dev
 feature toggles
Date: Mon, 02 Nov 2015 12:37:57 -0500
Message-ID: <56379F75.2000606@redhat.com>
References: <1445658019-58621-1-git-send-email-jarod@redhat.com> <562B1C4D.8050407@gmail.com> <20151026094213.GA1715@unicorn.suse.cz> <56339A08.8000205@redhat.com> <5633CCED.7060602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5633CCED.7060602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Duyck wrote:
> On 10/30/2015 09:25 AM, Jarod Wilson wrote:
...
>> Rather than outright dropping the second bit though, I was thinking
>> maybe just drop a note in dmesg along the lines of "hey, you shut off
>> LRO, it is still enabled on upper dev foo", to placate end-users.
>
> I would rather not see it. It would be mostly noise. It is perfectly
> valid to have LRO advertised on an upper device, but not supported on a
> lower one. It basically just means that the path will allow LRO frames
> through, it doesn't guarantee that we are going to provide them.

Okay, dropping this.

...
>>>> Same thing here. If a lower dev has it disabled then leave it
>>>> disabled. I believe your goal is to make it so that
>>>> dev_disable_lro() can shut down LRO when it is making packets in the
>>>> data-path unusable.
>>>
>>> This is already the case since commit fbe168ba91f7 ("net: generic
>>> dev_disable_lro() stacked device handling"). That commit makes sure
>>> dev_disable_lro() is propagated down the stack and also makes sure new
>>> slaves added to a bond/team with LRO disabled have it disabled too.
>>>
>>> What it does not do is propagating LRO disabling down if it is disabled
>>> in ways that do not call dev_disable_lro() (e.g. via ethtool). I'm not
>>> sure if this should be done or not, both options have their pros and
>>> cons.
>>
>> Making it work with ethtool was one of my primary goals with this
>> change, as it was users prodding things with ethtool that prompted the
>> "hey, this doesn't make sense" bug reports.
>
> I'd say make it work like dev_disable_lro already does. Disabling LRO
> propagates down, enabling LRO only enables it on the specific device.
>
> The way to think of it is as a warning flag. With LRO enabled this
> device may report frames larger than MTU to the stack and will mangle
> checksums. Without LRO all of the frames received should be restricted
> to MTU. That is why you have to force the disabling down to all lower
> devices, and why you cannot enable it if an upper device has it disabled.
>
>>> However, I believe enabling LRO shouldn't be propagated down.
>>
>> Hm. Devices that should never have LRO enabled still won't get it
>> enabled, so I'm not clear what harm it would cause.I tend to think you
>
> How do you define "devices that should never have LRO enabled"?

No NETIF_F_LRO flag set in hw_features is what I was thinking.

> The fact
> is LRO is very messy in terms of the way it functions. Different drivers
> handle it different ways. Usually it results in the Rx checksum being
> mangled, it provides frames larger than MTU, and uses fraglist instead
> of frags on some drivers.
>
>> do want this sync'ing down the stack if set on an upper dev (i.e.,
>> ethtool -K bond0 lro on), for consistency's sake. You can always come
>> back through afterwards and disable things on lower devs individually if
>> they're really not wanted, since we're in agreement that we shouldn't
>> prevent disabling features on lower devices.
>
> Think of it this way. Lets say I have a NIC that I know is problematic
> when LRO is enabled, it might cause a kernel panic due to an skb
> overrun. So I have a bond with it and some other NIC which can run with
> LRO enabled without issues. How do I enable LRO on the other device
> without causing a kernel panic, and without tearing apart the existing
> bond? With the approach you have described I can't because I have to
> enable it at the bond and doing so will enable it on the NIC with the
> faulty implementation.

I'd argue that if enabling LRO on a device causes a panic, that device 
probably shouldn't be advertising LRO support, and the driver ought to 
be fixed, but that's somewhat tangential. I'm already sold on only 
disabling down the stack.

> This is why we cannot enable LRO unless all upper devices support it,
> and why we should propagate disabling LRO down to all lower devices.
> Trying to force it on for a lower device just because the upper device
> supports it is a bad idea because there are multiple LRO implementations
> and they all behave very differently.

That's a bit concerning, given that we default to LRO on in a bond, as 
should all the slaves, regardless of which LRO implementation the device 
has (so long as the driver claims to support LRO, anyway).

But again, that's probably a separate issue, I've got a forthcoming 
patch that I'm still beating around and touching up, but I think looks 
sane and lines up with what you've suggested.

> If nothing else you might start looking at working with a mask of
> bits that function like this.  You could probably start with GRO,
> LRO, and RXCSUM and work your way up from there.  If they aren't set
> on the upper devices you cannot enable them, and if they are cleared
> then they must be cleared on all lower devices.

For step one, I've added a feature mask and a new helper that iterates 
over it looking for set feature flags. In the case of the bnx2x equipped 
host I'm currently testing on, adding RXCSUM had an interesting and as 
yet unexplained side-effect of preventing LRO from being enabled on the 
bnx2x cards -- ethtool showed "off [requested on]".

-- 
Jarod Wilson
jarod@redhat.com
