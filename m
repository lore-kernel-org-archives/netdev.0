From: David Fries <david@fries.net>
Subject: hiberante hangs TCP Re: [EXAMPLE CODE] Parasite thread injection
 and TCP connection hijacking
Date: Sat, 29 Oct 2011 23:48:21 -0500
Message-ID: <20111030044821.GA23741@spacedout.fries.net>
References: <20110806121247.GC23937@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110806121247.GC23937@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 06, 2011 at 02:12:47PM +0200, Tejun Heo wrote:
> Hello, guys.
> 
> So, here's transparent TCP connection hijacking (ie. checkpointing in
> one process and restoring in another) which adds only relatively small
> pieces to the kernel.  It's by no means complete but already works
> rather reliably in my test setup even with heavy delay induced with
> tc.

I saw the write up on this on lwn.net, pretty creative by the way, and
it got me thinking about a different checkpoint/restart problem I've
been running into.  Specifically in hibernating to disk.  In the
hibernate case active TCP connections hang after resuming, while an
idle TCP connection will continue after the system is back up.  My
observation is the kernel checkpoints itself to memory, enables
devices, writes out that checkpoint image to storage, then powers off.
The problem is if TCP packets are received while writing to storage,
the kernel will continue to queue and ack those TCP packets, but the
running kernel and it's network state is shortly lost.  When the
computer resumes, those TCP byte sequences hang the TCP connection for
an extended period of time while the resumed computer refuses to
acknowledge the data that was received after checkpointing and the now
running kernel knew nothing about, and the other computer tries in
vain to resend any data that hadn't yet been acknowledged, which is
always after the data that was lost, until one of them eventually
gives up.

I've been wondering if it was safe or possible to leave any network
interfaces down after the checkpoint, or what the right solution would
be.  I didn't think marking every TCP connection with a ZOMBIE_KERNEL
bit just after the kernel checkpoint (for the kernel is walking dead
and won't remember anything that happens), and then prevent any TCP
acks from being sent for those connections would be the right
solution.  I've taken to unplugging the physical lan cable,
hibernating to disk, and plugging it back in after the system is down,
to avoid the problem.  Any ideas?

-- 
David Fries <david@fries.net>    PGP pub CB1EE8F0
http://fries.net/~david/
