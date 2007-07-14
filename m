From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Fri, 13 Jul 2007 19:06:56 -0600
Message-ID: <m13azreqtr.fsf@ebiederm.dsl.xmission.com>
References: <20070713200515.GS5549@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764165AbXGNBH1@vger.kernel.org>
In-Reply-To: <20070713200515.GS5549@austin.ibm.com> (Linas Vepstas's message
	of "Fri, 13 Jul 2007 15:05:15 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linas@austin.ibm.com (Linas Vepstas) writes:

> This is a patch (& bug report) for a crash in sysctl_set_parent() 
> in 2.6.22-git2. 
>
> Problem: 2.6.22-git2 crashes with a stack trace 
> [c000000001d0fb00] c000000000067b4c .sysctl_set_parent+0x48/0x7c
> [c000000001d0fb90] c000000000069b40 .register_sysctl_table+0x7c/0xf4
> [c000000001d0fc30] c00000000065e710 .devinet_init+0x88/0xb0
> [c000000001d0fcc0] c00000000065db74 .ip_rt_init+0x17c/0x32c
> [c000000001d0fd70] c00000000065deec .ip_init+0x10/0x34
> [c000000001d0fdf0] c00000000065e898 .inet_init+0x160/0x3dc
> [c000000001d0fea0] c000000000630bc4 .kernel_init+0x204/0x3c8
>
> A bit of poking around makes it clear what the problem is:
> In sysctl_set_parent(), the for loop 
>
>    for (; table->ctl_name || table->procname; table++) {
>
> walks off the end of the table, and into garbage.  Basically,
> this for-loop iterator expects all table arrays to be 
> "null terminated".  However, net/ipv4/devinet.c statically 
> declares an array that is not null-terminated.  The patch 
> below fixes that; it works for me.  Its somewhat conservative;
> if one wishes to assume that the compiler will always zero out
> the empty parts of the structure, then this pach can be shrunk 
> to one line: +	ctl_table		devinet_root_dir[3];
>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>
> ----
> I tried to audit some of the code to see where else there 
> might be similar badly-formed static declarations.  This is hard,
> as there's a lot of code. Most seems fine.

Right.  I believe I performed a similar audit not to long ago
when everything was converted to C99 initializers and everything
was fine then.


>  net/core/neighbour.c |    4 ++++
>  net/ipv4/devinet.c   |    7 ++++++-
>  2 files changed, 10 insertions(+), 1 deletion(-)
>
> Index: linux-2.6.22-git2/net/ipv4/devinet.c
> ===================================================================
> --- linux-2.6.22-git2.orig/net/ipv4/devinet.c 2007-07-13 14:23:21.000000000
> -0500
> +++ linux-2.6.22-git2/net/ipv4/devinet.c 2007-07-13 14:24:15.000000000 -0500
> @@ -1424,7 +1424,7 @@ static struct devinet_sysctl_table {
>  	ctl_table		devinet_dev[2];
>  	ctl_table		devinet_conf_dir[2];
>  	ctl_table		devinet_proto_dir[2];
> -	ctl_table		devinet_root_dir[2];
> +	ctl_table		devinet_root_dir[3];
>  } devinet_sysctl = {
>  	.devinet_vars = {
>  		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
> @@ -1493,8 +1493,13 @@ static struct devinet_sysctl_table {
>  			.data		= &ipv4_devconf.loop,
>  			.maxlen		= sizeof(int),
>  			.mode		= 0644,
> +			.child	= 0x0,
>  			.proc_handler	= &proc_dointvec,
>  		},
Where did this entry above in devinet_sysctl come from?
> +		{
> +			.ctl_name	= 0,
> +			.procname	= 0,
> +		},
I probably would have just done:
+		{},
>  	},
>  };
>  

What added the additional entry to devinet_root_dir?  I don't see that
in Linus' tree?

The result may be fine but if it isn't named in a per network device
manner we are adding duplicate entries to the root /proc/sys directory
which is wrong.

Actually come to think of it I am concerned that someone added a
settable entry into /proc/sys/ it should at least be in /proc/sys/net/
where it won't conflict with other uses of that directory.  Especially
as things like network devices have user controlled names.

Eric
