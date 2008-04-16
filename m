From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 16 Apr 2008 12:31:59 -0400
Message-ID: <1208363519.18883.232.camel@moss-spartans.epoch.ncsc.mil>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>
	 <20080409131151.GK11962@parisc-linux.org>
	 <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
	 <20080411143013.GB11962@parisc-linux.org>
	 <20080413163658.GC7010@sergelap.austin.ibm.com>
	 <4802BBDC.1030707@crispincowan.com>
	 <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
	 <48043648.1000502@crispincowan.com>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <48043648.1000502@crispincowan.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2008-04-14 at 21:59 -0700, Crispin Cowan wrote:
> Stephen Smalley wrote:
> > On Sun, 2008-04-13 at 19:05 -0700, Crispin Cowan wrote:
> >   
> >> Things that pathname-based access control is good at:
> >>
> >>     * *System Integrity:* Many of the vital components of a UNIX system
> >>       are stored in files with Well Known Names such as /etc/shadow,
> >>       /var/www/htdocs/index.html and /home/crispin/.ssh/known_hosts. The
> >>       contents of the actual data blocks is less important than the
> >>       integrity of what some random process gets when it asks for these
> >>       resources by name. Preserving the integrity of what responds to
> >>       the Well Known Name is thus easier if you restrict access based on
> >>       the name.
> >>     
> > I think some might argue that the integrity of the data in /etc/shadow
> > and your .ssh files is very important, not just their names.
> I understand how the confidentiality of secrets like the contents of 
> /etc/shadow and your .ssh files is important, but how can the integrity 
> of these data objects be important? Back them up if you care ...

If you aren't concerned with unauthorized data flow into
your /etc/shadow and .ssh files, then I think we'll just have to stop
right there in our discussion, as we evidently don't have a common point
of reference in what we mean by "security".  Personally I'd be troubled
if an unauthorized entity can ultimately feed data to such files, even
if indirectly by tricking a privileged process into conveying the data
to its ultimate target, a not-so-uncommon pattern.

> >   And as
> > names are themselves just data contained by directories, the integrity
> > of the names is a particular case of the data integrity problem.
> That's just access control for the containing directory, and/or access 
> control to the raw partition, which is also  controlled by name-based 
> access control to /dev
> 
> >   And
> > ultimately data integrity requires information flow control to preserve.
> >   
> You've argued that before, and I've never been convinced. Rather, it 
> looked a lot like a stretched definition trying really hard to turn 
> integrity into an information flow problem.The most information flow 
> that I will buy in the integrity problem is taint analysis of software 
> inputs; that software should validate inputs before acting on it.

In some cases, you can simply prohibit a security-relevant process from
taking untrustworthy inputs.  Like blocking privileged processes from
following untrustworthy symlinks to counter malicious symlink attacks or
from reading any files other than ones created by the admin.  In other
cases, you need to allow untrustworthy inputs to ultimately flow to the
security-relevant process, but you want to force them through some kind
of validation as you say above, which you can do by enforcing a
processing pipeline that forces the data to go through a subsystem that
performs validation and/or sanitization before it ever reaches the
security-relevant process.  That's how integrity is an information flow
problem.  And this isn't a new idea, btw, it is one that was expressed
long ago in the Biba model, a variant of which happens to be implemented
and used in Vista, and is more usefully achievable via Type Enforcement
since there we can control the processing flow precisely and bind the
validation/sanitization subsystem to specific code.

> >  - anything further is misleading as the
> > server or device won't ensure any finer grained separation for us.
> I don't understand this issue. The enforcement here is t contain the 
> program executing on the NFS *client* to permit it to only mangle the 
> parts of the NFS mount that you want it to mangle. That the server won't 
> enforce anything for you is irrelevant when the threat is the confined 
> application.

Except that you have to consider what is happening on the server too,
given that the files are visible to local processes there, and what
happens on all of the clients.  And the aliasing problem that exists in
the local filesystem case becomes exacerbated in the NFS environment.

> > - no uniform abstraction for handling objects (not everything has a
> > pathname), leading to inconsistent or incomplete control,
> >   
> *Strawman* argument: AppArmor doesn't try to apply pathnames to 
> everything, just the file system. The "uniform abstraction" is to 
> specify security policy in the native terms of the resource being 
> mediated. Files are named as /path/to/some/files/*.html and network 
> resources are named in terms of ports and network addresses reminiscent 
> of firewall rules.
> 
> In contrast, SELinux *does* apply the labeled model to everything. That 
> has the strength that you are dealing with the same abstraction all the 
> time, and the weakness that the mapping from the label abstraction to 
> the stuff that admins and users have to actually deal with is arcane.

It isn't a strawman argument.  I know that AppArmor doesn't try to apply
pathnames to non-files.  Which leads it down the first case of
inconsistent" control - at the end of the day in looking at an AppArmor
policy you can't say anything about how information may have ultimately
flowed in violation of your confidentiality or integrity goals because
you have a lossy abstraction.  Whereas we can convey the same uniform
control over files, network IPC, local IPC, etc and make such
statements.

> > - forcing policy to be written in terms of individual objects and
> > filesystem layout rather than security properties.
> >   
> Name-based access control makes the overt assumption that the name of an 
> object corresponds to its security properties. If your data layout does 
> *not* make such an assumption, then you have some very strange data 
> layout putting highly sensitive objects next to non-sensitive objects.
> 
> Note also that the SELinux restorecon mechanism also makes the 
> assumption that path names correspond to security properties: in fact, 
> that is precisely its function, to take a path name and use it to apply 
> a security property (a label). Naturally I have no objection to 
> inferring a security property from the path name :) I just object to the 
> racy way that restorecon does it, combined with the complaint that 
> AppArmor is wrong for doing exactly the same thing in a different way.

Making that inference when a file is first installed (as from rpm) is
reasonable.  restorecon (the utility) is for the filesystem to the
initial install-time labeling state, which is why it uses the same
mapping.  Making that inference on every access in complete ignorance of
the actual runtime state of the system is what I object to.

-- 
Stephen Smalley
National Security Agency

