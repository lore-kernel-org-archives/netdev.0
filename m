From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Fri, 27 Aug 2010 10:55:23 +0300
Message-ID: <1282895723.2006.135.camel@powerslave>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
	 <1282570935.7198.5.camel@powerslave>
	 <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
	 <1282589101.7198.28.camel@powerslave>
	 <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>
	 <1282633220.7198.123.camel@powerslave>
	 <alpine.LNX.2.01.1008240921230.24349@obet.zrqbmnf.qr>
	 <1282720198.18016.72.camel@powerslave>
	 <alpine.LNX.2.01.1008251103150.24022@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>,
	=?ISO-8859-1?Q?M=E4kel=E4?= Juhani
	<ext-juhani.3.makela@nokia.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1008251103150.24022@obet.zrqbmnf.qr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan,

On Wed, 2010-08-25 at 11:04 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-08-25 09:09, Luciano Coelho wrote:
> >> 
> >> Indeed so. But you did not invent any new interface. You are reusing
> >> files, which can be protected by DAC modes, or LSMs doing
> >> funky-stuff. xt_{condition,recent,..} already implement file modes,
> >> but does it check for it? Well no, because fs/namei.c does it for
> >> them. As for LSMs, well, I hope they do cater for testing for
> >> capability bits.
> >
> >I dug deeper into the code and I can see that /sys/net has capability
> >checks (implemented in netdev_store() in net-sysfs.c) and nobody without
> >CAP_NET_ADMIN will be able to write to the files there.  But in procfs I
> >couldn't see anything similar and anyone with file write permissions can
> >modify the files in /proc/net/*.
> 
> I did not say there was. fs/ will handle the DAC part, and if you
> wanted MAC/capability checking/other sparkles, an LSM sounds like
> the right spot.

There is one fundamental difference that I forgot to point out.  While
in most cases netfilters are used by _sysadmins_ to route and control
traffic, we are using it in a very different way.  Our goal is to check
throughput and other connection characteristics to control power saving
and other features in an embedded device.  In such devices we typically
have one single user and the sysadmin is us who define all the rules and
pre-install them in the device beforehand.  We need to prevent binaries
rather than users from doing bad things.  Using basic DAC extensively to
do this may end up getting messy.

That's what I tried to say when I said that we have a security team
taking care of this.  They are implementing solutions to make the
product more secure, defending it against malware, misuse, attacks and
other such things.  In this specific case, security-wise, we are trying
to prevent some bogus or malicious application from changing our
netfilter rules and causing havoc.

LSM doesn't seem to be an option, here I quote Juhani (my colleague from
our security team):

> The problem with capabilites is that they are assigned to binaries, not
> users. Kind of a setuid-mechanism, really. In our embedded environment
> that makes a lot of sense, but in a server-type environment with
> multiple users and a competent sysadmin, not so much. In such an
> environment using a LSM might also actually make sense. But for us it's
> not an option, mostly because LSMs are not stackable - you can have only
> one effective at any time - and I'm afraid we have already reserved some
> of the LSM hooks.

Maybe Juhani can clarify this a bit more.

One other idea that Juhani had was to add an option to the condition
match/target where the capability requiremets could be set, instead of
checking them by default.  If nothing is specified, everything still
works as before (no caps checks).  Or even a Kconfig option?

I don't see any other option for checking the capabilities besides doing
it in the xt_condition module itself.  Or maybe move the condition
variable from procfs to sysfs and use the existing netdev_store
protection that is implemented there? The problem with the latter is the
same old story we discussed with the idletimer target: where in the
kernel object tree should the variable be added?


-- 
Cheers,
Luca.

