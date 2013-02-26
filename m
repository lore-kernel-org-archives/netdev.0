From: Paul Moore <pmoore@redhat.com>
Subject: LSM stacking and the network access controls (was: AF_VSOCK and the LSMs)
Date: Tue, 26 Feb 2013 16:21:37 -0500
Message-ID: <1495594.zrMMDNjium@sifl>
References: <1803195.0cVPJuGAEx@sifl> <1495862.ttoqQE2oSv@sifl> <512BEE66.9030405@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <512BEE66.9030405@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, February 25, 2013 03:06:14 PM Casey Schaufler wrote:
> On 2/25/2013 1:05 PM, Paul Moore wrote:
> > On Monday, February 25, 2013 10:02:42 AM Casey Schaufler wrote:
> >> On 2/25/2013 8:55 AM, Paul Moore wrote:
> >>> [NOTE/WARNING: we're veering away from the VSOCK discussion and towards
> >>> a LSM stacking discussion; see my response to Gerd if you want to stay
> >>> on topic.]
> >>> 
> >>> On Saturday, February 23, 2013 03:43:23 PM Casey Schaufler wrote:
> >>>> On 2/22/2013 4:45 PM, Paul Moore wrote:
> >>>>> On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
> >>>>>> Please add an LSM blob. Please do not use a secid. I am currently
> >>>>>> battling with secids in my efforts for multiple LSM support.
> >>>>>> 
> >>>>>> ...
> >>>>>> 
> >>>>>> I am going to be able to deal with secids for AF_INET only because
> >>>>>> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
> >>>>>> be willing to have networking be optional.
> >>>>> 
> >>>>> "prefers"?  Really Casey, did you think I would let you get away with
> >>>>> that statement?  What a LSM "prefers" is really not relevant to the
> >>>>> stacking effort, what a LSM _supports_ is what matters.
> >>>> 
> >>>> I suppose. My point, which you may refute if it is incorrect,
> >>>> is that there are common, legitimate SELinux configurations which
> >>>> eschew Netlabel in favor of XFRM.
> >>> 
> >>> There are common, legitimate use cases which use exclusively NetLabel,
> >>> exclusively labeled IPsec, and both.  A LSM stacking design that forces
> >>> SELinux to only operate with XFRM (labeled IPsec) is wrong.  If you are
> >>> giving admins the ability to selectively stack LSMs you should also
> >>> allow them to selectively pick which non-shareable functionality they
> >>> assign to each LSM.
> >> 
> >> That is the approach I'm taking. The kernel configuration
> >> will specify which LSM gets Netlabel and which gets XFRM.
> > 
> > Okay, it wasn't obvious to me in your previous emails that this was the
> > case. Also, just so I'm clear, you configure the stacking and the stacked
> > network access controls at the same time, yes?  I want to avoid the
> > situation where the stacked network access controls are determined at
> > build time and the LSM stacking order/configuration is determined at
> > boot.
> 
> The set of LSMs, the order they are invoked, which LSM
> uses /proc/.../attr/current and which LSM uses Netlabel,
> XFRM and secmark are all determined by Kconfig. You can
> specify a limited set of LSMs using security= at boot,
> but not the networking configuration.

That's unfortunate.  I'm _really_ not in favor of that, I would much rather 
see the non-shared LSM functionality assigned at the same time as the stacking 
order.  I'm not sure I'd NACK the current approach, or even if anyone would 
care that I did, but that is how I'm currently leaning with this split (build 
vs runtime) selection.
 
> Tetsuo is lobbying for loadable security modules. I am
> doing my best to leave everything in a state where some
> soul braver than I might pick that up after I'm done.
> I do not have any intention of supporting on the fly
> or heuristically determined networking.

Well, if that is the case I think the first-come-first-served approach to the 
non-shared functionality probably makes the most sense.  I understand why it 
might not be ideal in ever situation but it is predictable.

> >> I'm trying not to make too many architectural changes to the
> >> code around the LSM mechanism itself. I don't see that as cost
> >> effective or likely to be popular. If the implication of that is
> >> that there are certain configurations that are unsupportable but
> >> that have plausible alternatives I think it will do for phase I.
> > 
> > That statement is vague enough that I can't really say yes or no to it,
> > but I will stick by my previous comments about the network access
> > controls.
>
> Ah. I want to create a useful system. I want to create it
> reasonably short order. I am willing to forgo supporting
> some configuration options to reduce the project time. In
> particular, I hope to avoid mucking up other people's code
> as that is a sure fire way to bog a project down.

Usefulness is paramount of course and quickness is nice, but I do think it 
takes a back seat to "the right solution".  We're all going to have to live 
with this f-o-r-e-v-e-r, or at least what will surely seem like it, so I'd 
much rather we take the time to make sure we beat out as much ugly as we can 
before it is merged.
 
> >>>> Options I have considered include:
> >>>> 	- Netlabel support for discriminating LSM use by host,
> >>>> 	
> >>>> 	  just as it currently allows for unlabeled hosts.
> >>> 
> >>> Hmm, interesting ... not sure what I think of this.
> >> 
> >> It breaks down on 127.0.0.1. Otherwise is looks pretty easy to do.
> > 
> > When I said I wasn't sure what I thought of this, it was more along the
> > lines of I'm not sure if it makes sense, not that it would be difficult
> > to do.
>
> It makes sense if you're in a network environment with heterogeneous
> legacy multilevel secure systems and you want some of those machines
> to talk to SELinux controlled processes and others to talk to Smack
> controlled processes. That is unlikely to be an industry dominating
> scenario.

Well, you can talk MLS labeled networking to both SELinux and Smack, and you 
can talk MLS labeled networking between SELinux and Smack already (hip, hip, 
hooray for commonly accepted standards!) so I'm not sure you need this.  
Although I suppose it might simplify the configuration in some cases or help 
if you're trying to migrate from one LSM to another.

-- 
paul moore
security and virtualization @ redhat

