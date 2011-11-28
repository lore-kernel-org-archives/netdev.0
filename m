From: "Fischer, Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 13:54:16 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org"
	<jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111128130409.GB16828-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [GIT PULL v2] Open vSwitch
> 
> On Wed, Nov 23, 2011 at 07:22:56AM -0500, jamal wrote:
> >
> > For a classifier, u32 or em matches would do the job  - but they may
> > need a wrapper around it in user space; so from a usability pov, it
> > would make sense to have a new classifier that is specific to them.
> > All the VLAN actions could go into one tc action; the checksum action
> > is already present. The IP/TCP/UDP header re-writes may require
> > their own actions - I think one would be sufficient for all.
> > So in my estimate one classifier and two actions.
> > Then you get rid of half the code (they use generic netlink to
> set/get
> > policies)
> 
> You're right, a new classifier for the hash table would be the
> best option.
> 
> > I cant find one - you may. After staring at the code, I am also now
> > questioning if the existing bridge code couldnt have been re-used
> with
> > some small tweaks.
> 
> I wasn't able to find any functionality that could not be easily
> done with the existing classifier/action code.
> 
> Whether we want to go down this route though is open to debate
> as someone would have to actually implement this :)
> 
> However, what's more worrying for me right now is the gaping
> DoS opportunities that exist in the patch as is.
> 
> In particular, the whole design principle of punting all new
> flows to user-space is an excellent way of attacking the system.
> 
> A would-be attacker would only need to continuously inject new
> flows to prevent flow creation on all ports, since every single
> port on a data path shares the same receive queue in user-space.
> 
> Considering that this is meant to be used in virtualisation
> environments, where hostile entities may indeed exist on the
> network, I think this needs to be addressed.

Yes, I mentioned this months ago, and I am surprised this critical issue has never been picked up on and addressed. With a flaw like this there is no chance this component can be used in any serious virtualization deployment where different customers share the same physical server.

The path up to user-space needs to be designed in a multi-queue fashion, so that each vPort has its own queue up to user-space. Ideally those queues also need to be rate controlled in some form, so that no DoS is possible.
