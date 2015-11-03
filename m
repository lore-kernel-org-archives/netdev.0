From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 3 Nov 2015 15:01:57 -0800
Message-ID: <56393CE5.50704@gmail.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
 <1446583017-19021-1-git-send-email-jarod@redhat.com>
 <5639245D.7000501@gmail.com> <56393127.4050406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56393127.4050406@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2015 02:11 PM, Jarod Wilson wrote:
> Alexander Duyck wrote:
>> On 11/03/2015 12:36 PM, Jarod Wilson wrote:
>>> With moving netdev_sync_lower_features() after the .ndo_set_features
>>> calls, I neglected to verify that devices added *after* a flag had been
>>> disabled on an upper device were properly added with that flag
>>> disabled as
>>> well. This currently happens, because we exit 
>>> __netdev_update_features()
>>> when we see dev->features == features for the upper dev. We can retain
>>> the
>>> optimization of leaving without calling .ndo_set_features with a bit of
>>> tweaking and a goto here.
>>>
>>> Changing err to ret was somewhat arbitrary and makes the patch look 
>>> more
>>> involved, but seems to better fit the altered use.
> ...
>>> +     if (!ret) {
>>> +         dev->features = features;
>>> +         ret = 1;
>>> +     }
>>> +
>>
>> I would take the "ret = 1;" out of the if statement and let it stay here
>> by itself. Technically anything that traversed this path was returning 1
>> previously so we probably want to retain that behavior.
>
> Ah, that. I took a look at all the callers of 
> __netdev_update_features, and most don't even check return value, the 
> one that does (netdev_update_features) only cares if its zero or not 
> zero, so I figured it didn't really matter here, but it would indeed 
> return 2 now instead of 1, if it got that from ndo_set_features. For 
> consistency's sake, I can respin and just always set ret = 1 though.

One thought I just had would be to make it so that we assign -1 to ret 
and then jump inside the earlier features==features check rather than 
altering the ret value here.  Then we could just use a ternary value at 
the end and just do "return ret < 0 ? 0 : 1;".  That would take care of 
the return values and the features flag you called out below.

>>> +sync_lower:
>>>     /* some features must be disabled on lower devices when disabled
>>>      * on an upper device (think: bonding master or bridge)
>>>      */
>>>     netdev_for_each_lower_dev(dev, lower, iter)
>>>         netdev_sync_lower_features(dev, lower, features);
>>>
>>> -     if (!err)
>>> -         dev->features = features;
>>
>> You could just alter the if statement here to check for a non-zero ret
>> value since you should have it as either 0 or 1. It shouldn't have any
>> other values.
>>
>> That way you will have disabled the feature on the lower devices before
>> advertising that it has been disabled on the upper device.
>
> If this check is down here, the goto will trigger, setting 
> dev->features = features, but then, we got there because dev->features 
> == features already, so meh. But it would also NOT trigger in the case 
> of ndo_set_features returning 0 anymore, because we set ret = 1. Or am 
> I missing something or misunderstanding what you're suggesting here?
>
