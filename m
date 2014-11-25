From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 08:30:19 -0800
Message-ID: <5474AE9B.6000500@intel.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com> <5474A7EE.8000300@intel.com> <5474ABF0.60901@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42494 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbaKYQb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 11:31:58 -0500
In-Reply-To: <5474ABF0.60901@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 08:18 AM, Jamal Hadi Salim wrote:
> On 11/25/14 11:01, John Fastabend wrote:
>> On 11/25/2014 07:38 AM, Jamal Hadi Salim wrote:
>>> On 11/25/14 05:28, Jiri Pirko wrote:
>>>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>>>> u16 vid to drivers from there.
>>>>
>>>
>>> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> I know this maintains status quo of what is already in the kernel.
>>> But we need to take care of policy (pass it from user space) which
>>> dictates how to proceed on failure. Three possible options:
>>> 1) If something fails just continue with the rest of the transaction.
>>> Return success if at least one thing succeeds.
>>
>> I'm not sure how (1) works. We can't just let user-space/management
>> software run along thinking its configuration is set when its
>> not. At least it doesn't look very appealing for the software I'm
>> looking at.
>>
> 
> Thats why it is a policy - just dont use it ;->
> IOW, if the user made that choice the consequences are clear i.e there
> is no confusion.
> Example:
> I could add 100 entries and if the 10th one failed for some reason to
> apply to software version, I want to continue adding as many as i can
> possibly add in the hardware etc.

Actually (after having some coffee) this becomes much more useful
if you return which items failed. Then you can slam the hardware
with your 100 entries, probably a lot more then that, and come back
later and clean it up.

> 
>>> 2) If something fails stop transaction and return some partial success code
>>
>> Option (2) is the current behavior of fdb this is straight forward
>> and punts the complexity to user space. And at least the state is
>> always known.
>>
> 
> I dont think we return "partial" success code, do we?
> I think we stop when  software fails and dont care if hardware fails.
> So this is status quo - we can do better..
> 

We return a bitmask of which operations were successful. So if SW fails
we have both bits cleared and we abort. When SW is successful we set the
SW bit and try to program the HW. If its sucessful we set the HW bit if
its not we abort with an err. Converting this to (1) is not much work
just skip the abort.

>>> 3) If something fails undo everything that has been done and return failure.
>>>
>>
>> Sure this would be nice to have when doing bulk updates and is more
>> useful on hardware that has a commit phase where updates don't actually
>> occur until they are committed.
>>
> 
> Indeed - i dont expect this option to be used as much but identifying
> as a need now is important.
> 
>>> So two bits from somewhere would be useful to send from userspace->kernel
>>>
>>
>> +1 for a follow up patch though.
>>
> 
> As long as we are not adding any new behavior - agreed.
> I dont see us doing that, so no controversy (hence my ACK).
> 
> cheers,
> jamal
> 
