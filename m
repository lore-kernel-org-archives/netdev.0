From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Thu, 17 Apr 2008 08:42:05 -0400
Message-ID: <1208436125.18883.340.camel@moss-spartans.epoch.ncsc.mil>
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
	 <1208363519.18883.232.camel@moss-spartans.epoch.ncsc.mil>
	 <4807011D.8060009@crispincowan.com>
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
In-Reply-To: <4807011D.8060009@crispincowan.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2008-04-17 at 00:49 -0700, Crispin Cowan wrote:
> Stephen Smalley wrote:
> > On Mon, 2008-04-14 at 21:59 -0700, Crispin Cowan wrote:
> >   
> >> Stephen Smalley wrote:
> >>     
> >>> On Sun, 2008-04-13 at 19:05 -0700, Crispin Cowan wrote:  
> >>>       
> >>>> Things that pathname-based access control is good at:
> >>>>
> >>>>     * *System Integrity:* Many of the vital components of a UNIX system
> >>>>       are stored in files with Well Known Names such as /etc/shadow,
> >>>>       /var/www/htdocs/index.html and /home/crispin/.ssh/known_hosts. The
> >>>>       contents of the actual data blocks is less important than the
> >>>>       integrity of what some random process gets when it asks for these
> >>>>       resources by name. Preserving the integrity of what responds to
> >>>>       the Well Known Name is thus easier if you restrict access based on
> >>>>       the name.
> >>>>         
> >>> I think some might argue that the integrity of the data in /etc/shadow
> >>> and your .ssh files is very important, not just their names.
> >>>       
> >> I understand how the confidentiality of secrets like the contents of 
> >> /etc/shadow and your .ssh files is important, but how can the integrity 
> >> of these data objects be important? Back them up if you care ...
> >>     
> > If you aren't concerned with unauthorized data flow into
> > your /etc/shadow and .ssh files, then I think we'll just have to stop
> > right there in our discussion, as we evidently don't have a common point
> > of reference in what we mean by "security".  Personally I'd be troubled
> > if an unauthorized entity can ultimately feed data to such files, even
> > if indirectly by tricking a privileged process into conveying the data
> > to its ultimate target, a not-so-uncommon pattern.
> >   
> Of *course* AppArmor protects the integrity of /etc/shadow, and 
> unauthorized parties are not permitted to feed data into that file 
> unless explicit access is granted. The difference is in how it is done:
> 
>     * SELinux marks the inode with a label, and only processes with the
>       right permissions can mess with the label.
>           o Residual problem: someone could rename the inode and drop a
>             new inode into place named "/etc/shadow". SELinux addresses
>             this with access control on the parent directory.
>     * AppArmor checks the name "/etc/shadow" so that you cannot access
>       that name without explicit permission.
>           o AppArmor cares about the integrity of what the OS returns
>             when you access the name "/etc/shadow" and does not care a
>             wit what happens to the inode that was *previously* named
>             "/etc/shadow".
> 
> Now, without running off into the weeds again, tell me again why I 
> should care about the *integrity* of an inode that was *previously* 
> known as "/etc/shadow"?

Jamie responded to this last question, but let me also touch on what you
still seem to be missing above.  You are only looking at the direct
check when a process tries to write to the file, not any chain of events
that led a process to write to the file and how that process and that
data it is writing might have been influenced by that chain of events.
It is precisely there that security problems often arise, and I think
you'll see that if you go looking at past flaws.  Both SELinux and
AppArmor mediate that direct write, but only SELinux allows you to
control the entire chain of events and help protect the process from
unsafe influence, because that relies on information flow control.

> >>>   And
> >>> ultimately data integrity requires information flow control to preserve.
> >>>   
> >>>       
> >> You've argued that before, and I've never been convinced. Rather, it 
> >> looked a lot like a stretched definition trying really hard to turn 
> >> integrity into an information flow problem.The most information flow 
> >> that I will buy in the integrity problem is taint analysis of software 
> >> inputs; that software should validate inputs before acting on it.
> >>     
> > In some cases, you can simply prohibit a security-relevant process from
> > taking untrustworthy inputs.  Like blocking privileged processes from
> > following untrustworthy symlinks to counter malicious symlink attacks or
> > from reading any files other than ones created by the admin.  In other
> > cases, you need to allow untrustworthy inputs to ultimately flow to the
> > security-relevant process, but you want to force them through some kind
> > of validation as you say above, which you can do by enforcing a
> > processing pipeline that forces the data to go through a subsystem that
> > performs validation and/or sanitization before it ever reaches the
> > security-relevant process.  That's how integrity is an information flow
> > problem.  And this isn't a new idea, btw, it is one that was expressed
> > long ago in the Biba model, a variant of which happens to be implemented
> > and used in Vista, and is more usefully achievable via Type Enforcement
> > since there we can control the processing flow precisely and bind the
> > validation/sanitization subsystem to specific code.
> >   
> Ok. I view the above as a marginal nice-to-have property that I don't 
> actually care much about, because it is a large amount of work to manage 
> for a small amount of integrity to gain. People who want that should use 
> some kind of information flow controlling policy system like SELinux.
> 
> IMHO people with that need are a small minority, which is why I think it 
> is over-strong to say that integrity "requires" information flow 
> control. No it doesn't; the particular form of integrity you are talking 
> about requires information flow control, but other forms do not.

I'd be curious to be pointed to any integrity model that doesn't have
the above "marginal" property.  It is rather fundamental - when it comes
to enforcing data integrity, you generally have some transform
(validation, sanitization, formatting, etc) that you want applied to the
data to move it from lower integrity to higher integrity, and there are
three properties you want to hold:
1) The subsystem that performs the transform or validation must be
protected against bypass and tampering,
2) The transformed/validated data at each stage must be protected
against tampering,
3) The transform must be correct.

