From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [next] unix stream crashes
Date: Sat, 3 Sep 2011 07:54:47 +0200
Message-ID: <CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com>
References: <4E5FEF28.60406@gmail.com>
	<3179.1314924559@turing-police.cc.vt.edu>
	<1314927645.2576.2939.camel@schen9-DESK>
	<6805.1314979936@turing-police.cc.vt.edu>
	<1315007703.2576.2965.camel@schen9-DESK>
	<6043.1315028115@turing-police.cc.vt.edu>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:55699 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab1ICFys convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 01:54:48 -0400
In-Reply-To: <6043.1315028115@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 3, 2011 at 7:35 AM,  <Valdis.Kletnieks@vt.edu> wrote:
> On Fri, 02 Sep 2011 16:55:03 PDT, Tim Chen said:
>
>> I'll like to isolate the problem to either the send path or receive
>> path. My suspicion is the error handling portion of the send path is=
 not
>> quite right but I haven't yet found any issues after reviewing the
>> patch.
>
> Took a while, because it took a few tries to get netconsole working,
> and then I was seeing odd results, but here we go:
>
> next-20110831 - crashes 100% consistent.
> next-20110831 + revert 0856a30409 - OK.
> revert + scm_recv.patch - OK.
> revert + scm_send.patch - crashes 100% consistent.
>

YES, I can confirm this with next-20110826.

> Now the odd part - although I was seeing crashes 100% of the time, I =
saw a
> number of different tracebacks (but I never actually saw the same tra=
ceback
> that Jiri had). Also, the system died at different points - most of t=
he time it
> would live long enough for GDM to prompt for a userid/password and th=
en die,
> but sometimes it didn't get as far as the GDM screen. Hopefully the v=
ariety of
> crashes will tell you something useful.
>
> I'll be able to test patches for go/nogo over the weekend, but probab=
ly won't
> have a second machine to catch netconsole until I'm back in the offic=
e Monday.
>
> Example 1:
>
> [ =C2=A0142.316258] Kernel panic - not syncing: CRED: put_cred_rcu() =
sees ffff88010d1ff300 with usage -41
> [ =C2=A0142.316260]
> [ =C2=A0142.316275] Pid: 2264, comm: gdm-simple-slav Tainted: G =C2=A0=
 =C2=A0 =C2=A0 =C2=A0W =C2=A0 3.1.0-rc4-next-20110831-dirty #17
> [ =C2=A0142.316279] Call Trace:
> [ =C2=A0142.316283] =C2=A0<IRQ> =C2=A0[<ffffffff81577a6c>] panic+0x96=
/0x1a2
> [ =C2=A0142.316300] =C2=A0[<ffffffff8105cb54>] put_cred_rcu+0x32/0x91
> [ =C2=A0142.316306] =C2=A0[<ffffffff8157a44f>] rcu_do_batch+0xcb/0x1e=
4
> [ =C2=A0142.316313] =C2=A0[<ffffffff81092967>] invoke_rcu_callbacks+0=
x6c/0xc7
> [ =C2=A0142.316319] =C2=A0[<ffffffff810932f8>] __rcu_process_callback=
s+0x118/0x124
> [ =C2=A0142.316325] =C2=A0[<ffffffff810934f0>] rcu_process_callbacks+=
0x64/0x72
> [ =C2=A0142.316331] =C2=A0[<ffffffff8103f8c4>] __do_softirq+0x110/0x2=
78
> [ =C2=A0142.316338] =C2=A0[<ffffffff815a23ac>] call_softirq+0x1c/0x30
> [ =C2=A0142.316342] =C2=A0<EOI> =C2=A0[<ffffffff81003647>] do_softirq=
+0x44/0xf1
> [ =C2=A0142.316352] =C2=A0[<ffffffff8103f485>] _local_bh_enable_ip+0x=
12a/0x178
> [ =C2=A0142.316358] =C2=A0[<ffffffff8103f4dc>] local_bh_enable_ip+0x9=
/0xb
> [ =C2=A0142.316364] =C2=A0[<ffffffff8159a2f3>] _raw_write_unlock_bh+0=
x36/0x3a
> [ =C2=A0142.316372] =C2=A0[<ffffffff814c1ac3>] unix_release_sock+0x86=
/0x1ff
> [ =C2=A0142.316378] =C2=A0[<ffffffff8105b548>] ? up_read+0x1b/0x32
> [ =C2=A0142.316383] =C2=A0[<ffffffff814c1c5d>] unix_release+0x21/0x23
> [ =C2=A0142.316390] =C2=A0[<ffffffff81423d02>] sock_release+0x1a/0x6f
> [ =C2=A0142.316395] =C2=A0[<ffffffff81424a30>] sock_close+0x22/0x26
> [ =C2=A0142.316401] =C2=A0[<ffffffff810fcacb>] __fput+0x140/0x1fe
> [ =C2=A0142.316407] =C2=A0[<ffffffff810f97cb>] ? sys_close+0xe6/0x158
> [ =C2=A0142.316412] =C2=A0[<ffffffff810fcb9e>] fput+0x15/0x17
> [ =C2=A0142.316417] =C2=A0[<ffffffff810f8ef2>] filp_close+0x87/0x93
> [ =C2=A0142.316422] =C2=A0[<ffffffff810f97d6>] sys_close+0xf1/0x158
> [ =C2=A0142.316429] =C2=A0[<ffffffff815a0ffb>] system_call_fastpath+0=
x16/0x1b
>

I saw similiar call-traces with put_cred_rcu() - besides with
kmem_cache_alloc_trace().
My post-it says:
Kernel panic - not syncing: CRED: put_cred_rcu sees f67ac0c0 with usage=
 -43

BTW, systemd (uses dbus/sockets) is more sensitive than Debian's
standard sysvinit.

- Sedat -
