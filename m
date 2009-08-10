From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: module loading permissions and request_module permission
	inconsistencies
Date: Mon, 10 Aug 2009 16:23:08 -0400
Message-ID: <20090810202308.GA15390@hmsreliant.think-freely.org>
References: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kees@ubuntu.com, morgan@kernel.org, serue@us.ibm.com,
	casey@schaufler-ca.com, dwlash@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 03:45:13PM -0400, Eric Paris wrote:
> I'd like to hear thoughts on how we currently do permissions handling on
> request_module() and if it really makes sense?  request_module() is the
> function which will do an upcall to try to get modprobe to load a
> specified module into the kernel.  It is called in a lot of places
> around the kernel (~128).  Of those places only three check to see if
> the REQUESTING process has some sort of module loading permissions
> (CAP_SYS_RAWIO.)  Those three are in net/core/dev.c::dev_load() and in
> the IPv4 tcp congestion code in tcp_set_default_congestion_control() and
> tcp_set_congestion_control().  All 125 other calls to request_module()
> appear to be done without any permissions check against the triggering
> process.  The actual loading of a module is done in another thread which
> always has permissions, so that side of things appears to not be an
> issue.
> 
> First question, why does networking do it's own CAP_SYS_MODULE checks?
> (this is VERY old code, pre-git days)  And, does it make sense?  In the
> past this has come up in [1] when /sbin/ip triggered the loading of a
> module to get IPv6 tunnel support.  It's perfectly reasonable
> for /sbin/ip to do this.  But is it reasonable for /sbin/ip to need
> CAP_SYS_MODULE?  CAP_SYS_MODULE says that /sbin/ip has permissions to
> load any arbitrary binary it feels like as a kernel module directly.  Is
> this really what we want?  Should SELinux have to give a hacked /sbin/ip
> permissions to load any arbitrary module?  Recently in [2] we find that
> now bluetoothd needs to be granted permissions to directly load any
> kernel module it pleases, just so it can request the upcall loads bnep.
> The same holds basically true for congestion control hooks.  Note that
> I'm saying we are giving permission for these to load kernel modules
> directly, not just through the upcall.
> 
> Nowhere else in the kernel do we do CAP_SYS_MODULE checks on the
> triggering side of request_module() and, as I assume at least one of
> those allows the user to control the module name, it seems to me that
> the current checks are actually lowering the security bar.  We are
> granting wide dangerous permissions to binaries when a more directed
> permission would be much more sensible.  And we are doing it for no
> security gain since I assume we have 10's if not more than 100 other
> ways around it.
> 
> The second problem is this lack of control over the rest of the users of
> request_module().  If we looks at [3] we see that this oversight created
> an interesting and useful situation for a xen framebuffer exploit.  They
> created an invalid binary and tried to execute it.  This caused the
> kernel to enter search_binary_handler() which in turn called
> request_module() which triggered the modprobe upcall and the were able
> to load a module which they controlled.  As soon as they got their
> module into the kernel it was game over for everything.  So we really
> should be trying to prevent modules from getting into the kernel.  There
> is no security hook on the triggering side and the security hook on the
> other side always passes (and needs to always pass)
> 
> I recommend we make 2 changes to better our situation:
> 
> 1) remove CAP_SYS_MODULE from the networking code and instead check
> CAP_NET_ADMIN.  Maybe CAP_NET_ADMIN is already being checked and I'll
> just remove the capable call altogether but at least I can more
> intelligently limit the powers of these processes and they will still be
> root limited according to DAC permissions like they are today.
> 
Would this have any adverse effect on how user space sees this working.
Intuitively I would think that if you wanted to load a module (directly or
indirectly, via an iptables command or whatnot), you would need CAP_SYS_MODULE
capabilities on the calling process, not just CAP_NET_ADMIN.  I honestly don't
know the answer here, I'm just raising the question.

> 2) Add a new security hook inside request_module().  On a non-selinux
> system this would be a noop hook and all 128 callers of request_module()
> would perform exactly as they do today.  On SELinux systems I would add
> a new permission to see if a process was allowed to trigger a module
> load.  This permission would need to be added for things like /sbin/ip
> which are supposed to be allowed to trigger module loading, but would
> allow us to prevent [3] from taking place.
> 
This seems perfectly reasonable to me.

Neil

> Please, comments?  Thoughts?  What did I miss?
> 
> -Eric
> 
> [1] SELinux blocks IPv6 Tunnel
> https://bugzilla.redhat.com/show_bug.cgi?id=241401
> 
> [2] SELinux blocks bluetooth
> https://bugzilla.redhat.com/show_bug.cgi?id=481618
> 
> [3] xenfb exploit
> http://invisiblethingslab.com/pub/xenfb-adventures-10.pdf
>   page 6 section 3.4
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
