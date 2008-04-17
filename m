From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Thu, 17 Apr 2008 09:45:22 +0100
Message-ID: <20080417084522.GA23301@shareable.org>
References: <47FC8052.9070409@nttdata.co.jp> <20080409131151.GK11962@parisc-linux.org> <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp> <20080411143013.GB11962@parisc-linux.org> <20080413163658.GC7010@sergelap.austin.ibm.com> <4802BBDC.1030707@crispincowan.com> <1208182620.18883.92.camel@moss-spartans.epoch.ncsc.mil> <48043648.1000502@crispincowan.com> <1208363519.18883.232.camel@moss-spartans.epoch.ncsc.mil> <4807011D.8060009@crispincowan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Crispin Cowan <crispin@crispincowan.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762030AbYDQIrY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4807011D.8060009@crispincowan.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Crispin Cowan wrote:
> Of *course* AppArmor protects the integrity of /etc/shadow, and 
> unauthorized parties are not permitted to feed data into that file 
> unless explicit access is granted. The difference is in how it is done:
> 
>    * SELinux marks the inode with a label, and only processes with the
>      right permissions can mess with the label.
>          o Residual problem: someone could rename the inode and drop a
>            new inode into place named "/etc/shadow". SELinux addresses
>            this with access control on the parent directory.

<small> I have actually hacked a system by renaming /etc/passwd in
this way.  /etc was owned by user "bin", and I had a login as "bin"
due to a misfeature in some program.  So I substituted another
/etc/passwd, and gave myself a root shell. </small>

The trouble with access control on the parent directory is that
occasionally some human accidentally forgets how important that is,
thinking that permissions on the /etc/shadow file are important.

Also *programs* care about a file with that name.  They reference it
by name, apply security decisions based on a process which starts with
that name.  So the name is the most relevant point of communication
between the policy setter and programs which need to be affected.

So I think AppArmor's approach is good here.

>    * AppArmor checks the name "/etc/shadow" so that you cannot access
>      that name without explicit permission.
>          o AppArmor cares about the integrity of what the OS returns
>            when you access the name "/etc/shadow" and does not care a
>            wit what happens to the inode that was *previously* named
>            "/etc/shadow".
> 
> Now, without running off into the weeds again, tell me again why I 
> should care about the *integrity* of an inode that was *previously* 
> known as "/etc/shadow"?

But insufficient here.

If you rename /etc/shadow legitimately, after changing a password,
there might be a program which still has a handle to the _old_ inode
and is still reading it, still comparing a password against its contents.

If policy was entirely name based, so modifications may be possible to
that file after it's renamed from /etc/shadow to /etc/shadow.bak,
_while_ some programs are still reading it (because it was /etc/shadow
when they opened it, and they got swapped for a moment), that's a failure.

So you *should* care about the integrity of an inode that was
previously known as /etc/shadow - at least until you can prove that
nobody is still dependent on it's earlier security properties.  That's
a garbage collection problem.

> So associating a security property with a name is ok if you do it 
> statically at some arbitrary point in time, but not if you consider it 
> at the time of access? WtF? Isn't that a gigantic race condition?

Both are race conditions.

> To the contrary, I argue that the *current* name of a file is vastly 
> more meaningful for security properties than the name the file had some 
> months ago when someone ran restorecon over the file system.

I agree that the current name is meaningful, but it's not watertight
when your systems change.  To avoid unexpected weaknesses, you'll need
to apply the intersection of permissions over a time period, using
name based policy but having it follow renames until you can prove
it's safe to release the following.

-- Jamie