Only the last property requires verification of the subsystem code; the
first two can be directly enforced by the underlying system.  But this
does require information flow control.

It shows up all the time in the form of protected subsystems.

> >>>  - anything further is misleading as the
> >>> server or device won't ensure any finer grained separation for us.
> >>>       
> >> I don't understand this issue. The enforcement here is t contain the 
> >> program executing on the NFS *client* to permit it to only mangle the 
> >> parts of the NFS mount that you want it to mangle. That the server won't 
> >> enforce anything for you is irrelevant when the threat is the confined 
> >> application.
> >>     
> > Except that you have to consider what is happening on the server too,
> > given that the files are visible to local processes there, and what
> > happens on all of the clients.
> You don't have to consider any such thing when you are *only* concerned 
> with confining the impact of the process running on the NFS client.
> 
> If you want to concern yourself with funny business coming from other 
> clients, then you need to apply policy to those other clients. If you 
> want to control funny business happening on the server, then you need to 
> apply security policy to the server. But this is all irrelevant to 
> secure confinement of the single NFS client process being confined.

It is relevant when looking at the overall threat model and what you
realistically have to take into account from a real adversary who isn't
going to be limited by your strawman threat model.

> > It isn't a strawman argument.  I know that AppArmor doesn't try to apply
> > pathnames to non-files.  Which leads it down the first case of
> > inconsistent" control - at the end of the day in looking at an AppArmor
> > policy you can't say anything about how information may have ultimately
> > flowed in violation of your confidentiality or integrity goals because
> > you have a lossy abstraction.  Whereas we can convey the same uniform
> > control over files, network IPC, local IPC, etc and make such
> > statements.
> >   
> Conversely, at the end of the day you can't say much about what your 
> SELinux policy enforces, because you can't understand it :)
> 
> Duality again: SELinux policy is easier for machines (semantic 
> analyzers) to understand. AppArmor is easier for humans to understand.

SELinux policy can be analyzed.  AppArmor policy gives the appearance of
being easily understood, but is actually meaningless in terms of any
higher level security goal.

> >>> - forcing policy to be written in terms of individual objects and
> >>> filesystem layout rather than security properties.  
> >>>       
> >> Note also that the SELinux restorecon mechanism also makes the 
> >> assumption that path names correspond to security properties: in fact, 
> >> that is precisely its function, to take a path name and use it to apply 
> >> a security property (a label). Naturally I have no objection to 
> >> inferring a security property from the path name :) I just object to the 
> >> racy way that restorecon does it, combined with the complaint that 
> >> AppArmor is wrong for doing exactly the same thing in a different way.
> >>     
> > Making that inference when a file is first installed (as from rpm) is
> > reasonable.  restorecon (the utility) is for the filesystem to the
> > initial install-time labeling state, which is why it uses the same
> > mapping.  Making that inference on every access in complete ignorance of
> > the actual runtime state of the system is what I object to.
> >   
> So associating a security property with a name is ok if you do it 
> statically at some arbitrary point in time, but not if you consider it 
> at the time of access? WtF? Isn't that a gigantic race condition?

I'll try and explain again.  When a file is installed onto the system
initially (and here we are talking about a file from a package, not a
runtime file being created by a user/application), we have no intrinsic
knowledge of its security properties from the installer's security
properties, and thus we must consult an external data source - in our
case, the file contexts configuration or package metadata.  This relies
on secure creation and distribution of the packages in the first place,
of course, which is a dependency that has to be addressed separately.
At that time, using the pathname of the file as a key for looking up the
context in which to install the file makes sense; it is already the key
for the file.

For runtime operation of the system, we want to use the runtime state of
the system to determine the security properties of data created by
applications and users rather than the pathnames.  And thus SELinux
relies on policy in most cases to automatically label files based on the
security properties of the creating process and related objects, and
when needed, on instrumentation in the applications to explicitly label
files based on more specific application knowledge.

Relabeling of any kind is never desirable - the goal is always to label
the data correctly at creation time and preserve that label for the
lifecycle of the object.  Relabeling is a practical accommodation to
incomplete coverage.  It should always be minimized, and as coverage
grows, it becomes less necessary.

restorecon (the utility) is an administrator's way of forcing a given
file or files back to the initial state, presumably based on his
knowledge that they ought to be in that initial state.  It is only for
fixing up mislabeled files, not for runtime enforcement of anything.

restorecond (the daemon) is entirely an accommodation to usability to
deal with the incomplete coverage of policy and/or application support,
although the latter has come a long way since SELinux was first
introduced.  restorecond isn't necessary for using SELinux, but can be
helpful.  It isn't a fundamental part of the SELinux enforcement
mechanism, and we agree that you shouldn't rely on it to enforce a
security property - it is to fix up gaps left by incomplete coverage.

I think perhaps your confusion is that you think we are advocating
restorecond as a fundamental mechanism for enforcement rather than a
practical accommodation for optional use until coverage is more
complete.  It is a practical solution to the problem you posed earlier.

> To the contrary, I argue that the *current* name of a file is vastly 
> more meaningful for security properties than the name the file had some 
> months ago when someone ran restorecon over the file system.
> 
> I've said this before too: SELinux works well if your IT systems are 
> static. AppArmor works better if your IT systems change, precisely 
> because it evaluates the access based on the name at the time of access, 
> rather than some historic name the file once had.

On the contrary, SELinux enables the system to correctly track the real
runtime state of the system over time and to thus enforce the right
security properties over time.

In any event, my main goal here isn't really to argue about pathnames
vs. labels, but rather just to explain the role of information flow
control in protecting integrity and to clarify some misconceptions you
seem to have about SELinux.

-- 
Stephen Smalley
National Security Agency

