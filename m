From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Sat, 23 Feb 2013 15:43:23 -0800
Message-ID: <5129541B.4030806@schaufler-ca.com>
References: <1803195.0cVPJuGAEx@sifl> <5127F874.1050907@schaufler-ca.com> <1968537.V0Fsdryuo8@sifl>
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
In-Reply-To: <1968537.V0Fsdryuo8@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/2013 4:45 PM, Paul Moore wrote:
> On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
>> Please add an LSM blob. Please do not use a secid. I am currently
>> battling with secids in my efforts for multiple LSM support.
>>
>> ...
>>
>> I am going to be able to deal with secids for AF_INET only because
>> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
>> be willing to have networking be optional.
> "prefers"?  Really Casey, did you think I would let you get away with that 
> statement?  What a LSM "prefers" is really not relevant to the stacking 
> effort, what a LSM _supports_ is what matters.

I suppose. My point, which you may refute if it is incorrect,
is that there are common, legitimate SELinux configurations which
eschew Netlabel in favor of XFRM.

> SELinux _supports_ NetLabel (CIPSO, etc.), XFRM (labeled IPsec), and secmark.
>
> Smack _supports_ NetLabel (CIPSO).
>
> AppArmor and TOMOYO don't really do any of the forms of labeled networking 
> that are relevant for this discussion.

I am informed that labeled networking is being developed as an
option for AppArmor.

> If you are going to do stacking with 
> LSMs that conflict when it comes to what they _support_, not what they 
> _prefer_, with labeled networking then you are either going to have to either:
>
> 1. Selectively remove support from all but one of the LSMs. (ungh ...)
> 2. Convince netdev to give you a blob in the sk_buff. (the pigs are flying!)
> 3. Work some sub-system dependent magic.

With those being the possibilities, the choice is pretty obvious.
(It's 3, just in case the reader is unfamiliar with the histories
involved)

> If you want to try option #3 I think we might be able to do something with 
> NetLabel to support multiple LSMs as the label abstraction stuff should 
> theoretically make this possible; although the NetLabel cache will need some 
> work.

It is reasonably easy to restrict Netlabel to a single LSM,
and since SELinux seems better served by XFRM in most configurations
and AppArmor intends to make networking an option that seems
like a viable strategy until Netlabel gets multiple LSM support.

> Labeled IPsec is likely out due to the way it was designed unless you 
> want to attempt to negotiate two labels during the IKE exchange (yuck).  I 
> think we can also rule out secmark as multi-LSM enabled due to the limitations 
> on a 32 bit integer.

That was my take as well. But, since only SELinux uses those currently,
and I see little pressure for Smack to support them I don't have
a lot of incentive in that direction.

> If you want to talk about this further let me know - I think we've talked 
> about this at the past two security summits - but don't attempt to gloss over 
> details with this "prefers" crap.

Sorry if I presented my position poorly. I'm not trying to
gloss over details, and I apologize if I gave offense or made
statements that disrupted the harmony of the community.

>
>> If you have two LSMs that use secids you are never going to have a
>> rational way to get the information for both into one secid.
> Exactly, I don't disagree which is why I've always said that networking was 
> going to be a major problem for the stacked LSM effort.  Unfortunately it 
> sounds like you haven't yet made any serious effort into resolving that 
> problem other than saying "don't do that".

Oh believe me, I have made serious effort. I just haven't made
significant progress. The good news is that there can be a
networking configuration (SELinux with XFRM, Smack with Netlabel,
AppArmor with none) that is both supported and rational.

Options I have considered include:
	- Netlabel support for discriminating LSM use by host,
	  just as it currently allows for unlabeled hosts.
	- Netlabel as an independent LSM. Lots of refactoring.
	- secid maps.
	- Remove secids completely in favor of blobs.

I should have an updated patch set by month's end. I think it
will address the current LSM issues. I don't know that I can
say it will address everything new LSMs might want to try.

> Now, circling back to the issue of secid/blob in the AF_VSOCK/VMCI context ... 
> based on Andy's email I think I'm still missing some critical bit of 
> understanding regarding how VMCI is used so let's punt on this for a moment; 
> however, your preference for a blob is noted (you also remember that I prefer 
> blobs when they make sense, reference a lot of our earlier discussions).

Indeed. Thank you. A blob can contain sub-blobs. A secid is just
a number at the whim of an LSM.

Thanks. Sorry 'bout the whole "prefer" bruhaha.

