From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 00:01:14 -0500
Message-ID: <20091229050114.GC14362@heat>
References: <20091228181316.GA16277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@ZenIV.linux.org.uk>,
	M
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:37203 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751711AbZL2E71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 23:59:27 -0500
Content-Disposition: inline
In-Reply-To: <20091228181316.GA16277@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge,

I think that Pavel's point, at its strongest and most general, could be
rephrased as:

   "Adding *any* interesting isolation facility to the kernel breaks backwards
    compatibility for *some* program [in a way that violates security goals]."

The reason is the one that I identified in my previous note:

   "The purpose of isolation facilities is to create membranes inside which
    grievous security faults are converted into availability faults."

The question then is simply:

   "How do we want to deal with the compatibility-breaking changes created by
    introducing new isolation facilities?"

So far, I've seen the following suggestions:

   a) setuid restores pre-isolation semantics

         - Doesn't work for me because it violates the security guarantee of the
           isolation primitive 

   b) setuid is an escape-hatch

         - Probably the cleanest in the long-run

         - Doesn't, by itself, suffice for Pavel since it violates backwards
           compatibility

   c) signal to the kernel through a privileged mechanism that
      backwards-incompatible isolation may or may not be used

         - No problems seen so far.

I would be happy with (c), assuming we can agree on an appropriate signalling
mechanism and default.

So far, two defaults have been proposed:

   default-deny incompatible isolation (Pavel)
   default-permit incompatible isolation (Michael)

So far, several signalling mechanisms have been proposed:

   1) enabling a kernel config option implies default-permit

         - My favorite; apparently insufficient for Pavel?

   2) default-deny; disablesuid grants disablenetwork

         - "disablesuid" is my name for the idea of dropping the privilege of
           exec'ing setuid binaries

         - Suggested by Pavel and supported by several others. 

         - I think it has the same backwards-compatibility problem as
           disablenetwork: disablesuid is an isolation primitive.

   3) default-deny; dropping a capability from the bounding set grants "permit"

         - Suggested by Serge; seems nicely fine-grained but rather indirect

   4) default-deny; setting a sysctl implies permit

         - Suggested by Serge; works fine for me

   5) default-deny; setting a kernel boot argument implies permit

         - Suggested by Serge; I like the sysctl better.

I am happiest with (1) and, if (1) isn't good enough, with (4).

Pavel, what do you think of (4)?

Regards,

Michael

P.S. - I'd be happy to know more about existing precedent on introducing
compatibility-breaking changes if any comes to mind. (For example, how were the
Linux-specific rlimits handled?)

P.P.S. - On a completely unrelated note: imagine trying to use SELinux (or your
favorite MAC framework) to restrict the use of prctl(PR_SET_NETWORK,
PR_NETWORK_OFF). Am I right that sys_prctl() contains a
time-of-check-to-time-of-use (TOCTTOU) race (with security_task_prctl() as the
check and with prctl_set_network() as the use) as a result of the actual
argument being passed by address rather than by value?
