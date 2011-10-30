From: David Fries <david@fries.net>
Subject: Re: hiberante hangs TCP Re: [EXAMPLE CODE] Parasite thread
 injection and TCP connection hijacking
Date: Sun, 30 Oct 2011 15:43:18 -0500
Message-ID: <20111030204318.GZ24999@spacedout.fries.net>
References: <20110806121247.GC23937@htj.dyndns.org>
 <20111030044821.GA23741@spacedout.fries.net>
 <20111030201618.GA7696@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm@lists.linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111030201618.GA7696@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 30, 2011 at 01:16:18PM -0700, Tejun Heo wrote:
> (cc'ing Rafael and linux-pm)
> 
> On Sat, Oct 29, 2011 at 11:48:21PM -0500, David Fries wrote:
> > I saw the write up on this on lwn.net, pretty creative by the way, and
> > it got me thinking about a different checkpoint/restart problem I've
> > been running into.  Specifically in hibernating to disk.  In the
> > hibernate case active TCP connections hang after resuming, while an
> > idle TCP connection will continue after the system is back up.  My
> > observation is the kernel checkpoints itself to memory, enables
> > devices, writes out that checkpoint image to storage, then powers off.
> > The problem is if TCP packets are received while writing to storage,
> > the kernel will continue to queue and ack those TCP packets, but the
> > running kernel and it's network state is shortly lost.  When the
> > computer resumes, those TCP byte sequences hang the TCP connection for
> > an extended period of time while the resumed computer refuses to
> > acknowledge the data that was received after checkpointing and the now
> > running kernel knew nothing about, and the other computer tries in
> > vain to resend any data that hadn't yet been acknowledged, which is
> > always after the data that was lost, until one of them eventually
> > gives up.
> > 
> > I've been wondering if it was safe or possible to leave any network
> > interfaces down after the checkpoint, or what the right solution would
> > be.  I didn't think marking every TCP connection with a ZOMBIE_KERNEL
> > bit just after the kernel checkpoint (for the kernel is walking dead
> > and won't remember anything that happens), and then prevent any TCP
> > acks from being sent for those connections would be the right
> > solution.  I've taken to unplugging the physical lan cable,
> > hibernating to disk, and plugging it back in after the system is down,
> > to avoid the problem.  Any ideas?
> 
> Hmmm... sounds like taking down network interfaces before starting
> hibernation sequence should be enough, which shouldn't be too
> difficult to implement from userland.  Rafael, what do you think?

What I observe is the kernel prints out "Preallocating image memory",
then when the screen goes blank the network link light also goes out,
then the screen comes back on with "Compressing and saving" along with
the link light comes on, until it has been saved and the system shuts
down.  So the kernel is already brining the network down, it just
needs to keep it there until the original check pointed kernel is back
up.

Userspace bringing the network interfaces down is problematic.  As an
example one of my systems is running hostapd as an access point and
bridging that to the wired ethernet, that's not a trivial task to
setup and take down (the Debian ifup can set it up, but I've not
figured out yet how to get ifdown to take everything down cleanly, and
I sometimes manually run hostapd if I'm troubleshooting).  Any
manually added routes would go away, good luck in setting everything
back up the way it was before for all the different configurations out
there in userspace.  Add to those issues programs would now have a
time when networking is down that they wouldn't have otherwise seen.

-- 
David Fries <david@fries.net>    PGP pub CB1EE8F0
http://fries.net/~david/
