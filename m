From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 14 Apr 2008 10:05:21 -0700 (PDT)
Message-ID: <484889.77284.qm@web36604.mail.mud.yahoo.com>
References: <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Smalley <sds@tycho.nsa.gov>,
	Crispin Cowan <crispin@crispincowan.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761870AbYDNRFq@vger.kernel.org>
In-Reply-To: <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Smalley <sds@tycho.nsa.gov> wrote:

> 
> ...
> 
> I think some might argue that the integrity of the data in /etc/shadow
> and your .ssh files is very important, not just their names.

I believe that the key word here is "just". If you go back to
the Orange Book you will see that the combination of the object
and the name by which it is referenced is important. The audit
requirements are most interesting, as they make it clear that
without a relevant name associated with the object an audit
record has no value.

The Orange Book Unix evaluations raised enormous issues regarding
the file system name space. I know that at least two vendors
stated that the name of the object was its device/inode pair and
that the pathname stuff was there strictly for user convenience
and was not security relevent. This is of course hogwash, but
was logically consistant in the context of security policy
documentation. These same vendors had to then make completely
distinct arguments about their audit systems in order to meet
the name identification requirements there.

The question of protections on the object named /etc/passwd came
up time and time again. The notion that /etc/passwd could be a
symlink to /home/smalley/heeheehee really gave evaluators the
whillies. As did the chroot environment, where /roots/crispin/etc/passwd
could magicly become /etc/passwd. One reason that the object
access model is so firmly ingrained is that it allows the
security documentation to wave it's paw and say "bah" when
these questions arise.

> And as
> names are themselves just data contained by directories, the integrity
> of the names is a particular case of the data integrity problem.  And
> ultimately data integrity requires information flow control to preserve.

Good example of my point. The argument is true, and the implications
important, but the conclusion is not satisfactory.

> >     * *Dynamic Access Control:* A special case of the above pertains to
> >       files that may or may not exist. If you don't *have* a /etc/hosts
> >       file, it is still important to have a rule that controls whether
> >       it can be created. This is hard to do in label-based systems,
> >       because the file does not exist to put a label on, so you have to
> >       kludge it by either creating the file with zero length and
> >       labeling it, or by creating more complex policy for the parent
> >       /etc directory, and that's hard given the number of uses for /etc
> >       such as /etc/motd. In a name based scheme, you simply don't
> >       provide write permission to "/etc/hosts" unless you mean it, and
> >       it can be enforced even if such a file does not exist.
> 
> I'd view this as another example of practical or legacy concerns, as it
> wouldn't pose a problem if either of the following were true:
> - /etc was further partitioned into multiple subdirectories (seemingly
> true in an increasing number of cases, so we seem to be moving in that
> direction regardless) so that inheritance from parent directory would
> suffice, or
> - specific programs were used to create or update the individual files
> (true for some of the files in /etc, and generally helpful for ensuring
> proper data formatting and applying basic sanity checks on the content)
> so that the files created by them could be labeled based on the creating
> domain or via appropriate instrumentation of the programs to set the
> attributes (the latter is not fundamentally different than the situation
> for DAC ownership/mode or ACLs).

Yes, a proper design of the administrative data and interfaces
would solve the problem of /etc/passwd right quick. It would not
address the general issue which is assuring that access is controlled
based on the names that people use.

> Also, note that in the case of SELinux, we do have a solution to the
> above situation, namely restorecond, which leverages the kernel's
> inotify mechanism.

Well, I don't see that addressing the case where /etc/passwd is
a symlink unless restorecond is more sophisticated than I understand
it to be (correct me if I'm wrong) and I certainly can't see it
being used on every file on a multiple pedabyte filesystem.

> As an example where the name-based schemes have difficulties with
> "dynamic" data, files created at runtime in /tmp and other shared
> directories often have security-irrelevant names, yet protecting them
> from tampering by others can be very relevant to security.  There the
> attribute-based schemes have the advantage.

Very true.
 
> ...

> The weaknesses from my POV are:
> - no system-wide view of the subjects and objects and thus of the
> policy,
> - no uniform abstraction for handling objects (not everything has a
> pathname), leading to inconsistent or incomplete control,
> - no useful information for runtime objects,
> - forcing policy to be written in terms of individual objects and
> filesystem layout rather than security properties.

These are all legitimate concerns, but it is really hard to say
that they outweigh the value of controlling access to /etc/passwd
by specifying that you want to control access to /etc/passwd.
The real problem lies in the perfectly reasonable but nontheless
untrue assumptions that users, administrators, and developers
make about the relationship between names and objects on *ix
filesystems. The object model is more correct, and the dickins
easier to write kernel code for I might add. The problem is that
the object model is not what is exposed by the syscall interface,
it's the filesystem namespace. I have oft considered an OS (casex?)
that exposes the device/inode pair and leaves all the pathname
stuff to application space, but I doubt it would be popular
because the namespace is riddled with handy features.

We could fix the filesystem namespace, and then the issue would
evaporate, but I think too many people would think it was fixed
in the veterenary sense.


Casey Schaufler
casey@schaufler-ca.com
