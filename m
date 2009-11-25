From: Asdo <asdo@shiftmail.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Wed, 25 Nov 2009 17:38:30 +0100
Message-ID: <4B0D5D86.8010509@shiftmail.org>
References: <4B0CB1B8.8030402@shiftmail.org>
	<alpine.DEB.2.00.0911251344520.7024@wel-95.cs.helsinki.fi>
	<4B0D2C0E.9050101@shiftmail.org> <4B0D4EFC.4050302@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <4B0D4EFC.4050302@shiftmail.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Asdo wrote:
> Asdo wrote:
>> Ilpo J=E4rvinen wrote:
>>  =

>>> ...I'd next try strace the sftp server to see what it was doing =

>>> during the stall.
>>>       =

>> Thanks for your help Ilpo
>>
>> Isn't the strace equivalent to the stack trace I obtained via cat =

>> /proc/pid/stack reported previously? That was at the time of the stall
>>
>> I'm thinking the strace would slow down sftp-server very deeply...
>>   =

>
> I found out that if I attach the strace I can see at least the last =

> function call.
> The SFTP it's hanged right now so I did that:
>
> root@mystorage:/root# strace -p 11475
> Process 11475 attached - interrupt to quit
> select(5, [3], [], NULL, NULL
>
> (stuck here forever... doesn't move)
> (it's strange the first option of select is 5, shouldn't it be 4 from =

> man select? A bug of strace maybe?)
>
> root@mystorage:/root# cat /proc/11475/stack
> [<ffffffff8112e644>] poll_schedule_timeout+0x34/0x50
> [<ffffffff8112ef4f>] do_select+0x58f/0x6b0
> [<ffffffff8112f8b5>] core_sys_select+0x185/0x2b0
> [<ffffffff8112fc32>] sys_select+0x42/0x110
> [<ffffffff8101225b>] tracesys+0xd9/0xde
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> And this is from cat /proc/net/tcp   2: 0F12A8C0:0016 2512A8C0:0FBD 01 =

> 00000000:00000000 02:00009144 00000000     0        0 5326251 2 =

> ffff88085408ce00 26 4 1 9 4
>
> The select refers to open files so here they are:
>
>
> root@mystorage:/proc/11475/fd# ll
> total 0
> lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 0 -> pipe:[5326309]
> l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 1 -> pipe:[5326310]
> l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 2 -> pipe:[5326311]
> lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 3 -> pipe:[5326309]
> l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 4 -> pipe:[5326310]
> l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 5 -> =

> /path/to/file_being_saved.filepart
>
> I tried to send SIGSTOP and then SIGCONT to see if I could make it =

> make a loop and then reenter into the select. I'm not sure it really =

> did that, what do you think? This is the strace:
> root@mystorage:/root# strace -p 11475 2>&1 | tee sftpstrace.dmp
> Process 11475 attached - interrupt to quit
> select(5, [3], [], NULL, NULL)          =3D ? ERESTARTNOHAND (To be =

> restarted)
> --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> --- SIGSTOP (Stopped (signal)) @ 0 (0) ---
> select(5, [3], [], NULL, NULL)          =3D ? ERESTARTNOHAND (To be =

> restarted)
> --- SIGCONT (Continued) @ 0 (0) ---
> select(5, [3], [], NULL, NULL
>
> (hanged again here)
>
>
> Do you think this info is enough or I really have to strace it since =

> the beginning?
> If it is a race condition it might not happen if the sftp-server is =

> deeply slowed down by the strace.
> If I had a way to make it continue right now we could get the rest of =

> the strace... But it's not so easy, I tried starting a Samba transfer =

> but it did not unlock the SFTP this time. SIGSTOP + SIGCONT also =

> didn't work.
>
> BTW people using the Storage also experienced data loss while pushing =

> files in it: appartently data disappeared from the middle of a file =

> they were saving to the Storage.
> To me looks like another hint that application-level data which has =

> been received via network by TCP stack is trapped there and not being =

> pushed to the application.
> Or the data might even be trapped into the anonymous sockets between =

> sshd and sftp-server.
>
> Thanks for your help

I thought that it would be more meaningful to try the cat stack, the =

strace and the SIGSTOP SIGCONT tricks on the sshd which actually holds =

the TCP socket, instead of the sftp-server. Here they are, on the sshd:

root@mystorage:/root# strace -p 11449 2>&1 | tee -a sshd1strace1.dmp
Process 11449 attached - interrupt to quit
read(5, 0x7fff4e956220, 4)              =3D ? ERESTARTSYS (To be restarted)
--- SIGSTOP (Stopped (signal)) @ 0 (0) ---
--- SIGSTOP (Stopped (signal)) @ 0 (0) ---
read(5, 0x7fff4e956220, 4)              =3D ? ERESTARTSYS (To be restarted)
--- SIGCONT (Continued) @ 0 (0) ---
read(5,

(hanged again here after the SIGSTOP + SIGCONT, unfortunately)

root@mystorage:/root# cat /proc/11449/stack
[<ffffffff814b428a>] unix_stream_data_wait+0xaa/0x110
[<ffffffff814b50cd>] unix_stream_recvmsg+0x36d/0x570
[<ffffffff81426399>] sock_aio_read+0x149/0x150
[<ffffffff8111e232>] do_sync_read+0xf2/0x130
[<ffffffff8111e8e1>] vfs_read+0x181/0x1a0
[<ffffffff8111edec>] sys_read+0x4c/0x80
[<ffffffff8101225b>] tracesys+0xd9/0xde
[<ffffffffffffffff>] 0xffffffffffffffff

root@mystorage:/proc/11449/fd# ll
total 0
lrwx------ 1 root root 64 2009-11-25 14:43 0 -> /dev/null
lrwx------ 1 root root 64 2009-11-25 14:43 1 -> /dev/null
lrwx------ 1 root root 64 2009-11-25 14:43 2 -> /dev/null
lrwx------ 1 root root 64 2009-11-25 14:43 3 -> socket:[5326251]
lrwx------ 1 root root 64 2009-11-25 14:43 5 -> socket:[5326303]


I would like to try to attach a program of mine (a python interactive) =

to "socket:[5326303]" and try to read data from there to see if =

something comes out of the TCP stack, but I don't know where to find the =

socket:[5326303] on the filesystem. Is it mapped to a file anywhere in =

Linux?

Thank you



---------------------------------------------------------------------------=
---
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day =

trial. Simplify your report design, integration and deployment - and focus =
on =

what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
