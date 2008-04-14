From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 14 Apr 2008 10:17:00 -0400
Message-ID: <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>
	 <20080409131151.GK11962@parisc-linux.org>
	 <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
	 <20080411143013.GB11962@parisc-linux.org>
	 <20080413163658.GC7010@sergelap.austin.ibm.com>
	 <4802BBDC.1030707@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Crispin Cowan <crispin@crispincowan.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4802BBDC.1030707@crispincowan.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 2008-04-13 at 19:05 -0700, Crispin Cowan wrote:
> Serge E. Hallyn wrote:
> > Quoting Matthew Wilcox (matthew@wil.cx):
> >   
> >> On Fri, Apr 11, 2008 at 11:12:27PM +0900, Tetsuo Handa wrote:
> >>     
> >>> Matthew Wilcox wrote:
> >>>       
> >>>> When the rule is put in place, say "No modifications to /etc/passwd",
> >>>> look up the inode and major:minor of /etc/passwd.  If there's a rename,
> >>>> look up the new inode number.  If it's mounted elsewhere, it doesn't
> >>>> matter, they still can't modify it because it has the same
> >>>> major:minor:inode.
> >>>>         
> >>> If write access is denied because of a rule "No modifications to /etc/passwd",
> >>> a rule "Allow modifications to /tmp/passwd" can no longer be enforced after
> >>> "mount --bind /etc/ /tmp/" or "mount --bind /etc/passwd /tmp/passwd" or
> >>> "mv /etc/passwd /tmp/passwd" or "ln /etc/passwd /tmp/passwd" is done.
> >>>       
> >> That's a fundamental limitation of pathname-based security though.
> >> If the same file exists in two places, you have to resolve the question
> >> of which rule overrides the other.
> >>     
> > In the past, Crispin has given clear, concise explanations of a few of
> > the things pathname based access control in fact excels at.  Crispin,
> > can you recite those again so we can think constructively about which
> > (if any) of the currently considered options are or are not sufficient?
> >
> > I.e. what would be a motivation for a rule like 'no modifications to
> > /etc/passwd', and what precisely would and would not be accepted ways to
> > get around it (and why)?
> >   
> As I just posted, a rule of "no mods to /some/pathname" is broken, which 
> is why AppArmor has no such construct.
> 
> Things that pathname-based access control is good at:
> 
>     * *System Integrity:* Many of the vital components of a UNIX system
>       are stored in files with Well Known Names such as /etc/shadow,
>       /var/www/htdocs/index.html and /home/crispin/.ssh/known_hosts. The
>       contents of the actual data blocks is less important than the
>       integrity of what some random process gets when it asks for these
>       resources by name. Preserving the integrity of what responds to
>       the Well Known Name is thus easier if you restrict access based on
>       the name.

I think some might argue that the integrity of the data in /etc/shadow
and your .ssh files is very important, not just their names.  And as
names are themselves just data contained by directories, the integrity
of the names is a particular case of the data integrity problem.  And
ultimately data integrity requires information flow control to preserve.

>     * *Dynamic Access Control:* A special case of the above pertains to
>       files that may or may not exist. If you don't *have* a /etc/hosts
>       file, it is still important to have a rule that controls whether
>       it can be created. This is hard to do in label-based systems,
>       because the file does not exist to put a label on, so you have to
>       kludge it by either creating the file with zero length and
>       labeling it, or by creating more complex policy for the parent
>       /etc directory, and that's hard given the number of uses for /etc
>       such as /etc/motd. In a name based scheme, you simply don't
>       provide write permission to "/etc/hosts" unless you mean it, and
>       it can be enforced even if such a file does not exist.

I'd view this as another example of practical or legacy concerns, as it
wouldn't pose a problem if either of the following were true:
- /etc was further partitioned into multiple subdirectories (seemingly
true in an increasing number of cases, so we seem to be moving in that
direction regardless) so that inheritance from parent directory would
suffice, or
- specific programs were used to create or update the individual files
(true for some of the files in /etc, and generally helpful for ensuring
proper data formatting and applying basic sanity checks on the content)
so that the files created by them could be labeled based on the creating
domain or via appropriate instrumentation of the programs to set the
attributes (the latter is not fundamentally different than the situation
for DAC ownership/mode or ACLs).

Also, note that in the case of SELinux, we do have a solution to the
above situation, namely restorecond, which leverages the kernel's
inotify mechanism.

As an example where the name-based schemes have difficulties with
"dynamic" data, files created at runtime in /tmp and other shared
directories often have security-irrelevant names, yet protecting them
from tampering by others can be very relevant to security.  There the
attribute-based schemes have the advantage.

>     * *Ad Hoc Generalization:* Label-based access control generalizes
>       policy in that the policy treats all files and resources that
>       share a label the same. If you want to make a new generalization
>       that encompasses *part* of the files that share a label, but *not
>       all* of those files, then you have to "split the label", relabel
>       the file system, and revise the policy accordingly. Name-based
>       access control lets you create ad hoc generalizations, so that
>       *my* policy can grant access to "/var/www/*.pl" without regard to
>       whatever labels or rules some other policy has applied to the same
>       directory tree.

We might argue about whether ad hoc policy writing is the best approach.
Regardless, the corresponding weakness here for the path-based schemes
is that they force you into writing policy in terms of the filesystem
layout and names, which may have little or no bearing on the actual
security characteristics of the files.

>     * *Familiar Interface:* Administrators are accustomed to
>       administering the box in terms of the names of the files that
>       matter. A name-based policy is therefore somewhat more familiar
>       than a policy with label abstractions, where they then have to go
>       look at the restorecon file to discover what files will/should
>       have what labels.

restorecon /path/to/file doesn't require the user to deal with anything
other than a pathname.  The file contexts configuration is entirely
hidden from the user by that interface.

>     * *Practical Concerns:* Not all file systems support labels, and so
>       label-based schemes become coarse grained when they run into them.
>       Name based schemes remain granular when specifying access down
>       into the internals of such file systems. Legacy Linux file systems
>       like ext2 don't matter much any more, but persistent file systems
>       that will never have label support include NFSv3 file systems
>       (nearly every Network Appliance NAS server out there) and FAT32
>       file system (most every USB storage device).

At present this is a limitation, although we do support per-mount
labeling of such filesystems, which is really all we can guarantee in
terms of protection anyway - anything further is misleading as the
server or device won't ensure any finer grained separation for us.  But
labeled NFS support is in progress, and one should never let legacy code
cripple one's approach.  Making compatibility allowances for legacy code
is quite reasonable, and is precisely what we do in terms of supporting
default type transitions, per-mount labels, etc, but that isn't the same
thing as completely constraining your design to only what is supported
by existing code.

> A lot of what's going on is the duality of the one:many relationships 
> between labels and names:
> 
>     * Labels: one label represents many files
>           o this property is why ad hoc generalization fails in label
>             based systems
>     * Names: many names can represent a single file
>           o This property is why deny rules fail in name based systems
> 
> Therefore, I am not claiming name-based access controls to be the 
> ultimate. Rather, there are duals for all of the above that induce 
> circumstances where label-based systems are superior. Each class of 
> system has strengths and weaknesses. These are name-based strengths.

The weaknesses from my POV are:
- no system-wide view of the subjects and objects and thus of the
policy,
- no uniform abstraction for handling objects (not everything has a
pathname), leading to inconsistent or incomplete control,
- no useful information for runtime objects,
- forcing policy to be written in terms of individual objects and
filesystem layout rather than security properties.

-- 
Stephen Smalley
National Security Agency

