From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Fri, 12 Dec 2008 16:24:46 -0500
Message-ID: <1229117086.3134.22.camel@localhost.localdomain>
References: <49381644.8020502@intel.com>
	 <20081204175236.GA19808@x200.localdomain>
	 <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	 <20081204.102138.123959105.davem@davemloft.net>
	 <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	 <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
	 <m1bpvrslk0.fsf@frodo.ebiederm.org>
	 <1228486339.20274.3.camel@localhost.localdomain>
	 <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>
	 <20081212052420.GA14948@x200.localdomain>
	 <alpine.LRH.1.10.0812122022520.32426@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Eric Paris <eparis@parisplace.org>,
	Daniel J Walsh <dwalsh@redhat.com>
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:41890 "EHLO mummy.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816AbYLOMPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 07:15:08 -0500
In-Reply-To: <alpine.LRH.1.10.0812122022520.32426@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-12 at 20:26 +1100, James Morris wrote:
> On Fri, 12 Dec 2008, Alexey Dobriyan wrote:
> 
> > Yes, please, someone test it.
> 
> Still getting avc denials:
> 
> avc:  denied  { mount } for  pid=2308 comm="dhclient" name="/" 
> dev=proc/net ino=4026531842 scontext=unconfined_u:system_r:dhcpc_t:s0-s0:c0.c1023 
> tcontext=system_u:object_r:proc_t:s0 tclass=filesystem
> type=SYSCALL msg=audit(1229073699.174:53): arch=c000003e syscall=2 
> success=no exit=-2 a0=45bef7 a1=80000 a2=1b6 a3=7f296
> e71c6f0 items=0 ppid=2259 pid=2308 auid=0 uid=0 gid=0 euid=0 suid=0 
> fsuid=0 egid=0 sgid=0 fsgid=0 tty=ttyS0 ses=1 comm="
> dhclient" exe="/sbin/dhclient" 
> subj=unconfined_u:system_r:dhcpc_t:s0-s0:c0.c1023 key=(null)
> 
> It seems the problem is that the /proc/net mountpoint is now labeled as 
> proc_t.

No, that's a check against the filesystem (superblock) label, not the
mountpoint directory.

proc_net_follow_link() creates a new mount, so we end up hitting
security_sb_kern_mount() => selinux_sb_kern_mount() and triggering this
permission check in the context of the current process on what is
supposed to be a kernel-internal mount of /proc/net.

Maybe pass flags down to security_sb_kern_mount() and skip the check in
the MS_KERNMOUNT case?

-- 
Stephen Smalley
National Security Agency

