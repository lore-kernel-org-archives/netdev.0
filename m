From: Eric Paris <eparis@redhat.com>
Subject: Re: module loading permissions and request_module permission
 inconsistencies
Date: Mon, 10 Aug 2009 21:29:59 -0400
Message-ID: <1249954199.2501.123.camel@dhcp231-106.rdu.redhat.com>
References: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
	 <20090810202308.GA15390@hmsreliant.think-freely.org>
	 <1249937339.2501.80.camel@dhcp231-106.rdu.redhat.com>
	 <20090810232551.GA20747@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kees@ubuntu.com, morgan@kernel.org, serue@us.ibm.com,
	casey@schaufler-ca.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090810232551.GA20747@hmsreliant.think-freely.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-08-10 at 19:25 -0400, Neil Horman wrote:
> On Mon, Aug 10, 2009 at 04:48:59PM -0400, Eric Paris wrote:
> > On Mon, 2009-08-10 at 16:23 -0400, Neil Horman wrote:
> > > On Mon, Aug 10, 2009 at 03:45:13PM -0400, Eric Paris wrote:
> > 
> > > > 1) remove CAP_SYS_MODULE from the networking code and instead check
> > > > CAP_NET_ADMIN.  Maybe CAP_NET_ADMIN is already being checked and I'll
> > > > just remove the capable call altogether but at least I can more
> > > > intelligently limit the powers of these processes and they will still be
> > > > root limited according to DAC permissions like they are today.
> > > > 
> > > Would this have any adverse effect on how user space sees this working.
> > > Intuitively I would think that if you wanted to load a module (directly or
> > > indirectly, via an iptables command or whatnot), you would need CAP_SYS_MODULE
> > > capabilities on the calling process, not just CAP_NET_ADMIN.  I honestly don't
> > > know the answer here, I'm just raising the question.
> > 
> > While that might make intuitive sense, it's actually proving to be a bad
> > idea to use the same capability for direct and indirect module loading
> > (especially considering we have 125 other places in the kernel where you
> > can do indirect module loading without any security check)  And believe
> > me, if someone suggests I move a CAP_SYS_MODULE check down into
> > __request_module I'll scream about what a horrible idea that is (and
> > then laugh at them behind their back).
> > 
> > While I think there should be some check in __request_module I don't
> > think it should be CAP_SYS_MODULE.
> > 
> Forgive my excessive density, but what exactly would be wrong with putting a
> CAP_SYS_MODULE check into __request_module?  Is there some sort of implicit
> behavioral change that will mess with user space in doing so?

Yes I believe it would almost certainly break all of the programs
outside of the 3 networking spots which trigger the kernel to try to
load a module.  Take a look at everything that call request_module().  I
believe this because currently there are no security checks on those 125
call sites and security policy does not grant CAP_SYS_MODULE to many
domains (for good reason, it's a @#$% dangerous permission to give
things.)

If the kernel does go that route it will force the security policy to be
loosened such that all of those programs will have permission to
directly load arbitrary data they can create.  As it stands today,
subverting any of those calling programs 'merely' allows the attacker to
make the kernel load a module using modprobe whose name is sometimes
attacker controlled and sometimes not.  I contend that triggering the
kernel to do an upcall is not the same security behavior as loading my
own data directly into the kernel.

That's the whole problem.  There are separate security concerns between
triggering the loading of a known module and directly loading arbitrary
data.  Pushing a CAP_SYS_MODULE check down into __request_module will
result in a less secure system policy in which the attack space on a
system grows since there would be a significantly increased number of
programs with permission to load data directly into the kernel.

If the community feels that CAP_SYS_MODULE in __request_module is the
right way to go that's fine (but I'm not going to send that patch which
i believe will break systems).  I'll just create new security hooks in
init_module, delete_module, and __request_module, which have no DAC
meaning but which LSMs can implement policy with.  Given those 2/3 new
hooks an LSMs can freely grant CAP_SYS_MODULE like candy, since in my
opinion, it becomes a lot less meaningful and we can still meet
meaningful security goals.

-Eric

