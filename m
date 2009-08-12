From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: module loading permissions and request_module permission
	inconsistencies
Date: Wed, 12 Aug 2009 18:48:55 -0500
Message-ID: <20090812234855.GA12505@us.ibm.com>
References: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kees@ubuntu.com, morgan@kernel.org, casey@schaufler-ca.com,
	dwlash@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric Paris (eparis@redhat.com):
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

Right, so taking a more extreme example, the request_module() in
search_binary_handler...  requiring CAP_SYS_MODULE there would mean
you'd have to be privileged to be the first to execute say a
binfmt_misc.

The actual modules are to be protected by protecting /lib/modules
and /sbin/modprobe themselves.  So long as those are properly
protected, the ability to cause a call to __request_module() at most
takes up more memory.

So what you say seems to make sense.

-serge
