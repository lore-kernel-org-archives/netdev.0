From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: iproute2 and kernel headers
Date: Wed, 4 Aug 2004 17:50:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805005019.GA11538@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mariusz Mazur <mmazur@kernel.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote :
> 
> On Tue, 3 Aug 2004 02:14:59 +0200 Tomasz Torcz <zdzichu@irc.pl> wrote:
> 
> > On Mon, Aug 02, 2004 at 03:38:05PM -0700, Stephen Hemminger wrote:
> > > I am willing to put some headers (not all) in with the user level
> > > code, provided they are copies since they I can easily update. I don't want
> > > to get into keeping an edited set of headers in sync.
> > 
> >  Aren't linux-libc-headers (*) sufficient?
> > 
> > * - http://ep09.pld-linux.org/~mmazur/linux-libc-headers/
> 
> The theory of that is good, but in practice it would make the problem
> worse.  What iproute2 wants is to have the same kernel data structures
> as the latest kernel.  It is awkward enough making sure to get them
> from the correct kernel sources, but doing it from a different package
> would make updating and keeping everything current worse.

	Hi Stephen,

	Sorry to bring bad news, but I wanted to share my experience
on the subject with you. This e-mail might not give you solution, but
I hope it will at least entertain you ;-)


	I have the same problem with Wireless Extensions. My thinking
was similar to yours a while back, and since then I've tried various
solutions. My personal opinion on the subject is that you have just
opened a big can of worms, and you will quickly realise that it's
worse than you initally though...

	Back when I started with Wireless Extensions, the kernel
headers in /usr/include/linux where a symbolic link to the actual
kernel headers. I was just building Wireless Tools against
/usr/include/linux/wireless.h, and magically both the tools and the
kernel were using the same defintions of various data structures.

	Then, people started to upgrade their kernel and forgot to
recompile the tools. Personally, the first thing I do when I install a
Debian stable to to wipe out the obsolete kernel and install the
latest. The end result was that the tools were crashing in all kind of
mysterious ways, because the data structs were not the same size in
the tools and the kernel.
	I learned pretty quickly that version number on the tools were
not much help. If kernel version X recommend tools version A, but
tools version A were compiled for kernel version Y, the tools will
still malfunction. And the user won't understand because he has the
"right" version.
	I tried to educate users, with notices in README and on my web
page, but after answering the same question for hundreds of time, I
felt I was wasting my time. I don't think it's possible to expect
standard users to always recompile those system tools when they
upgrade the kernel.

	This is when I introduced version number in the API. This
allows the tools to verify that they use the same version of the API
as the kernel, and complain if they are not with an explicit error
message.
	Things were somewhat better, at least the errors were no
longer mysterious and a significant number of users figured out how to
fix it by themselves.
	However, many users got very confused by the two version
numbers and their relationship.

	Around this time, /usr/include/linux was no longer a symlink
and became independant of the kernel version (what we have
today). That was another additional annoyance.
	There are some ways to get around this. One way is to poke
directly in /usr/src/linux for the header. Another is to have local
copies of all the versions of the header, and poke the current running
kernel for the API version number to select the proper version of the
header. Or you can let the user decide which version to use at
configure time. I implemented all three for wireless tools.
	Your proposal would fix this precise issue, but in the grand
scheme of things, I believe this is only one annoyance, not the main
issue. You still have data structure mismatches if the kernel and the
tools are not compiled with the same version of the kernel headers.

	By the way, one of the consequence of versioning the API is
that I tend to do most API changes in batches. The idea is that I want
to minimise the number of API versions, because I have to test the
tools and drivers with each of them, and I have finite time.
	The kernel people hate me, because I submit changes as big
batches, which is contrary to the "small patch" philosophy. The
driver/tools people hate me because the changes they depend upon are
queued up until next batch *and* they have to test for multiple
versions of the API and #define all over the place in their code. You
can't win...

	Soon after that, the distribution people started to hate
me. Many of their users were seeing my message about API mismatche and
rep[orting it as a bug. Distro only offer one prepackaged version of
the tools ; Some distro offer multiple kernel options (Debian), or
offer prepackaged kernel updates (Red-Hat). Of course, the tools would
match only one version of the kernel, and not the other ones. Distro
went as far as just disable my error message, because it was confusing
their users too much, and live with the broken functionality.
	Let's also not forget people like me having multiple kernels
on the same system (like one 2.4.X and one 2.6.X kernels in my
case). You don't want to recompile your tools each time you boot the
other kernel.

	I tried to have a system where I would compile the tools with
different versions of the API (i.e. create multiple binaries), and
have a small dispatcher that would call the right version of the tools
depending on the running kernel. That was working, but just ugly and
fragile.
	The current solution is that I implemented a layer that
translate those data structures from one version to another. I read
the version of the API and translate the structure to whatever the
tool is expecting. Basically, a single binary dynamically support
multiple versions of the API and multiple kernels.
	This works for me because the number of API versions and data
structures is limited. I'm not sure if it would work for everybody...

	Now, that's my story. Other people have their own stories, and
for example I would ask the netfilter people how they deal with this
problem.

	Now, my sick brain would like to suggest a few other crazy
solutions totally out of the box :

	1) Get it right the first time, so no change is ever
needed. If things are standardised (POSIX, IEEE), this can work, if
you are called Linus, most likely, otherwise, good luck...

	2) Migrate all those kernel APIs to XML. XML is the future,
you can validate the output, and you can add/remove nodes/attributes
between versions without the full thing falling apart. And we already
have a web server in the kernel.

	3) Every time you need to change the API, migrate it to
another delivery mechanism and create a totally different set of
tools. If you were using ioctl, migrate to netlink. If you were using
netlink, migrate to a pseudo filesystem. Obviously the holy grail is
to make it a system call. Also, make sure to kill the old APIs and old
tools, otherwise some other folks my continue to maintain it.

	4) Distribute all those system utilities as part of the
kernel, compile them as part of the kernel, and install them in a
kernel specific directory. Basically, treat system utilities exactly
the same way as kernel modules.
	That actually would go a long way toward solving the issue of
distribution of system utils (where is module-init-tools ?) and push
more people to implement their pet project in user space rather than
in the kernel.

	I wish you a lot of luck exploring those issues, and if one of
those long nights you have a Eureka moment, please share with us ;-)
	Have fun...

	Jean
