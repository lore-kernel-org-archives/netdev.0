From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [TEST_PATCH]Re: Fw: Oops in register_proc_table (2.6.1-mm4)
Date: Mon, 19 Jan 2004 11:49:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401191146250.20265-100000@linux-udp15191261uds.beaverton.ibm.com>
References: <OFB49626C9.096C6A6C-ON87256E20.006D3112@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <thomas.schlichter@web.de>, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <OFB49626C9.096C6A6C-ON87256E20.006D3112@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Can you test with following patch ?

thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6/net/ipv6/route.c linux-2.6.0-rc2-bk6.new/net/ipv6/route.c
--- linux-2.6.0-rc2-bk6/net/ipv6/route.c	2004-01-19 11:41:14.000000000 -0800
+++ linux-2.6.0-rc2-bk6.new/net/ipv6/route.c	2004-01-19 11:42:33.000000000 -0800
@@ -1974,6 +1974,7 @@
          	.proc_handler	=	&proc_dointvec_jiffies,
 		.strategy	=	&sysctl_jiffies,
 	},
+	{ .ctl_name = 0 }
 };

 #endif

> OK, I can reproduce this oops now.
>
> 0xc0126f7d in register_proc_table (table=0xc04cc80c, root=0xcff92600) at
> string.h:182
> 182     __asm__ __volatile__(
> (gdb) bt
> #0  0xc0126f7d in register_proc_table (table=0xc04cc80c, root=0xcff92600)
> at string.h:182
> #1  0xc0126fcb in register_proc_table (table=0xc04cd540, root=0xcff92680)
> at sysctl.c:1187
> #2  0xc0126fcb in register_proc_table (table=0xc04cf624, root=0xcff95680)
> at sysctl.c:1187
> #3  0xc0126fcb in register_proc_table (table=0xc0451958, root=0xcffa0380)
> at sysctl.c:1187
> #4  0xc051f727 in sysctl_init () at sysctl.c:854
> #5  0xc0105169 in init (unused=0x0) at init/main.c:557
> (gdb) f 3
> #3  0xc0126fcb in register_proc_table (table=0xc0451958, root=0xcffa0380)
> at sysctl.c:1187
> 1187                            register_proc_table(table->child, de);
> (gdb) p *table
> $1 = {ctl_name = 3, procname = 0xc043394e "net", data = 0x0, maxlen = 0,
> mode = 365, child = 0xc04cf5a0,
>   proc_handler = 0, strategy = 0, de = 0xcff95680, extra1 = 0x0, extra2 =
> 0x0}
> (gdb) f 2
> #2  0xc0126fcb in register_proc_table (table=0xc04cf624, root=0xcff95680)
> at sysctl.c:1187
> 1187                            register_proc_table(table->child, de);
> (gdb) p *table
> $2 = {ctl_name = 12, procname = 0xc0431b88 "ipv6", data = 0x0, maxlen = 0,
> mode = 365,
>   child = 0xc04cd540, proc_handler = 0, strategy = 0, de = 0xcff92680,
> extra1 = 0x0, extra2 = 0x0}
> (gdb) f 1
> #1  0xc0126fcb in register_proc_table (table=0xc04cd540, root=0xcff92680)
> at sysctl.c:1187
> 1187                            register_proc_table(table->child, de);
> (gdb) p *table
> $3 = {ctl_name = 18, procname = 0xc0431402 "route", data = 0x0, maxlen = 0,
> mode = 365,
>   child = 0xc04cc680, proc_handler = 0, strategy = 0, de = 0xcff92600,
> extra1 = 0x0, extra2 = 0x0}
> (gdb) f 0
> #0  0xc0126f7d in register_proc_table (table=0xc04cc80c, root=0xcff92600)
> at string.h:182
> 182     __asm__ __volatile__(
> (gdb) p *table
> $4 = {ctl_name = 1220, procname = 0x927c0 <Address 0x927c0 out of bounds>,
> data = 0x9, maxlen = 60000,
>   mode = 500, child = 0x1000, proc_handler = 0, strategy = 0, de = 0x0,
> extra1 = 0x0, extra2 = 0x0}
>
> It seems that ipv6 is registering something under /proc/net/ipv6/route
> which has a bad ctl_table.procname.  I don't know what it is - the ipv6
> sysctl code overpowered my attention span.
>
> The .config is attached - 2.6.1-mm4 should demonstrate the problem.
>
> Can one of the ip6 guys please look at this?
