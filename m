From: Paul Moore <pmoore@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Mon, 25 Feb 2013 11:55:06 -0500
Message-ID: <5429810.RVpOLLsSs4@sifl>
References: <1803195.0cVPJuGAEx@sifl> <1968537.V0Fsdryuo8@sifl> <5129541B.4030806@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5129541B.4030806@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NOTE/WARNING: we're veering away from the VSOCK discussion and towards a LSM 
stacking discussion; see my response to Gerd if you want to stay on topic.]

On Saturday, February 23, 2013 03:43:23 PM Casey Schaufler wrote:
> On 2/22/2013 4:45 PM, Paul Moore wrote:
> > On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
> >> Please add an LSM blob. Please do not use a secid. I am currently
> >> battling with secids in my efforts for multiple LSM support.
> >> 
> >> ...
> >> 
> >> I am going to be able to deal with secids for AF_INET only because
> >> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
> >> be willing to have networking be optional.
> > 
> > "prefers"?  Really Casey, did you think I would let you get away with that
> > statement?  What a LSM "prefers" is really not relevant to the stacking
> > effort, what a LSM _supports_ is what matters.
> 
> I suppose. My point, which you may refute if it is incorrect,
> is that there are common, legitimate SELinux configurations which
> eschew Netlabel in favor of XFRM.

There are common, legitimate use cases which use exclusively NetLabel, 
exclusively labeled IPsec, and both.  A LSM stacking design that forces 
SELinux to only operate with XFRM (labeled IPsec) is wrong.  If you are giving 
admins the ability to selectively stack LSMs you should also allow them to 
selectively pick which non-shareable functionality they assign to each LSM.

> > SELinux _supports_ NetLabel (CIPSO, etc.), XFRM (labeled IPsec), and
> > secmark.
> > 
> > Smack _supports_ NetLabel (CIPSO).
> > 
> > AppArmor and TOMOYO don't really do any of the forms of labeled networking
> > that are relevant for this discussion.
> 
> I am informed that labeled networking is being developed as an
> option for AppArmor.

I've remember hearing the same several years ago too, until we see patches it 
doesn't make sense to spend a lot of time worrying about what the AppArmor 
developers plan to support.  Regardless, if anything I think this only 
furthers the need to provide a mechanism to selectively assign non-shareable 
LSM functionality to individuals LSMs in a stacked scenario.
 
> > If you want to try option #3 I think we might be able to do something with
> > NetLabel to support multiple LSMs as the label abstraction stuff should
> > theoretically make this possible; although the NetLabel cache will need
> > some work.
> 
> It is reasonably easy to restrict Netlabel to a single LSM,
> and since SELinux seems better served by XFRM in most configurations ...

I disagree.  In some use cases SELinux is better served by XFRM, in others it 
is better served by NetLabel.  Once again, I think you need to focus on what 
is possible with the LSMs rather than a particular set of use cases which 
happen to make the LSM stacking project easier.

> and AppArmor intends to make networking an option that seems
> like a viable strategy until Netlabel gets multiple LSM support.

It would be nice if the AppArmor developers could share their plans - or have 
I missed them on the list?  My apologies if that is the case, a pointer would 
be helpful ...

> > Labeled IPsec is likely out due to the way it was designed unless you
> > want to attempt to negotiate two labels during the IKE exchange (yuck).  I
> > think we can also rule out secmark as multi-LSM enabled due to the
> > limitations on a 32 bit integer.
> 
> That was my take as well. But, since only SELinux uses those currently,
> and I see little pressure for Smack to support them I don't have
> a lot of incentive in that direction.

Agreed.

> >> If you have two LSMs that use secids you are never going to have a
> >> rational way to get the information for both into one secid.
> > 
> > Exactly, I don't disagree which is why I've always said that networking
> > was going to be a major problem for the stacked LSM effort.  Unfortunately
> > it sounds like you haven't yet made any serious effort into resolving that
> > problem other than saying "don't do that".
> 
> Oh believe me, I have made serious effort. I just haven't made
> significant progress.

True, that wasn't a fair comment for me to make - my apologies.

> The good news is that there can be a networking configuration (SELinux with
> XFRM, Smack with Netlabel, AppArmor with none) that is both supported and
> rational.

I disagree that the approach you are proposing is the one that should be 
adopted.  I am very much in favor of providing the ability to selectively 
assign non-shareable LSM features when stacking.  If you aren't able to create 
a mechanism to assign features when stacking, I think I would be more in favor 
of a "first come, first served" model (the first LSM gets whatever it wants, 
and each LSM stacked on top has to make do with what is left) over what you 
are currently proposing.

> Options I have considered include:
> 	- Netlabel support for discriminating LSM use by host,
> 	  just as it currently allows for unlabeled hosts.

Hmm, interesting ... not sure what I think of this.

> 	- Netlabel as an independent LSM. Lots of refactoring.

Ungh, no.

> 	- secid maps.

Can you elaborate on this?  I can think of a few different meanings here ...

> 	- Remove secids completely in favor of blobs.

Obviously ideal, but unlikely to happen unless the netdev crew change their 
mind on blobs in sk_buff.

> I should have an updated patch set by month's end. I think it
> will address the current LSM issues. I don't know that I can
> say it will address everything new LSMs might want to try.

I'll be sure to take a closer look then.  I should have taken a closer look at 
your previous patches - my mistake and I'll take responsibility for that - but 
based on the discussion from the last security summit I was under the 
impression that stacking was only going to be allowed between "big" and 
"little" LSMs, that is obviously no longer the case.

-- 
paul moore
security and virtualization @ redhat

