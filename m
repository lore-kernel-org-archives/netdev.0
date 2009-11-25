From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [E1000-devel] TCP sockets stalling - help! (long)
Date: Thu, 26 Nov 2009 00:29:45 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911252337140.5299@melkinpaasi.cs.helsinki.fi>
References: <4B0CB1B8.8030402@shiftmail.org> <alpine.DEB.2.00.0911251344520.7024@wel-95.cs.helsinki.fi> <4B0D2C0E.9050101@shiftmail.org> <4B0D4EFC.4050302@shiftmail.org> <4B0D5D86.8010509@shiftmail.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1820343251-1259185497=:5299"
Cc: e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: Asdo <asdo@shiftmail.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59224 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759589AbZKYW3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 17:29:40 -0500
In-Reply-To: <4B0D5D86.8010509@shiftmail.org>
Content-ID: <alpine.DEB.2.00.0911260017100.5299@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1820343251-1259185497=:5299
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911252348161.5299@melkinpaasi.cs.helsinki.fi>

On Wed, 25 Nov 2009, Asdo wrote:

> Asdo wrote:
> > Asdo wrote:
> > > Ilpo Järvinen wrote:
> > >  
> > > > ...I'd next try strace the sftp server to see what it was doing during
> > > > the stall.
> > > >       
> > > Thanks for your help Ilpo
> > > 
> > > Isn't the strace equivalent to the stack trace I obtained via cat
> > > /proc/pid/stack reported previously? That was at the time of the stall
> > > 
> > > I'm thinking the strace would slow down sftp-server very deeply...
> > >   
> > 
> > I found out that if I attach the strace I can see at least the last function
> > call.
> > The SFTP it's hanged right now so I did that:
> > 
> > root@mystorage:/root# strace -p 11475
> > Process 11475 attached - interrupt to quit
> > select(5, [3], [], NULL, NULL
> > 
> > (stuck here forever... doesn't move)
> > (it's strange the first option of select is 5, shouldn't it be 4 from man
> > select? A bug of strace maybe?)
> > 
> > root@mystorage:/root# cat /proc/11475/stack
> > [<ffffffff8112e644>] poll_schedule_timeout+0x34/0x50
> > [<ffffffff8112ef4f>] do_select+0x58f/0x6b0
> > [<ffffffff8112f8b5>] core_sys_select+0x185/0x2b0
> > [<ffffffff8112fc32>] sys_select+0x42/0x110
> > [<ffffffff8101225b>] tracesys+0xd9/0xde
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > And this is from cat /proc/net/tcp   2: 0F12A8C0:0016 2512A8C0:0FBD 01
> > 00000000:00000000 02:00009144 00000000     0        0 5326251 2
> > ffff88085408ce00 26 4 1 9 4
> > 
> > The select refers to open files so here they are:
> > 
> > 
> > root@mystorage:/proc/11475/fd# ll
> > total 0
> > lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 0 -> pipe:[5326309]
> > l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 1 -> pipe:[5326310]
> > l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 2 -> pipe:[5326311]
> > lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 3 -> pipe:[5326309]
> > l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 4 -> pipe:[5326310]
> > l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 5 ->
> > /path/to/file_being_saved.filepart
> > 
> > I tried to send SIGSTOP and then SIGCONT to see if I could make it make a
> > loop and then reenter into the select. I'm not sure it really did that, what
> > do you think? This is the strace:
> > root@mystorage:/root# strace -p 11475 2>&1 | tee sftpstrace.dmp
> > Process 11475 attached - interrupt to quit
> > select(5, [3], [], NULL, NULL)          = ? ERESTARTNOHAND (To be restarted)
> > --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> > --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> > select(5, [3], [], NULL, NULL)          = ? ERESTARTNOHAND (To be restarted)
> > --- SIGCONT (Continued) @ 0 (0) ---
> > select(5, [3], [], NULL, NULL
> > 
> > (hanged again here)
> > 
> > 
> > Do you think this info is enough or I really have to strace it since the
> > beginning?
> > If it is a race condition it might not happen if the sftp-server is deeply
> > slowed down by the strace.
> > If I had a way to make it continue right now we could get the rest of the
> > strace... But it's not so easy, I tried starting a Samba transfer but it did
> > not unlock the SFTP this time. SIGSTOP + SIGCONT also didn't work.
> > 
> > BTW people using the Storage also experienced data loss while pushing files
> > in it: appartently data disappeared from the middle of a file they were
> > saving to the Storage.
> > To me looks like another hint that application-level data which has been
> > received via network by TCP stack is trapped there and not being pushed to
> > the application.
> > Or the data might even be trapped into the anonymous sockets between sshd
> > and sftp-server.
> > 
> > Thanks for your help
> 
> I thought that it would be more meaningful to try the cat stack, the strace
> and the SIGSTOP SIGCONT tricks on the sshd which actually holds the TCP
> socket, instead of the sftp-server. Here they are, on the sshd:
> 
> root@mystorage:/root# strace -p 11449 2>&1 | tee -a sshd1strace1.dmp
> Process 11449 attached - interrupt to quit
> read(5, 0x7fff4e956220, 4)              = ? ERESTARTSYS (To be restarted)
> --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> read(5, 0x7fff4e956220, 4)              = ? ERESTARTSYS (To be restarted)
> --- SIGCONT (Continued) @ 0 (0) ---
> read(5,
> 
> (hanged again here after the SIGSTOP + SIGCONT, unfortunately)
> 
> root@mystorage:/root# cat /proc/11449/stack
> [<ffffffff814b428a>] unix_stream_data_wait+0xaa/0x110
> [<ffffffff814b50cd>] unix_stream_recvmsg+0x36d/0x570
> [<ffffffff81426399>] sock_aio_read+0x149/0x150
> [<ffffffff8111e232>] do_sync_read+0xf2/0x130
> [<ffffffff8111e8e1>] vfs_read+0x181/0x1a0
> [<ffffffff8111edec>] sys_read+0x4c/0x80
> [<ffffffff8101225b>] tracesys+0xd9/0xde
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> root@mystorage:/proc/11449/fd# ll
> total 0
> lrwx------ 1 root root 64 2009-11-25 14:43 0 -> /dev/null
> lrwx------ 1 root root 64 2009-11-25 14:43 1 -> /dev/null
> lrwx------ 1 root root 64 2009-11-25 14:43 2 -> /dev/null
> lrwx------ 1 root root 64 2009-11-25 14:43 3 -> socket:[5326251]
> lrwx------ 1 root root 64 2009-11-25 14:43 5 -> socket:[5326303]
> 
> 
> I would like to try to attach a program of mine (a python interactive) to
> "socket:[5326303]" and try to read data from there to see if something comes
> out of the TCP stack, but I don't know where to find the socket:[5326303] on
> the filesystem. Is it mapped to a file anywhere in Linux?

This line still tells that there is nothing to read from the socket:

> > And this is from cat /proc/net/tcp   2: 0F12A8C0:0016 2512A8C0:0FBD 01    
> > 00000000:00000000 02:00009144 00000000     0        0 5326251 2

Let me reiterate, the first zeros here are the write side queue, the 
latter are for the receive (not including ofo queue but if tcpdump doesn't 
show ofo that's not significant detail here).

> > ffff88085408ce00 26 4 1 9 4

To me it seems that this particular problem so far shows very little 
problem on TCP side. Ie., TCP just "stalls" because it is not fed with 
anything.

What I would want to make absolutely sure, is that sftp-server was waiting 
for a pipe which comes from sshd, I don't think we have confirmed that 
just yet.

Also, I'd want to get a tcpdump, strace (the latter attach might be ok 
but I'm not sure just yet) and /proc/net/tcp from a consistent case rather 
than trying to mix multiple captures from different stalls. This is very 
important since your captures are already in disagreement on what is 
happening.

In addition, I want to see TCP timestamps (probably you need more -vvv to 
tcpdump to show them), however, if there are no timestamps in use at all
and 1gpbs speeds, it could potentially explain the missing data already.


-- 
 i.
---696230645-1820343251-1259185497=:5299--
