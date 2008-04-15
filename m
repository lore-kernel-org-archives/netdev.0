From: "Toshiharu Harada" <haradats@gmail.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Tue, 15 Apr 2008 06:00:32 -0700
Message-ID: <9d732d950804150600t64cfc1c6qdabdca83f74ff346@mail.gmail.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
	 <200804071140.59247.paul.moore@hp.com>
	 <47FC8052.9070409@nttdata.co.jp>
	 <20080409131151.GK11962@parisc-linux.org>
	 <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
	 <20080411143013.GB11962@parisc-linux.org>
	 <20080413163658.GC7010@sergelap.austin.ibm.com>
	 <4802BBDC.1030707@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	"Matthew Wilcox" <matthew@wil.cx>,
	"Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: "Crispin Cowan" <crispin@crispincowan.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4802BBDC.1030707@crispincowan.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Serge E. Hallyn wrote:
>> Quoting Matthew Wilcox (matthew@wil.cx):
>>
>>> On Fri, Apr 11, 2008 at 11:12:27PM +0900, Tetsuo Handa wrote:
>>>
>>>> Matthew Wilcox wrote:
>>>>
>>>>> When the rule is put in place, say "No modifications to /etc/passwd",
>>>>> look up the inode and major:minor of /etc/passwd.  If there's a
>>>>> rename,
>>>>> look up the new inode number.  If it's mounted elsewhere, it doesn't
>>>>> matter, they still can't modify it because it has the same
>>>>> major:minor:inode.
>>>>>
>>>> If write access is denied because of a rule "No modifications to
>>>> /etc/passwd",
>>>> a rule "Allow modifications to /tmp/passwd" can no longer be
>>>> enforced after
>>>> "mount --bind /etc/ /tmp/" or "mount --bind /etc/passwd /tmp/passwd" or
>>>> "mv /etc/passwd /tmp/passwd" or "ln /etc/passwd /tmp/passwd" is done.
>>>>
>>> That's a fundamental limitation of pathname-based security though.
>>> If the same file exists in two places, you have to resolve the question
>>> of which rule overrides the other.
>>>
>> In the past, Crispin has given clear, concise explanations of a few of
>> the things pathname based access control in fact excels at.  Crispin,
>> can you recite those again so we can think constructively about which
>> (if any) of the currently considered options are or are not sufficient?
>>
>> I.e. what would be a motivation for a rule like 'no modifications to
>> /etc/passwd', and what precisely would and would not be accepted ways to
>> get around it (and why)?
>>
> As I just posted, a rule of "no mods to /some/pathname" is broken, which
> is why AppArmor has no such construct.

Traditional "talking by examples" is a good way and works in general,
but not always right for this case (I mean "label or path" discussion.
Yes, I've learned this from AppArmor thread. :)

> Things that pathname-based access control is good at:
>
>    * *System Integrity:* Many of the vital components of a UNIX system
>      are stored in files with Well Known Names such as /etc/shadow,
>      /var/www/htdocs/index.html and /home/crispin/.ssh/known_hosts. The
>      contents of the actual data blocks is less important than the
>      integrity of what some random process gets when it asks for these
>      resources by name. Preserving the integrity of what responds to
>      the Well Known Name is thus easier if you restrict access based on
>      the name.
>    * *Dynamic Access Control:* A special case of the above pertains to
>      files that may or may not exist. If you don't *have* a /etc/hosts
>      file, it is still important to have a rule that controls whether
>      it can be created. This is hard to do in label-based systems,
>      because the file does not exist to put a label on, so you have to
>      kludge it by either creating the file with zero length and
>      labeling it, or by creating more complex policy for the parent
>      /etc directory, and that's hard given the number of uses for /etc
>      such as /etc/motd. In a name based scheme, you simply don't
>      provide write permission to "/etc/hosts" unless you mean it, and
>      it can be enforced even if such a file does not exist.
>    * *Ad Hoc Generalization:* Label-based access control generalizes
>      policy in that the policy treats all files and resources that
>      share a label the same. If you want to make a new generalization
>      that encompasses *part* of the files that share a label, but *not
>      all* of those files, then you have to "split the label", relabel
>      the file system, and revise the policy accordingly. Name-based
>      access control lets you create ad hoc generalizations, so that
>      *my* policy can grant access to "/var/www/*.pl" without regard to
>      whatever labels or rules some other policy has applied to the same
>      directory tree.
>    * *Familiar Interface:* Administrators are accustomed to
>      administering the box in terms of the names of the files that
>      matter. A name-based policy is therefore somewhat more familiar
>      than a policy with label abstractions, where they then have to go
>      look at the restorecon file to discover what files will/should
>      have what labels.
>    * *Practical Concerns:* Not all file systems support labels, and so
>      label-based schemes become coarse grained when they run into them.
>      Name based schemes remain granular when specifying access down
>      into the internals of such file systems. Legacy Linux file systems
>      like ext2 don't matter much any more, but persistent file systems
>      that will never have label support include NFSv3 file systems
>      (nearly every Network Appliance NAS server out there) and FAT32
>      file system (most every USB storage device).
>
> A lot of what's going on is the duality of the one:many relationships
> between labels and names:
>
>    * Labels: one label represents many files
>          o this property is why ad hoc generalization fails in label
>            based systems
>    * Names: many names can represent a single file
>          o This property is why deny rules fail in name based systems
>
> Therefore, I am not claiming name-based access controls to be the
> ultimate. Rather, there are duals for all of the above that induce
> circumstances where label-based systems are superior. Each class of
> system has strengths and weaknesses. These are name-based strengths.

Agreed and I personally would love to stay discussions in this layer
forgetting existing implementations, including my own project of
TOMOYO Linux. The above summary of labels and names are very important,
but I would like to "raise" the layer of discussion.

The essence of MAC is limiting and restricting.
My version of the MAC *issues* are as follows:

- how to distinguish good(necessary) and bad(unnecessary) accesses
- how to describe the rule (the most important result is a policy language)
- how to keep Linux kernel aware of the rule and keep it safely
- how to administrate the whole picture (with human error in mind)

The first one belongs to a human responsible part and the
remainders belong to implementations. Let me note, label vs. names
issue resides in the implementation layer.

How to describe rules imply "what is the natural way for human
administrators" while keeping the Linux kernel implies
"what is the most solid and trusted way for Linux".
>From the fact is Linux works with names and inodes, I'm pretty sure
we will end up with some sort of hybrid system.

>From the above point of view, the option 2 which Stephen
kindly showed quite *practical* to me, because it allows
loose connection of the "namespace" and "inode". (If your
initial is not S.S, my PNG diagram posted on April 10 might help
to understand what I wrote here)


BTW I'm attending the ELC2008. Hope to see and talk in peace
with some of related people. :)

Regards,
Toshiharu Harada
NTT DATA CORPORATION
