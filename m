From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Fri, 11 Apr 2008 08:30:13 -0600
Message-ID: <20080411143013.GB11962@parisc-linux.org>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp> <20080409131151.GK11962@parisc-linux.org> <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760125AbYDKOap@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 11, 2008 at 11:12:27PM +0900, Tetsuo Handa wrote:
> Matthew Wilcox wrote:
> > When the rule is put in place, say "No modifications to /etc/passwd",
> > look up the inode and major:minor of /etc/passwd.  If there's a rename,
> > look up the new inode number.  If it's mounted elsewhere, it doesn't
> > matter, they still can't modify it because it has the same
> > major:minor:inode.
> 
> If write access is denied because of a rule "No modifications to /etc/passwd",
> a rule "Allow modifications to /tmp/passwd" can no longer be enforced after
> "mount --bind /etc/ /tmp/" or "mount --bind /etc/passwd /tmp/passwd" or
> "mv /etc/passwd /tmp/passwd" or "ln /etc/passwd /tmp/passwd" is done.

That's a fundamental limitation of pathname-based security though.
If the same file exists in two places, you have to resolve the question
of which rule overrides the other.

In my role as a sysadmin, I would consider it a flaw if someone could
edit a file I'd marked uneditable -- simply by creating a hard-link to it.
If we look at existing systems, such as the immutable bit, those apply to
inodes, not to paths, so they can't be evaded.  If a system such as TOMOYA
allows evasion this easily, then it doesn't seem like an improvement.

So when considering your problem, I worked from the point of view of the
attacker "Oh, I can't modify /etc/passwd?  In that case, I'll create
a new name to the same file", and then figured out a defense to it.
I did not consider the case where the admin /wants/ to allow access
through different pathnames to the same file that's denied access.
That doesn't seem like a secure system to me.

In short, if a file is named as protected, I think the admin clearly
means to protect that file -- no matter what name is used to address it.

> If rules are described like "No modifications to passwd_t",
> it is correct to deny modifications of the file when the file
> with passwd_t was renamed or bind-mounted or hard-linked.
> Those who want to do access restriction based on the entity of the file
> prefer rules described using inodes (or labels).
> 
> If rules are described like "No modifications to /etc/passwd" and
> "Allow modifications to /tmp/passwd", it is wrong to deny modifications of
> the file when /etc/passwd was renamed or bind-mounted or hard-linked to
> /tmp/passwd .
> Those who want to do access restriction based on the location of the file
> prefer rules described using pathnames.

My impression of pathname-based security was that it was preferred
because it's easier to administer than setting labels and making sure
everything has the right capabilities.  But from what you're saying,
it seems like it's no additional security at all.

Let's take an example.  We have the two rules "nobody can edit
/etc/passwd" and "root can edit /tmp/passwd".  A daemon running as root
is compromised.  Instead of being able to simply write to /etc/passwd,
the attacker has to "ln /etc/passwd /tmp" first.  There's no additional
security here, just obfuscation.

So I say a 'DENY' rule must always override an 'ALLOW' rule where two
filenames happen to map to the same file.  Or it's just snake-oil.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
