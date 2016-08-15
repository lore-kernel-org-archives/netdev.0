From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC 0/4] RFC: Add Checmate, BPF-driven minor LSM
Date: Mon, 15 Aug 2016 10:03:50 -0700
Message-ID: <20160815170348.GD31242@ircssh.c.rugged-nimbus-611.internal>
References: <20160804071116.GA19098@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKfjKPuGO98S5XwVSuOcimLtZD6Y9WRQ9pvdBa16TQyFw@mail.gmail.com>
 <20160809000015.GA9866@ircssh.c.rugged-nimbus-611.internal>
 <CAGXu5jKJTqb25vE_TyRiv1X3tg-dU3OLXh+FxPfcBhxmQoOZ=A@mail.gmail.com>
 <57B0F768.8000307@digikod.net>
 <20160815030952.GC31242@ircssh.c.rugged-nimbus-611.internal>
 <57B1A081.9030209@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kees Cook <keescook@chromium.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Reshetova, Elena" <elena.reshetova@intel.com>
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57B1A081.9030209@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 15, 2016 at 12:59:13PM +0200, Mickaël Salaün wrote:
> 
> On 15/08/2016 05:09, Sargun Dhillon wrote:
> > On Mon, Aug 15, 2016 at 12:57:44AM +0200, Mickaël Salaün wrote:
> >> Our approaches have some common points (i.e. use eBPF in an LSM, stacked 
> >> filters like seccomp) but I'm focused on a kind of unprivileged LSM (i.e. no 
> >> CAP_SYS_ADMIN), to make standalone sandboxes, which brings more constraints 
> >> (e.g. no use of unsafe functions like bpf_probe_read(), take care of privacy, 
> >> SUID exec, stable ABI…). However, I don't want to handle resource limits, 
> >> which should be the job of cgroups.
> >>
> > Kind of. Sometimes describing these resource limits is difficult. For example, I 
> > have a customer who is trying to restrict containers from burning up all the 
> > ephemeral ports on the machine. In this, they have an incredibly elaborate chain 
> > of wiring to prevent a given container from connecting to the same (proto, 
> > destip, destport) more than 1000 times.
> > 
> > I'm unsure of how you'd model that in a cgroup. 
> 
> This looks like a Netfilter rule. Have you tried applying this limitation with the connlimit module?
> 
> 
I could do this by adding a new Netfilter match, but with the existing matches, 
the only ones that "select" by cgroup2 don't have the ability to connlimit by 
cgroup. Potentially, I could wire up something with the cgroup2 match, but this 
comes with a lot of overhead. If you know of a low-overhead way of doing this, 
I'd love to hear.

Have you ever user Kubernetes? (http://kubernetes.io/docs/whatisk8s/)? You 
usually have a bunch of independent systems running together under what's called 
a "Pod". You can think of this as an old style "lxc" container, or a VM, and in 
each of these pods there is nesting where you want to not only limit the pod's 
resources, but you also want to limit the resources of each application. Doing 
this without some layer of programmability in resource management layer can be 
difficult.

> > 
> >> For now, I'm focusing on file-system access control which is one of the more 
> >> complex system to properly filter. I also plan to support basic network access 
> >> control.
> >>
> >> What you are trying to accomplish seems more related to a Netfilter extension 
> >> (something like ipset but with eBPF maybe?).
> >>
> > I don't only want to do network access control, I also want to write to the 
> > value once it's copied into kernel space. There are lot of benefits of doing 
> > this at the syscall level, but the two primary ones are performance, and 
> > capability. 
> > 
> > One of the biggest complaints with our current approach to filtering & load 
> > balancing (iptables) is that it hides information. When people connect through 
> > the load balancer, they want to find out who they connected to, and without some 
> > high application-level mechanism, this isn't possible. On the other hand, if we 
> > just rewrite the destination address in the connect hook, we can pretty easily
> > allow them to do getpeername.
> 
> What exactly is not doable with Netfilter (e.g. REDIRECT or TPROXY)?
> 
> 
Is there a way to "load balance" or "proxy" a connection where getpeername() 
tells you the real IP of the node you're connected to?

> > 
> > I'm curious about your filesystem access limiter. Do you have a way to make it so
> > that a given container can only write, say, 100mb of data to disk? 
> 
> It's a filesystem access control. It doesn't deal with quota and is not focused on container but process hierarchies (which is more generic).
> 
> What is not doable with a quota mount option? It may be more appropriate to enhance the VFS (or overlayfs) to apply this kind of limitation, if needed.
> 
Your overlayfs suggesion is on point. Since a lot of my containers look similar 
to Kubernetes though, quota isn't very well aligned with them (within a Pod, 
there are usually a bunch of independent things that need their usage limited). 
I think quota / overlayfs with labeling that comes from an LSM, or some other 
smart classifier would be ideal.
