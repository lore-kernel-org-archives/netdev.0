From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 11:31:04 -0500
Message-ID: <20091229163104.GC14668@heat>
References: <20091229055653.GB23714@us.ibm.com>
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
Received: from lists.laptop.org ([18.85.2.145]:33653 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752918AbZL2Q26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2009 11:28:58 -0500
Content-Disposition: inline
In-Reply-To: <20091229055653.GB23714@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge Hallyn writes:
> Quoting Michael Stone (michael@laptop.org):
> So far, two defaults have been proposed:
> 
>   default-deny incompatible isolation (Pavel)
>   default-permit incompatible isolation (Michael)
> 
> So far, several signalling mechanisms have been proposed:
> 
>>   1) enabling a kernel config option implies default-permit
>> 
>>         - My favorite; apparently insufficient for Pavel?
>
> default under what conditions?  any setuid?  setuid-root?

My favorite option is that CONFIGURE_SECURITY_DISABLENETWORK causes
disablenetwork to function like djb describes: unprivileged and irrevocable.

(I don't have any setuid executables that I'm worried about breaking; only ones
that I think /should/ be broken and aren't, like ping.)

>   2) default-deny; disablesuid grants disablenetwork
> 
>         - "disablesuid" is my name for the idea of dropping the privilege of
>           exec'ing setuid binaries
> 
>         - Suggested by Pavel and supported by several others.
> 
>         - I think it has the same backwards-compatibility problem as
>           disablenetwork: disablesuid is an isolation primitive.
> 
>   3) default-deny; dropping a capability from the bounding set grants "permit"
> 
>         - Suggested by Serge; seems nicely fine-grained but rather indirect
> 
> Actually I think it's the opposite of what you said here:  so long as the
> capability is in pE, you can regain network.  So it would require a privileged
> process early on (like init or login) to remove the capability from the
> bounding set (bc doing so requires CAP_SETPCAP), but once that was done,
> the resulting process and it's children could not require the capability,
> and, without the capability, could not regain network.  Point being that
> privileged userspace had to actively allow userspace to trap a setuid root
> binary without networking.

What I wrote accurately (if confusingly; sorry!) reflects what you suggest: by
default, the kernel should deny processes from irrevocably dropping networking
privilege until signalled that this is acceptable by the privileged mechanism
of dropping your cap from the bounding set.

> I think during exec we can simply check for this capability in pE, and
> if present then re-enable network if turned off.  Then setuid-root binaries
> will raise that bit (if it's in the bounding set) automatically.  Now,
> that means setuid-nonroot binaries will not reset network.  Though you
> could make that happen by doing setcap cap_net_allownet+pe /the/file.
> Does that suffice?

I think I could live with it.

I find it weird that, if I call disablenetwork on a system *without* dropping
your capability, sendto(...) will fail but execve(['/bin/ping', '...']) will
succeed. 

Still, it will do what I need.

>>   4) default-deny; setting a sysctl implies permit
>> 
>>         - Suggested by Serge; works fine for me
>
>That still leaves the question of when we re-allow network.  Any
>setuid?

My intention was that prctl(PR_SET_NETWORK, PR_NETWORK_OFF) would return
-ENOTSUP or similar until the sysctl was enabled, at which point it would work
as I specified.

("As I specified" means one of "irrevocable" or "like rlimits; can be relaxed
by explicit action by privileged processes")

>> P.P.S. - On a completely unrelated note: imagine trying to use SELinux (or your
>> favorite MAC framework) to restrict the use of prctl(PR_SET_NETWORK,
>> PR_NETWORK_OFF). Am I right that sys_prctl() contains a
>> time-of-check-to-time-of-use (TOCTTOU) race (with security_task_prctl() as the
>> check and with prctl_set_network() as the use) as a result of the actual
>> argument being passed by address rather than by value?
>
> I'm probably misunderstanding your question, but just in case I'm not:  the
> answer is that you wouldn't use the prctl interface anyway.  You would strictly
> use domain transitions.  Instead of doing prctl(PR_SET_NETWORK, PR_NETWORK_OFF)
> you would move yourself from the user_u:user_r:network_allowed domain to the
> user_u:user_r:network_disallowed domain.

You misunderstood; sorry I wasn't more clear. :)

I was really saying:

   Suppose process A and process B create a share a memory segment containing an
   unsigned long pointed to by.

   unsigned long *flags;

   Can't process A call prctl(PR_SET_NETWORK, flags) while, on another
   processor, process B is twiddling bits in *flags so that

     security_task_prctl() sees the bits that process A wrote and
     prctl_set_network() sees the bits that process B wrote?

   i.e. isn't there a TOCTTOU race [1] here in every prctl option that uses a
   pointer argument? if not, what stops the race?

Regards,

Michael

[1]: http://en.wikipedia.org/wiki/Time-of-check-to-time-of-use
