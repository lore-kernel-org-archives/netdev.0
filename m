From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 1360] New: Can't access /proc/self/fd/0 from
 sshd when no pty allocated.
Date: Sat, 18 Oct 2003 17:27:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018172736.417bf89d.akpm@osdl.org>
References: <200310151142.h9FBgi5k029003@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dtucker@zip.com.au
In-Reply-To: <200310151142.h9FBgi5k029003@fire-1.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bugme-daemon@osdl.org wrote:
>
> http://bugme.osdl.org/show_bug.cgi?id=1360
> 
>            Summary: Can't access /proc/self/fd/0 from sshd when no pty
>                     allocated.
>     Kernel Version: 2.6.0-test7
>             Status: NEW
>           Severity: normal
>              Owner: bugme-janitors@lists.osdl.org
>          Submitter: dtucker@zip.com.au
> 
> 
> Distribution: Redhat 8 w/2.6.0-test7
> Hardware Environment: AMD K6III/500, 256MB RAM
> Software Environment: gcc-3.2-7, glibc-2.3.2-4.80.6, openssh-3.7.1p2
> Problem Description:
> 
> Basically, processes lauched from sshd without a pty can't access /proc/self/fd/0.
> 
> This is an update to bug #1357 which has been closed as invalid (because it was
> a 2.4 vendor kernel).  I can reproduce with a vanilla 2.6.0-test7 kernel but I
> can't reopen the bug.
> 
> I'm guessing this in an issue with /proc, hence the "Filesystem" category,
> however I could be wrong.
> 
> Steps to reproduce:
> $ ssh testbox "uname -a"
> Linux testbox 2.6.0-test7 #11 Wed Oct 15 20:35:16 EST 2003 i686 unknown
> 
> $ echo test | ssh 192.168.32.108 "cat /proc/self/fd/0" 
> cat: /proc/self/fd/0: No such device or address
> 
> $ echo test | ssh testbox "cat | cat /proc/self/fd/0 | cat"
> test
> 
> In the failing example, the descriptor is a socket.  In the working example, the
> descriptor is a pipe.  I don't know if this is related.
> 
> $ ssh testbox "ls -l /proc/self/fd/"
> lrwx------    1 root     root           64 Oct 16 04:50 0 -> socket:[2474]
> lrwx------    1 root     root           64 Oct 16 04:50 1 -> socket:[2474]
> lrwx------    1 root     root           64 Oct 16 04:50 2 -> socket:[2476]
> lr-x------    1 root     root           64 Oct 16 04:50 3
> ls: ls:/proc/self/fd/3: No such file or directory
> 
> $ ssh testbox "cat | ls -l /proc/self/fd/ | cat"
> lr-x------    1 root     root           64 Oct 16 04:51 0 -> pipe:[2556]
> l-wx------    1 root     root           64 Oct 16 04:51 1 -> pipe:[2557] 
> lrwx------    1 root     root           64 Oct 16 04:51 2 -> socket:[2554]
> lr-x------    1 root     root           64 Oct 16 04:51 3
> ls: ls:/proc/self/fd/3: No such file or directory
> 
> (Also occurs on kernel-2.4.20-20.8, and self-made embedded system with VIA Ezra
> CPU, 2.6.0-test7 kernel + uClibc-0.9.19 + busybox userspace)
> 
> I have a stand-alone test case which I will attach.
> 

This appears to be deliberate:

/*
 *	In theory you can't get an open on this inode, but /proc provides
 *	a back door. Remember to keep it shut otherwise you'll let the
 *	creepy crawlies in.
 */
  
static int sock_no_open(struct inode *irrelevant, struct file *dontcare)
{
	return -ENXIO;
}

I do not know why; the comment is fairly useless.
