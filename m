From: Laura Abbott <labbott@redhat.com>
Subject: Re: [PATCH v2 net-next] net/core: ensure features get disabled on new
 lower devs
Date: Fri, 13 Nov 2015 14:31:44 -0800
Message-ID: <564664D0.9020007@redhat.com>
References: <1446583017-19021-1-git-send-email-jarod@redhat.com>
 <1446610172-21420-1-git-send-email-jarod@redhat.com>
 <20151104.215632.964832400121049446.davem@davemloft.net>
 <56452E2A.9050501@gmail.com> <20151113102903.GB2143@nanopsycho.orion>
 <5645C0A5.2080506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarod@redhat.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	razor@blackwall.org, mkubecek@suse.cz, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5645C0A5.2080506@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2015 02:51 AM, Nikolay Aleksandrov wrote:
> On 11/13/2015 11:29 AM, Jiri Pirko wrote:
>> Fri, Nov 13, 2015 at 01:26:18AM CET, f.fainelli@gmail.com wrote:
>>> On 04/11/15 18:56, David Miller wrote:
>>>>> Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
>>>>   ...
>>>>> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>>>> ---
>>>>> v2: Based on suggestions from Alex, and with not changing err to ret, this
>>>>> patch actually becomes quite minimal and doesn't ugly up the code much.
>>>>
>>>> Applied, thanks.
>>>
>>> This causes some warnings to be displayed for DSA stacked devices:
>>>
>>> [    1.272297] brcm-sf2 f0b00000.ethernet_switch: Starfighter 2 top:
>>> 4.00, core: 2.00 base: 0xf0c80000, IRQs: 68, 69
>>> [    1.283181] libphy: dsa slave smi: probed
>>> [    1.344088] f0b403c0.mdio:05: Broadcom BCM7445 PHY revision: 0xd0,
>>> patch: 3
>>> [    1.658917] brcm-sf2 f0b00000.ethernet_switch gphy (uninitialized):
>>> attached PHY at address 5 [Broadcom BCM7445]
>>> [    1.669414] brcm-sf2 f0b00000.ethernet_switch gphy: set_features()
>>> failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>>> [    1.734202] brcm-sf2 f0b00000.ethernet_switch rgmii_1
>>> (uninitialized): attached PHY at address 0 [Generic PHY]
>>> [    1.744486] brcm-sf2 f0b00000.ethernet_switch rgmii_1: set_features()
>>> failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>>> [    1.809091] brcm-sf2 f0b00000.ethernet_switch rgmii_2
>>> (uninitialized): attached PHY at address 1 [Generic PHY]
>>> [    1.819364] brcm-sf2 f0b00000.ethernet_switch rgmii_2: set_features()
>>> failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>>> [    1.884090] brcm-sf2 f0b00000.ethernet_switch moca (uninitialized):
>>> attached PHY at address 2 [Generic PHY]
>>> [    1.894109] brcm-sf2 f0b00000.ethernet_switch moca: set_features()
>>> failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>>>
>>> DSA slave network devices are not associated with their master network
>>> device using the typical lower/upper netdev helpers.
>>>
>>> I do not have a good fix to come up with yet, but if you see something
>>> obvious with net/dsa/slave.c, feel free to send patches for testing, I
>>> can boot net-next on this platform.
>>
>> I'm having similar issues with bridge, with linus's git now:
>>
> [snip]
>
> Hmm, I think it's because the bridge and dsa/slave don't have ndo_set_features()
> so err is left as -1 and thus an error is reported which isn't actually true.
> Before in this case the features would just get set, so could you please try
> the following patch ?
>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ab9b8d0d115e..4a1d198dbbff 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6426,6 +6426,8 @@ int __netdev_update_features(struct net_device *dev)
>
>   	if (dev->netdev_ops->ndo_set_features)
>   		err = dev->netdev_ops->ndo_set_features(dev, features);
> +	else
> +		err = 0;
>
>   	if (unlikely(err < 0)) {
>   		netdev_err(dev,


The patch seems to be working for at least one person who reported the
problem in Fedora rawhide https://bugzilla.redhat.com/show_bug.cgi?id=1281674

Thanks,
Laura
