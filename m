From: Andy Lutomirski <luto@MIT.EDU>
Subject: Re: [EXAMPLE CODE] Parasite thread injection and TCP connection hijacking
Date: Sat, 06 Aug 2011 08:45:28 -0400
Message-ID: <4E3D3768.3070108@mit.edu>
References: <20110806121247.GC23937@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Nathan Lynch <ntl@pobox.com>,
	Oren Laadan <orenl@cs.columbia.edu>,
	Daniel Lezcano <dlezcano@fr.ibm.com>, S@mit.edu,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110806121247.GC23937@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2011 08:12 AM, Tejun Heo wrote:
> Hello, guys.
>
> So, here's transparent TCP connection hijacking (ie. checkpointing in
> one process and restoring in another) which adds only relatively small
> pieces to the kernel.  It's by no means complete but already works
> rather reliably in my test setup even with heavy delay induced with
> tc.
>
> I wrote a rather long README describing how it's working, what's
> missing which is appended at the end of this mail so if you're
> interested in the details please go ahead and read.

That's a little gross but quite cool.

I think you have an annoying corner case, though:

 > 2. Decide where to inject the foreign code and save the original code
 >    with PTRACE_PEEKDATA.  Tracer can poke any mapped area regardless
 >    of protection flags but it can't add execution permission to the
 >    code, so it needs to choose memory area which already has X flag
 >    set.  The example code uses the page the %rip is in.

If the process is executing from the vsyscall page, then you'll probably 
fail.  (Admittedly, this is rather unlikely, given that the vsyscalls 
are now exactly one instruction.)  Presumably you also fail if executing 
from a read-only MAP_SHARED mapping.

Windows has a facility to more-or-less call mmap on behalf of another 
process, and another one to directly inject a thread into a remote 
process.  It's traditional to use them for this type of manipulation. 
Perhaps Linux should get the same thing.  (Although you could accomplish 
much the same thing if you could create a task with your mm but the 
tracee's fs.)

--Andy
