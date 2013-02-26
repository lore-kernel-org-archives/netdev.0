From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: LSM stacking and the network access controls
Date: Tue, 26 Feb 2013 15:12:31 -0800
Message-ID: <512D415F.7050205@schaufler-ca.com>
References: <1803195.0cVPJuGAEx@sifl> <1495862.ttoqQE2oSv@sifl> <512BEE66.9030405@schaufler-ca.com> <1495594.zrMMDNjium@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1495594.zrMMDNjium@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/26/2013 1:21 PM, Paul Moore wrote:
> On Monday, February 25, 2013 03:06:14 PM Casey Schaufler wrote:
>> On 2/25/2013 1:05 PM, Paul Moore wrote:
>>> On Monday, February 25, 2013 10:02:42 AM Casey Schaufler wrote:
>>>> On 2/25/2013 8:55 AM, Paul Moore wrote:
>>>>> [NOTE/WARNING: we're veering away from the VSOCK discussion and towards
>>>>> a LSM stacking discussion; see my response to Gerd if you want to stay
>>>>> on topic.]
>>>>>
>>>>> On Saturday, February 23, 2013 03:43:23 PM Casey Schaufler wrote:
>>>>>> On 2/22/2013 4:45 PM, Paul Moore wrote:
>>>>>>> On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
>>>>>>>> Please add an LSM blob. Please do not use a secid. I am currently
>>>>>>>> battling with secids in my efforts for multiple LSM support.
>>>>>>>>
>>>>>>>> ...
>>>>>>>>
>>>>>>>> I am going to be able to deal with secids for AF_INET only because
>>>>>>>> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
>>>>>>>> be willing to have networking be optional.
>>>>>>> "prefers"?  Really Casey, did you think I would let you get away with
>>>>>>> that statement?  What a LSM "prefers" is really not relevant to the
>>>>>>> stacking effort, what a LSM _supports_ is what matters.
>>>>>> I suppose. My point, which you may refute if it is incorrect,
>>>>>> is that there are common, legitimate SELinux configurations which
>>>>>> eschew Netlabel in favor of XFRM.
>>>>> There are common, legitimate use cases which use exclusively NetLabel,
>>>>> exclusively labeled IPsec, and both.  A LSM stacking design that forces
>>>>> SELinux to only operate with XFRM (labeled IPsec) is wrong.  If you are
>>>>> giving admins the ability to selectively stack LSMs you should also
>>>>> allow them to selectively pick which non-shareable functionality they
>>>>> assign to each LSM.
>>>> That is the approach I'm taking. The kernel configuration
>>>> will specify which LSM gets Netlabel and which gets XFRM.
>>> Okay, it wasn't obvious to me in your previous emails that this was the
>>> case. Also, just so I'm clear, you configure the stacking and the stacked
>>> network access controls at the same time, yes?  I want to avoid the
>>> situation where the stacked network access controls are determined at
>>> build time and the LSM stacking order/configuration is determined at
>>> boot.
>> The set of LSMs, the order they are invoked, which LSM
>> uses /proc/.../attr/current and which LSM uses Netlabel,
>> XFRM and secmark are all determined by Kconfig. You can
>> specify a limited set of LSMs using security= at boot,
>> but not the networking configuration.
> That's unfortunate.  I'm _really_ not in favor of that, I would much rather 
> see the non-shared LSM functionality assigned at the same time as the stacking 
> order.  I'm not sure I'd NACK the current approach, or even if anyone would 
> care that I did, but that is how I'm currently leaning with this split (build 
> vs runtime) selection.

I'm not against that approach. How would you see it working?

The distro compiles in all the LSMs.
They specify that SELinux gets xfrm and secmark.
They specify the Smack gets Netlabel.
They tell (the new and improved) AppArmor to eschew networking.
They specify a boot order of "selinux,smack,apparmor,yama"
(They left off tomoyo for tax purposes).

On the boot line, the user types "security=apparmor".

What should happen?

>  
>> Tetsuo is lobbying for loadable security modules. I am
>> doing my best to leave everything in a state where some
>> soul braver than I might pick that up after I'm done.
>> I do not have any intention of supporting on the fly
>> or heuristically determined networking.
> Well, if that is the case I think the first-come-first-served approach to the 
> non-shared functionality probably makes the most sense.  I understand why it 
> might not be ideal in ever situation but it is predictable.

Would you have the same opinion if SELinux were last,
instead of first? SELinux is the most feature rich of
the LSMs and no other LSM would ever get networking in
the presence of SELinux.


>>>> I'm trying not to make too many architectural changes to the
>>>> code around the LSM mechanism itself. I don't see that as cost
>>>> effective or likely to be popular. If the implication of that is
>>>> that there are certain configurations that are unsupportable but
>>>> that have plausible alternatives I think it will do for phase I.
>>> That statement is vague enough that I can't really say yes or no to it,
>>> but I will stick by my previous comments about the network access
>>> controls.
>> Ah. I want to create a useful system. I want to create it
>> reasonably short order. I am willing to forgo supporting
>> some configuration options to reduce the project time. In
>> particular, I hope to avoid mucking up other people's code
>> as that is a sure fire way to bog a project down.
> Usefulness is paramount of course

Agreed

> and quickness is nice,

If it drags on too long the boss gets cranky. And "labelled" NFSv4.2
gets done. And the list macros get reworked. And ....

> but I do think it takes a back seat to "the right solution".

If I had two years and didn't have to worry about anyone else's
changes and weren't beholden to retaining some of the past's more
interesting design choices I'd be more concerned about "right" than
"good".

> We're all going to have to live with this f-o-r-e-v-e-r,

Assuming it gets adopted. It will have to be good enough for that.
There is no guarantee on that.

> or at least what will surely seem like it, so I'd 
> much rather we take the time to make sure we beat out as much ugly as we can 
> before it is merged.

I'm with you there. I just hope the ugly hasn't been lifting weights.

 

>>>>>> Options I have considered include:
>>>>>> 	- Netlabel support for discriminating LSM use by host,
>>>>>> 	
>>>>>> 	  just as it currently allows for unlabeled hosts.
>>>>> Hmm, interesting ... not sure what I think of this.
>>>> It breaks down on 127.0.0.1. Otherwise is looks pretty easy to do.
>>> When I said I wasn't sure what I thought of this, it was more along the
>>> lines of I'm not sure if it makes sense, not that it would be difficult
>>> to do.
>> It makes sense if you're in a network environment with heterogeneous
>> legacy multilevel secure systems and you want some of those machines
>> to talk to SELinux controlled processes and others to talk to Smack
>> controlled processes. That is unlikely to be an industry dominating
>> scenario.
> Well, you can talk MLS labeled networking to both SELinux and Smack, and you 
> can talk MLS labeled networking between SELinux and Smack already (hip, hip, 
> hooray for commonly accepted standards!)

And Paul gets a pat on the back! The crowd goes wild!

> so I'm not sure you need this.  
> Although I suppose it might simplify the configuration in some cases or help 
> if you're trying to migrate from one LSM to another.

It's a nutty scenario. It would allow Smack and SELinux to divide the
hosts amongst them, and if SELinux wasn't going to use Netlabel for
on the box (127.0.0.1) communications anyway, Smack could use that
and be very happy.

