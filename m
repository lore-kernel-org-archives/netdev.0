From: Crispin Cowan <crispin@crispincowan.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Mon, 14 Apr 2008 20:21:42 -0700
Message-ID: <48041F46.8030004@crispincowan.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp> <20080409131151.GK11962@parisc-linux.org> <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp> <20080411143013.GB11962@parisc-linux.org> <4802B63F.2010804@crispincowan.com> <20080414134858.GV11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.dotsterhost.com ([66.11.233.1]:43210 "HELO
	mail8.dotsterhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1762099AbYDODWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 23:22:02 -0400
In-Reply-To: <20080414134858.GV11962@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Wilcox wrote:
> On Sun, Apr 13, 2008 at 06:41:19PM -0700, Crispin Cowan wrote:
>   
>> Rather, it is "can write to /tmp/ntpd/*". You *grant* permissions. You 
>> do *not* throw deny rules.
>>     
> So primarily we're concerned here with things that are running as root,
> daemons and the like.  Normal unix file permissions (or ACLs, if you
> must) are adequate to handle anything not running as uid 0.
>   
That's not true. Both AppArmor and SELinux Targeted Policy address 
confinement of both root and non-root applications. Examples:

    * Confining even non-root applications keeps them from accessing
      world and group accessible files.
    * Many services run as nobody instead of root, and smarter ones
      create themselves a new UID to run as. Even so, confining them is
      useful because the least-privilege posture is much easier to
      specify and verify in a capability model (as SELinux and AppArmor
      are) than an ACL model (as permission bits on files are).
    * You may want to confine a desktop application. E.g. Pidgin is a
      great IM tool because it speaks so many protocols, but with that
      large functionality comes a large attack surface, and it has had
      vulnerabilities from time to time. A confined IM client can be
      configured to only have access to your IM files, and not e.g. your
      SSH private keys.


> I don't see what apparmour and tomoya buy us that namespaces can't.
>   
Controlled overlap. You can use AppArmor to confine every *individual* 
piece of a web site shopping cart, and yet they still can interact with 
each other by sharing files. You cannot do that with namespaces.

Conversely, it is very convenient to use namespaces to set up private 
virtual domains, and that is not at all convenient to do with AppArmor, 
TOMOYO, or SELinux.

The correct answer is to use namespaces for total isolation (virtual 
domain hosting) and LSM confinement tools for security within a virtual 
domain.

> Maybe a nicer interface, but that's something that a nice userspace
> management interface can handle.
>   
Not true. Ease of management of access control is about the security 
model. Cute GUIs help, but not much.

> Create an empty namespace.  Create /tmp/ntpd in it.  Bind the outside
> /tmp/ntpd onto that directory.  Presto, the equivalent to an allow-rule
> of 'can write to /tmp/ntpd/*'.
>   
Now get ntpd to show you that you need to do this, in one pass. If you 
already know all of the files to be accessed, and you are going to write 
the security policy by hand, then the two approaches might be kind of 
comparable. But that's not how AppArmor policies are created. This is 
not a minor distinction.

> The equivalent of 'can read, but not write /home/crispin/.ssh/id_rsa.pub'
> will need r-o bind mounts, which Miklos seems to have become distracted
> from by working on the hooks for TOMOYA.
>
> Do you have a good example of something that apparmour can protect against
> that namespaces can't?
>   
See above. The major classes of things that namespaces can't do are:

    * deliberate overlap
    * learning mode
    * wild cards, e.g. 'can read /var/www/**.html' to grant access to
      all of the HTML files in the tree, but not the .pl source code files

Crispin

-- 
Crispin Cowan, Ph.D.               http://crispincowan.com/~crispin
The Olympic Games: Symbolizing oppressiiion and corruption for over a
hundred years


