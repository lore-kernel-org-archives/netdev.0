From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Tue, 14 Mar 2006 10:31:34 +1000
Message-ID: <1142296295.17608.112.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
	<1142286237.17608.7.camel@ras.pc.brisbane.lube>
	<20060313135048.27b09fba@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060313135048.27b09fba@localhost.localdomain>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-13 at 13:50 -0800, Stephen Hemminger wrote:
> On Tue, 14 Mar 2006 07:43:57 +1000
> Russell Stuart <russell-lartc@stuart.id.au> wrote:
> 
> > On Mon, 2006-03-13 at 10:04 -0800, Stephen Hemminger wrote:
> > > The memset fix is in current CVS. I just wasn't going to take the
> > > patch that looked at utsname to decide what hash to use.
> > 
> > Stephen, could you describe your objections to it please?
> > 
> 
> Because it means that the API for netlink isn't being used properly.

Do you mean the binary API between the kernel and the 
applications has been broken; this is bad as it 
transgresses some unwritten law; and the patch is
bad because it hides this problem rather than addressing
it?

Does the fact that the binary API changed during a
major kernel release (between 2.4 and 2.6) give us some 
wriggle room here?

Anyway, jokes aside, the situation we have now is the 
current "tc" doesn't work with the current kernel.  This 
situation can't be allowed to continue, I presume.  Ergo, 
here is a list of things we could do to fix this.  All 
you (plural) have to do is choose one, or some 
combination:

1.  Change the hashing algorithm back to the 2.4 way.
    (IMHO, the 2.4 algorithm was better.)  Disadvantage:
    anybody who had a u32 filter that hashed on more
    than one non-zero byte will have their u32 filters
    suddenly break.  However, since how the hashing
    algorithm was never documented beyond "HOWTO's"
    that showed how to hash on one byte, and every
    example of hashing I have seen has been a copy &
    paste of said HOWTO's, my guess is there are stuff
    all people who will be effected.  Another disadvantage:
    people who are using older 2.6 kernels (eg me on
    my production machines) won't have the problem fixed.

2.  Change the hashing algorithm in "tc" to match the 
    current kernel.  Disadvantage: "tc" will no longer 
    work with 2.4 kernels.

3.  Change the hashing algorithm in "tc" to match the
    current kernel, and change the 2.4 kernel's hashing
    algorithm to match the 2.6 kernel.  This is Jamal's
    proposed solution.  Disadvantage: 2.4 is a "stable" 
    kernel, produced when we made a real effort to 
    distinguish between between stable and development 
    kernels.  This change would break API compatibility 
    in a stable series.  Yuk!

4.  Make "tc" look at the kernel version, and choose
    the appropriate hashing function.  This was my
    solution, and everybody seems to hate it bar me
    :(.  Disadvantages: None, other than it hides a
    violation of an "unwritten law".

5.  A combination of 1 & 4.  Change the hashing in 2.6 
    algorithm back to what it was in 2.4, and hide the 
    change by making "tc" check the kernel version and 
    choose the matching hash.    Disadvantages: None, 
    other than now we have wilfully broken the unwritten
    law twice.

My personal preference is to have a "tc" in CVS that
works with _all_ kernel versions.  Yes - the netlink
interface has been broken.  But is was done, and now 
can't be undone.  No matter why we do, there will
forever more be kernel versions with incompatible
netlink interfaces.  We can't fix it.  We just have
to limit the damage.
