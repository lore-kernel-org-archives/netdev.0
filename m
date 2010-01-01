From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Fri, 1 Jan 2010 14:57:01 +0000
Message-ID: <20100101145701.6432e7b7@lxorguk.ukuu.org.uk>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com>
	<m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091230212931.233003b9@lxorguk.ukuu.org.uk>
	<m1skasrvnq.fsf@fess.ebiederm.org>
	<20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
	<3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
	<20091231173334.5e3d7557@lxorguk.ukuu.org.uk>
	<20091231175257.GA7210@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bryan Donlan <bdonlan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schauf
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091231175257.GA7210@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> dereferencing task->security would be fine.  But finding a way to
> multiplex task->security so it can be used by Eric's nosuid lsm,
> Michael's disablenetwork LSM, and SELinux/smack/apparmor, that
> will likely take months, and, history shows, may never happen.

You assume firstly that it matters. If it doesn't matter and people don't
want to mix SELinux etc with weird little hacks then the problem doesn't
really arise anyway. If people do want to stack them then yes they'll
have to do the work. Diddums, thats how it works, and filling the kernel
with crap shortcuts just makes a bigger mess longer term and leaves a
huge mess to sort out.

There are lots of trivial ways to implement a fast lookup per security
context. The only real problem is figuring out how much space is needed
and that's fairly trivial to do providing you don't try and be clever and
reclaim slots unloading modules

You just need void * security and an offset allocated per security module
as its registered. We've even got library code to hand those out nicely
alloc and free them (leaving holes on unload and refilling on reload)

Then it all comes out as

lsm_context = (struct my_lsm_context *)(task->security + lsm->offset)

whoopee 1 clock.

You pay a cost at LSM load time (which is extremely rare) to update all
the tasks and introduce them to the LSM but you need to do that anyway to
initialise your LSM state for each task.

If people were serious about doing the work right rather than just trying
to dump their pet neat idea into the kernel with no care about the cost
I'd expect to see patches for sharing ->security, LSM stacking first.
They are not hard technically.

There are real issues about what it *means* to stack LSM modules
semantically but thats a problem for the admin not the kernel so it's not
a "hard" problem programming wise.

> Eric, the thing is, once an API goes upstream, we can't change it,
> but in contrast we can change how task->security is used at any time.
> So I'd suggest just adding 
> 
> #ifdef CONFIG_SECURITY_NOSUID
> 	short nosuid;
> #endif

Should be a bitflag - then you can also fix some of the locking questions
- the current code really doesn't consider locking issues at all - which
needs fixing.

> or something like it next to the
> 
> #ifdef CONFIG_SECURITY
> 	void *security;
> #endif

And 148 other #defines later it'll be a joyous mess.

Its always easier short term to pee in the pond than install a toilet -
it's just not a good long term plan.

