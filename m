From: Crispin Cowan <crispin@crispincowan.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 14 Apr 2008 21:59:52 -0700
Message-ID: <48043648.1000502@crispincowan.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>	 <20080404122408.986477936@I-love.SAKURA.ne.jp>	 <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>	 <20080409131151.GK11962@parisc-linux.org>	 <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>	 <20080411143013.GB11962@parisc-linux.org>	 <20080413163658.GC7010@sergelap.austin.ibm.com>	 <4802BBDC.1030707@crispincowan.com> <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762940AbYDOE4o@vger.kernel.org>
In-Reply-To: <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Smalley wrote:
> On Sun, 2008-04-13 at 19:05 -0700, Crispin Cowan wrote:
>   
>> Things that pathname-based access control is good at:
>>
>>     * *System Integrity:* Many of the vital components of a UNIX system
>>       are stored in files with Well Known Names such as /etc/shadow,
>>       /var/www/htdocs/index.html and /home/crispin/.ssh/known_hosts. The
>>       contents of the actual data blocks is less important than the
>>       integrity of what some random process gets when it asks for these
>>       resources by name. Preserving the integrity of what responds to
>>       the Well Known Name is thus easier if you restrict access based on
>>       the name.
>>     
> I think some might argue that the integrity of the data in /etc/shadow
> and your .ssh files is very important, not just their names.
I understand how the confidentiality of secrets like the contents of 
/etc/shadow and your .ssh files is important, but how can the integrity 
of these data objects be important? Back them up if you care ...

>   And as
> names are themselves just data contained by directories, the integrity
> of the names is a particular case of the data integrity problem.
That's just access control for the containing directory, and/or access 
control to the raw partition, which is also  controlled by name-based 
access control to /dev

>   And
> ultimately data integrity requires information flow control to preserve.
>   
You've argued that before, and I've never been convinced. Rather, it 
looked a lot like a stretched definition trying really hard to turn 
integrity into an information flow problem.The most information flow 
that I will buy in the integrity problem is taint analysis of software 
inputs; that software should validate inputs before acting on it.

>>     * *Dynamic Access Control:* A special case of the above pertains to
>>       files that may or may not exist. If you don't *have* a /etc/hosts
>>       file, it is still important to have a rule that controls whether
>>       it can be created. This is hard to do in label-based systems,
>>       because the file does not exist to put a label on, so you have to
>>       kludge it by either creating the file with zero length and
>>       labeling it, or by creating more complex policy for the parent
>>       /etc directory, and that's hard given the number of uses for /etc
>>       such as /etc/motd. In a name based scheme, you simply don't
>>       provide write permission to "/etc/hosts" unless you mean it, and
>>       it can be enforced even if such a file does not exist.
>>     
> I'd view this as another example of practical or legacy concerns, as it
> wouldn't pose a problem if either of the following were true:
> - /etc was further partitioned into multiple subdirectories (seemingly
> true in an increasing number of cases, so we seem to be moving in that
> direction regardless) so that inheritance from parent directory would
> suffice, or
>   
If you want to move this particular benefit to the "practical" bucket, I 
have no issue with that. It is a core part of the name-based argument 
that it is a practical solution for system administrators who     
experience the system through names.

> - specific programs were used to create or update the individual files
> (true for some of the files in /etc, and generally helpful for ensuring
> proper data formatting and applying basic sanity checks on the content)
> so that the files created by them could be labeled based on the creating
> domain or via appropriate instrumentation of the programs to set the
> attributes (the latter is not fundamentally different than the situation
> for DAC ownership/mode or ACLs).
>   
Security architecture for a clean&pure architecture are an interesting 
problem, but certainly are not the LSM problem.

> Also, note that in the case of SELinux, we do have a solution to the
> above situation, namely restorecond, which leverages the kernel's
> inotify mechanism.
>   
IMHO that is a slow and racy solution. If one applied the kind of 
standards that AppArmor is being asked to pass to restorecond, it would 
have a tough time too.

> As an example where the name-based schemes have difficulties with
> "dynamic" data, files created at runtime in /tmp and other shared
> directories often have security-irrelevant names,
Presumably you mean that the name is not meaningfully predictable with 
respect tot he application. Yes, sometimes this is a problem, and 
AppArmor doesn't presently deal with it well.

>  yet protecting them
> from tampering by others can be very relevant to security.  There the
> attribute-based schemes have the advantage.
>   
John Johansen has some designs he has been working on to let an AA 
profile require a UID match as well as a name match. To the extent that 
file ownership is a kind of label, this is a small step towards a hybrid 
model that leverages the strengths of both name and label based access 
controls.

>>     * *Ad Hoc Generalization:* Label-based access control generalizes
>>       policy in that the policy treats all files and resources that
>>       share a label the same. If you want to make a new generalization
>>       that encompasses *part* of the files that share a label, but *not
>>       all* of those files, then you have to "split the label", relabel
>>       the file system, and revise the policy accordingly. Name-based
>>       access control lets you create ad hoc generalizations, so that
>>       *my* policy can grant access to "/var/www/*.pl" without regard to
>>       whatever labels or rules some other policy has applied to the same
>>       directory tree.
>>     
> We might argue about whether ad hoc policy writing is the best approach.
>   
Another way of saying "ad hoc policy writing" is "incremental policy 
development."

