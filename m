From: Asdo <asdo@shiftmail.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Wed, 25 Nov 2009 16:36:28 +0100
Message-ID: <4B0D4EFC.4050302@shiftmail.org>
References: <4B0CB1B8.8030402@shiftmail.org>
	<alpine.DEB.2.00.0911251344520.7024@wel-95.cs.helsinki.fi>
	<4B0D2C0E.9050101@shiftmail.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1254984700650555158=="
Cc: e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <4B0D2C0E.9050101@shiftmail.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1254984700650555158==
Content-type: multipart/alternative;
	boundary="Boundary_(ID_BmPK/FSHT6LBKaVEI2F6JA)"

This is a multi-part message in MIME format.

--Boundary_(ID_BmPK/FSHT6LBKaVEI2F6JA)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: QUOTED-PRINTABLE

Asdo wrote:
> Ilpo J=E4rvinen wrote:
>  =20
>> ...I'd next try strace the sftp server to see what it was doing=
=20
>> during the stall.
>>  =20
>>    =20
> Thanks for your help Ilpo
>
> Isn't the strace equivalent to the stack trace I obtained via cat=
=20
> /proc/pid/stack reported previously? That was at the time of the st=
all
>
> I'm thinking the strace would slow down sftp-server very deeply...
>  =20

I found out that if I attach the strace I can see at least the last=
=20
function call.
The SFTP it's hanged right now so I did that:

root@mystorage:/root# strace -p 11475
Process 11475 attached - interrupt to quit
select(5, [3], [], NULL, NULL

(stuck here forever... doesn't move)
(it's strange the first option of select is 5, shouldn't it be 4 from=
=20
man select? A bug of strace maybe?)

root@mystorage:/root# cat /proc/11475/stack
[<ffffffff8112e644>] poll_schedule_timeout+0x34/0x50
[<ffffffff8112ef4f>] do_select+0x58f/0x6b0
[<ffffffff8112f8b5>] core_sys_select+0x185/0x2b0
[<ffffffff8112fc32>] sys_select+0x42/0x110
[<ffffffff8101225b>] tracesys+0xd9/0xde
[<ffffffffffffffff>] 0xffffffffffffffff

And this is from cat /proc/net/tcp=20
   2: 0F12A8C0:0016 2512A8C0:0FBD 01 00000000:00000000 02:00009144=
=20
00000000     0        0 5326251 2 ffff88085408ce00 26 4 1 9 4

The select refers to open files so here they are:


root@mystorage:/proc/11475/fd# ll
total 0
lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 0 -> pipe:[5326309=
]
l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 1 -> pipe:[5326310=
]
l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 2 -> pipe:[5326311=
]
lr-x------ 1 ccosentino wetlab 64 2009-11-25 14:43 3 -> pipe:[5326309=
]
l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 4 -> pipe:[5326310=
]
l-wx------ 1 ccosentino wetlab 64 2009-11-25 14:43 5 ->=20
/path/to/file_being_saved.filepart

I tried to send SIGSTOP and then SIGCONT to see if I could make it ma=
ke=20
a loop and then reenter into the select. I'm not sure it really did=
=20
that, what do you think? This is the strace:
root@mystorage:/root# strace -p 11475 2>&1 | tee sftpstrace.dmp
Process 11475 attached - interrupt to quit
select(5, [3], [], NULL, NULL)          =3D ? ERESTARTNOHAND (To be r=
estarted)
--- SIGSTOP (Stopped (signal)) @ 0 (0) ---
--- SIGSTOP (Stopped (signal)) @ 0 (0) ---
select(5, [3], [], NULL, NULL)          =3D ? ERESTARTNOHAND (To be r=
estarted)
--- SIGCONT (Continued) @ 0 (0) ---
select(5, [3], [], NULL, NULL

(hanged again here)


Do you think this info is enough or I really have to strace it since =
the=20
beginning?
If it is a race condition it might not happen if the sftp-server is=
=20
deeply slowed down by the strace.
If I had a way to make it continue right now we could get the rest of=
=20
the strace... But it's not so easy, I tried starting a Samba transfer=
=20
but it did not unlock the SFTP this time. SIGSTOP + SIGCONT also didn=
't=20
work.

BTW people using the Storage also experienced data loss while pushing=
=20
files in it: appartently data disappeared from the middle of a file t=
hey=20
were saving to the Storage.
To me looks like another hint that application-level data which has b=
een=20
received via network by TCP stack is trapped there and not being push=
ed=20
to the application.
Or the data might even be trapped into the anonymous sockets between=
=20
sshd and sftp-server.

Thanks for your help




--Boundary_(ID_BmPK/FSHT6LBKaVEI2F6JA)--


--===============1254984700650555158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
--===============1254984700650555158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============1254984700650555158==--
