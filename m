From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: networking probs in next-20081203
Date: Fri, 05 Dec 2008 09:12:19 -0500
Message-ID: <1228486339.20274.3.camel@localhost.localdomain>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	<m1bpvrslk0.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jmorris@namei.org, adobriyan@gmail.com,
	eparis@parisplace.org, akpm@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <m1bpvrslk0.fsf@frodo.ebiederm.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2008-12-04 at 13:00 -0800, Eric W. Biederman wrote:
> Stephen Smalley <sds@tycho.nsa.gov> writes:
> 
> > On Thu, 2008-12-04 at 14:32 -0500, Stephen Smalley wrote:
> >> On Thu, 2008-12-04 at 10:21 -0800, David Miller wrote:
> >> > From: Stephen Smalley <sds@tycho.nsa.gov>
> >> > Date: Thu, 04 Dec 2008 13:11:20 -0500
> >> > 
> >> > > On Thu, 2008-12-04 at 20:52 +0300, Alexey Dobriyan wrote:
> >> > > > On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
> >> > > > > maybe try disabling selinux?
> >> > > > 
> >> > > > This will work. :^)
> >> > > 
> >> > > SELinux didn't change here.  /proc/net did.
> >> > 
> >> > We've been through this before...
> >> 
> >> Yep, and we altered SELinux so that they could freely change proc
> >> directories into symlinks to support the earlier proc/net change.  But
> >> now proc/net has turned into its own separate filesystem, with its own
> >> filesystem type, which is unknown to SELinux.  Thus causing it to be
> >> left unlabeled and inaccessible to confined domains.
> >> 
> >> > And it is a usability issue that people can't change how procfs
> >> > directories work without requiring the user to update their selinux
> >> > policies first.
> >> 
> >> Introducing a new filesystem type (proc/net) without teaching SELinux
> >> how to handle it is always going to produce denials on accessing that
> >> filesystem.  If they left the filesystem type string as "proc" it
> >> wouldn't be a problem.
> >
> > Actually, that isn't quite correct as it wouldn't generate the same
> > name/key for lookup.
> >
> >>   Or they can adjust the SELinux code to
> >> automagically handle it.  Regardless, we didn't break anything.
> >
> > Looking back, I see that they did in fact change selinux as part of the
> > patch to make proc/net its own filesystem, although unfortunately not in
> > a way that will quite work.  But no selinux maintainer was ever cc'd on
> > that patch.
> 
> Yes.  Apologies.  The whole thing started with some stupid security
> drama and so things tried to happen outside of the normal channels
> and things just went wrong, and got lost...
> 
> When I resent and started things through the normal channels I forgot
> to cc you guys.  My apologies.
> 
> Which piece of selinux magic did I miss?
> 
> In particular can you tell if this was a code bug or a logic bug?

I suspect we need the following un-tested diff to map all of these proc/
filesystem types to "proc" for the policy lookup at filesystem mount
time.

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 9155fa9..3c3ceb7 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -703,7 +703,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 		sbsec->proc = 1;
 
 	/* Determine the labeling behavior to use for this filesystem type. */
-	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
+	rc = security_fs_use(sbsec->proc ? "proc" : sb->s_type->name, &sbsec->behavior, &sbsec->sid);
 	if (rc) {
 		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
 		       __func__, sb->s_type->name, rc);

-- 
Stephen Smalley
National Security Agency


------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