If you can anticipate everything you need in your data center and get it 
right ahead of time, then you don't need ad hoc policy. If circumstances 
change on you and you need to adapt, then your policy is necessarily ad hoc.

> Regardless, the corresponding weakness here for the path-based schemes
> is that they force you into writing policy in terms of the filesystem
> layout and names, which may have little or no bearing on the actual
> security characteristics of the files.
>   
I assert that the pathname has a strong correspondence to the integrity 
sensitivity of the file, and a weaker correspondence to the 
confidentiality sensitivity of the file, e.g. a backup copy of your 
actual /etc/shadow file is still sensitive if it gets disclosed to 
someone intent on password cracking.

This is not a severe problem for AppArmor in practice because of the 
default-deny nature of the policy: only grant read access to the files 
you intend to allow to be read. It is fairly difficult to accidentally 
disclose a file in an AppArmor policy unless you engage in really sloppy 
practice like dropping copies of sensitive files in publicly readable 
places like /tmp

>>     * *Familiar Interface:* Administrators are accustomed to
>>       administering the box in terms of the names of the files that
>>       matter. A name-based policy is therefore somewhat more familiar
>>       than a policy with label abstractions, where they then have to go
>>       look at the restorecon file to discover what files will/should
>>       have what labels.
>>     
> restorecon /path/to/file doesn't require the user to deal with anything
> other than a pathname.
Yes it does. To understand your security policy, you have to understand 
both the SELinux policy about labels & types and which are allowed to 
access each other, and also the restorecon specification that determines 
what labels will be applied to which files.

>>     * *Practical Concerns:* Not all file systems support labels, and so
>>       label-based schemes become coarse grained when they run into them.
>>       Name based schemes remain granular when specifying access down
>>       into the internals of such file systems. Legacy Linux file systems
>>       like ext2 don't matter much any more, but persistent file systems
>>       that will never have label support include NFSv3 file systems
>>       (nearly every Network Appliance NAS server out there) and FAT32
>>       file system (most every USB storage device).
>>     
> At present this is a limitation, although we do support per-mount
> labeling of such filesystems, which is really all we can guarantee in
> terms of protection anyway
That's what I meant by granular: you get access to the whole NFS mount, 
or none of it.

>  - anything further is misleading as the
> server or device won't ensure any finer grained separation for us.
I don't understand this issue. The enforcement here is t contain the 
program executing on the NFS *client* to permit it to only mangle the 
parts of the NFS mount that you want it to mangle. That the server won't 
enforce anything for you is irrelevant when the threat is the confined 
application.

>> A lot of what's going on is the duality of the one:many relationships 
>> between labels and names:
>>
>>     * Labels: one label represents many files
>>           o this property is why ad hoc generalization fails in label
>>             based systems
>>     * Names: many names can represent a single file
>>           o This property is why deny rules fail in name based systems
>>
>> Therefore, I am not claiming name-based access controls to be the 
>> ultimate. Rather, there are duals for all of the above that induce 
>> circumstances where label-based systems are superior. Each class of 
>> system has strengths and weaknesses. These are name-based strengths.
>>     
>
> The weaknesses from my POV are:
> - no system-wide view of the subjects and objects and thus of the
> policy,
>   
... and no *requirement* to construct a system-wide consistent view of 
security policy.

> - no uniform abstraction for handling objects (not everything has a
> pathname), leading to inconsistent or incomplete control,
>   
*Strawman* argument: AppArmor doesn't try to apply pathnames to 
everything, just the file system. The "uniform abstraction" is to 
specify security policy in the native terms of the resource being 
mediated. Files are named as /path/to/some/files/*.html and network 
resources are named in terms of ports and network addresses reminiscent 
of firewall rules.

In contrast, SELinux *does* apply the labeled model to everything. That 
has the strength that you are dealing with the same abstraction all the 
time, and the weakness that the mapping from the label abstraction to 
the stuff that admins and users have to actually deal with is arcane.

> - forcing policy to be written in terms of individual objects and
> filesystem layout rather than security properties.
>   
Name-based access control makes the overt assumption that the name of an 
object corresponds to its security properties. If your data layout does 
*not* make such an assumption, then you have some very strange data 
layout putting highly sensitive objects next to non-sensitive objects.

Note also that the SELinux restorecon mechanism also makes the 
assumption that path names correspond to security properties: in fact, 
that is precisely its function, to take a path name and use it to apply 
a security property (a label). Naturally I have no objection to 
inferring a security property from the path name :) I just object to the 
racy way that restorecon does it, combined with the complaint that 
AppArmor is wrong for doing exactly the same thing in a different way.

Crispin

-- 
Crispin Cowan, Ph.D.               http://crispincowan.com/~crispin
The Olympic Games: Symbolizing oppression and corruption for over a
hundred years
