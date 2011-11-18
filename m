From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: lock-warning seen on giving rds-info command
Date: Fri, 18 Nov 2011 14:24:54 +0530
Message-ID: <20111118085453.GA17346@kumars-PC.asicdesigners.com>
References: <1321603654-17179-1-git-send-email-kumaras@chelsio.com>
 <1321604802.2444.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	venkat.x.venkatsubra@oracle.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10913 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607Ab1KRIjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 03:39:18 -0500
Content-Disposition: inline
In-Reply-To: <1321604802.2444.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Nov 18, 2011 at 09:26:42 +0100, Eric Dumazet wrote:
> Le vendredi 18 novembre 2011 =E0 13:37 +0530, Kumar Sanghvi a =E9crit=
 :
> > Hi netdev team,
> >=20
> > I am trying to investigate one issue with RDS.
> > On giving command rds-info, we get below trace in dmesg:
> >=20
> > ------------[ cut here ]------------
> > WARNING: at /root/chelsio/git_repos/linux-2.6/kernel/softirq.c:159 =
local_bh_enable_ip+0x7a/0xa0()
> > Hardware name: X7DB8
> > Modules linked in: rds_rdma rds rdma_cm iw_cm ib_addr autofs4 sunrp=
c
> > p4_clockmod freq_table speedstep_lib ib_ipoib ib_cm ib_sa ipv6 ib_u=
verbs
> > ib_umad ib_mad iw_nes libcrc32c ib_core dm_mirror dm_region_hash dm=
_log
> > uinput ppdev sg parport_pc parport pcspkr serio_raw i2c_i801 iTCO_w=
dt
> > iTCO_vendor_support ioatdma dca i5k_amb i5000_edac edac_core e1000e=
 shpchp
> > ext4 mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif pata_acpi ata_gene=
ric ata_piix
> > floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core dm=
_mod
> > [last unloaded: mdio]
> > Pid: 1937, comm: rds-info Not tainted 3.1.0 #1
> > Call Trace:
> >  [<ffffffff8106446f>] warn_slowpath_common+0x7f/0xc0
> >  [<ffffffff810644ca>] warn_slowpath_null+0x1a/0x20
> >  [<ffffffff8106af6a>] local_bh_enable_ip+0x7a/0xa0
> >  [<ffffffff814d3126>] _raw_read_unlock_bh+0x16/0x20
> >  [<ffffffff813f83b4>] sock_i_ino+0x44/0x60
> >  [<ffffffffa046ab02>] rds_sock_info+0xd2/0x140 [rds]
> >  [<ffffffffa046c7a7>] rds_info_getsockopt+0x197/0x200 [rds]
> >  [<ffffffffa046a1b4>] rds_getsockopt+0x84/0xe0 [rds]
> >  [<ffffffff813f3453>] sys_getsockopt+0x73/0xe0
> >  [<ffffffff814dafd7>] tracesys+0xd9/0xde
> > ---[ end trace 4e7838d2e1e53231 ]---
> >=20
> > I tested this on 3.1 kernel. However, this problem seems to be pres=
ent on most
> > recent kernels. I tried to investigate, and the RDS problem seems t=
o stem(I might be wrong)
> > after this upstream commit:
> >=20
> > ----
> > commit f064af1e500a2bf4607706f0f458163bdb2a6ea5
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Wed Sep 22 12:43:39 2010 +0000
> >=20
> >     net: fix a lockdep splat
> > ----
> >=20
> > In the above commit, sock_i_ino is modified to use read_lock/unlock=
_bh instead
> > of plain read_lock/unlock.
> >=20
> > Now, everywhere in Linux network stack, it seems that callers of so=
ck_i_ino
> > are not disabling interrupts and are also not holding any lock whil=
e calling
> > sock_i_ino function. However, RDS seems to be only one who is calli=
ng sock_i_ino
> > with spin_lock_irqsave i.e. with interrupts disabled.
> > As a result, when sock_i_ino finally calls read_unlock_bh -  which =
in turn will lead to
> > local_bh_enable_ip - which in turn throws the WARN-ON-ONCE since in=
terrupts are
> > disabled at this stage.
> >=20
>=20
> You mean that following sequence triggers a warning ?

It seems to be. I am not completely sure however.

>=20
> spin_lock_irqsave(&rds_sock_lock, flags);
> ...
> read_lock_bh(&sk->sk_callback_lock);
> read_unlock_bh(&sk->sk_callback_lock);   // HERE
> ...
>=20
>=20
> I dont know why. How softirqs can trigger if we block hard irqs ?
>=20
> In any case your patch is not the right solution, please read=20
>=20
>  vi +112 net/rds/af_rds.c

Yes, I am aware of this. However, I thought I would better report this =
to
netdev with a possible, although incorrect, solution.
I am wondering how to correctly resolve this.

>=20
> /*
>  * Careful not to race with rds_release -> sock_orphan which clears s=
k_sleep.
>  * _bh() isn't OK here, we're called from interrupt handlers.  It's p=
robably OK
>  * to wake the waitqueue after sk_sleep is clear as we hold a sock re=
f, but
>  * this seems more conservative.
>  * NB - normally, one would use sk_callback_lock for this, but we can
>  * get here from interrupts, whereas the network code grabs sk_callba=
ck_lock
>  * with _lock_bh only - so relying on sk_callback_lock introduces liv=
elocks.
>  */
> void rds_wake_sk_sleep(struct rds_sock *rs)
> {
>         unsigned long flags;
>=20
>         read_lock_irqsave(&rs->rs_recv_lock, flags);
>         __rds_wake_sk_sleep(rds_rs_to_sk(rs));
>         read_unlock_irqrestore(&rs->rs_recv_lock, flags);
> }
>=20
>=20
>=20
