From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: Kernel stack overflow on 2.6.9-rc2
Date: Tue, 14 Sep 2004 13:55:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0409141340540.4262@chaos>
References: <200409141723.35009.vda@port.imtp.ilyichevsk.odessa.ua>
 <20040914163347.GE3197@schnapps.adilger.int>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Linux kernel <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Dilger <adilger@clusterfs.com>
In-Reply-To: <20040914163347.GE3197@schnapps.adilger.int>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Has anybody ever explained why there is an attempt to
minimize the size of the kernel stack? Temporary data
allocation on the stack is FREE! The compiler just
adjusts offsets for data. Even dynamic data-allocation
takes only one instruction, (subl %reg, %esp).

On Intel machines, the compiler requires that SS and DS
be the same so that data can be accessed off the stack.
That means that the stack-pointer is just some arbitrary
offset in the segment(s) with enough room for downward
growth. Changing if from the original 0x1000 (one Intel
PAGE_SIZE) to anything smaller is weird, sort of like a
contest to see how long one can hold the wrong end of
a torch.

It seems that some hole got opened up with the PREEMPTABLE
KERNEL changes (read recursion). Removing stack data allocation
just masks a far more egregious problem, I think.


On Tue, 14 Sep 2004, Andreas Dilger wrote:
> On Sep 14, 2004  17:23 +0300, Denis Vlasenko wrote:
> > I am putting to use an ancient box. Pentium 66.
> > It gives me stack overflow errors on 2.6.9-rc2:
> >
> > To save you filtering out functions with less than 100
> > bytes of stack:
> >
> > udp_sendmsg+0x35e/0x61a [220]
> > sock_sendmsg+0x88/0xa3 [208]
> > __nfs_revalidate_inode+0xc7/0x308 [152]
> > nfs_lookup_revalidate+0x257/0x4ed [312]
> > load_elf_binary+0xc4f/0xcc8 [268]
> > load_script+0x1ea/0x220 [136]
> > do_execve+0x153/0x1b9 [336]
>
> do_execve() can be trivially fixed to allocate bprm (328 bytes) instead
> putting it on the stack.  Given the frequency of exec and the odd size
> it should probably be in its own slab (and fix the goofy prototype
> indenting while you're there too ;-).
>
> load_elf_binary() on the other hand is a big mess, 132 bytes of int/long
> variables.
>
> nfs_lookup_revalidate() has 2 large structs on the stack, fhandle and fattr.
>
> Cheers, Andreas
> --
> Andreas Dilger
> http://sourceforge.net/projects/ext2resize/
> http://members.shaw.ca/adilger/             http://members.shaw.ca/golinux/
>
>

Cheers,
Dick Johnson
Penguin : Linux version 2.4.26 on an i686 machine (5570.56 BogoMips).
            Note 96.31% of all statistics are fiction.
