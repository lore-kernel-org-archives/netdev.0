From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Wrong locking code in udp seq_file infrastructure
Date: Mon, 23 Mar 2009 15:17:01 +0100
Message-ID: <49C799DD.8070504@cosmosbay.com>
References: <8763i0fnrm.wl%vmayatsk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54304 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757673AbZCWORO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 10:17:14 -0400
In-Reply-To: <8763i0fnrm.wl%vmayatsk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Mayatskikh a =E9crit :
> Reading zero bytes from /proc/net/udp or other similar files which us=
e
> the same seq_file udp infrastructure panics kernel in that way:
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ BUG: bad unlock balance detected! ]
> -------------------------------------
> read/1985 is trying to release lock (&table->hash[i].lock) at:
> [<ffffffff81321d83>] udp_seq_stop+0x27/0x29
> but there are no more locks to release!
>=20
> other info that might help us debug this:
> 1 lock held by read/1985:
>  #0:  (&p->lock){--..}, at: [<ffffffff810eefb6>] seq_read+0x38/0x348
>=20
> stack backtrace:
> Pid: 1985, comm: read Not tainted 2.6.29-rc8 #9
> Call Trace:
>  [<ffffffff81321d83>] ? udp_seq_stop+0x27/0x29
>  [<ffffffff8106dab9>] print_unlock_inbalance_bug+0xd6/0xe1
>  [<ffffffff8106db62>] lock_release_non_nested+0x9e/0x1c6
>  [<ffffffff810ef030>] ? seq_read+0xb2/0x348
>  [<ffffffff8106bdba>] ? mark_held_locks+0x68/0x86
>  [<ffffffff81321d83>] ? udp_seq_stop+0x27/0x29
>  [<ffffffff8106dde7>] lock_release+0x15d/0x189
>  [<ffffffff8137163c>] _spin_unlock_bh+0x1e/0x34
>  [<ffffffff81321d83>] udp_seq_stop+0x27/0x29
>  [<ffffffff810ef239>] seq_read+0x2bb/0x348
>  [<ffffffff810eef7e>] ? seq_read+0x0/0x348
>  [<ffffffff8111aedd>] proc_reg_read+0x90/0xaf
>  [<ffffffff810d878f>] vfs_read+0xa6/0x103
>  [<ffffffff8106bfac>] ? trace_hardirqs_on_caller+0x12f/0x153
>  [<ffffffff810d88a2>] sys_read+0x45/0x69
>  [<ffffffff8101123a>] system_call_fastpath+0x16/0x1b
> BUG: scheduling while atomic: read/1985/0xffffff00
> INFO: lockdep is turned off.
> Modules linked in: cpufreq_ondemand acpi_cpufreq freq_table dm_multip=
ath kvm ppdev snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwde=
p snd_seq_dummy snd_seq_oss snd_seq_midi_event arc4 snd_s
> eq ecb thinkpad_acpi snd_seq_device iwl3945 hwmon sdhci_pci snd_pcm_o=
ss sdhci rfkill mmc_core snd_mixer_oss i2c_i801 mac80211 yenta_socket r=
icoh_mmc i2c_core iTCO_wdt snd_pcm iTCO_vendor_support rs
> rc_nonstatic snd_timer snd lib80211 cfg80211 soundcore snd_page_alloc=
 video parport_pc output parport e1000e [last unloaded: scsi_wait_scan]
> Pid: 1985, comm: read Not tainted 2.6.29-rc8 #9
> Call Trace:
>  [<ffffffff8106b456>] ? __debug_show_held_locks+0x1b/0x24
>  [<ffffffff81043660>] __schedule_bug+0x7e/0x83
>  [<ffffffff8136ede9>] schedule+0xce/0x838
>  [<ffffffff810d7972>] ? fsnotify_access+0x5f/0x67
>  [<ffffffff810112d0>] ? sysret_careful+0xb/0x37
>  [<ffffffff8106be9c>] ? trace_hardirqs_on_caller+0x1f/0x153
>  [<ffffffff8137127b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff810112f6>] sysret_careful+0x31/0x37
> read[1985]: segfault at 7fffc479bfe8 ip 0000003e7420a180 sp 00007fffc=
479bfa0 error 6
> Kernel panic - not syncing: Aiee, killing interrupt handler!
>=20
> udp_seq_stop() tries to unlock not yet locked spinlock. The lock was =
lost
> during splitting global udp_hash_lock to subsequent spinlocks.
>=20
> Signed-off by: Vitaly Mayatskikh <v.mayatskih@gmail.com>
>=20
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c47c989..c8bee18 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1614,7 +1614,8 @@ static struct sock *udp_get_next(struct seq_fil=
e *seq, struct sock *sk)
>  	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family !=3D st=
ate->family));
> =20
>  	if (!sk) {
> -		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
> +		if (state->bucket < UDP_HTABLE_SIZE)
> +			spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
>  		return udp_get_first(seq, state->bucket + 1);
>  	}
>  	return sk;
> @@ -1632,6 +1633,9 @@ static struct sock *udp_get_idx(struct seq_file=
 *seq, loff_t pos)
> =20
>  static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
>  {
> +	struct udp_iter_state *state =3D seq->private;
> +	state->bucket =3D UDP_HTABLE_SIZE;
> +
>  	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
>  }
> =20
>=20

Oops...

Nice catch Vitaly

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

