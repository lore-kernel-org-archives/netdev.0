From: Stefan Seyfried <stefan.seyfried@googlemail.com>
Subject: Re: [REGRESSION] in 3.18-rc1: ppp crashes kernel
Date: Fri, 07 Nov 2014 16:08:42 +0100
Message-ID: <545CE07A.6020601@message-id.googlemail.com>
References: <545CA8B6.2060608@message-id.googlemail.com> <s5hioirqh6m.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <s5hioirqh6m.wl-tiwai@suse.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Takashi,

yes, this no longer crashes. No real-world test yet, but the obvious
crash is gone. Thanks!

Am 07.11.2014 um 14:22 schrieb Takashi Iwai:
> At Fri, 07 Nov 2014 12:10:46 +0100,
> Stefan Seyfried wrote:
>>
>> Hi all,
>>
>> since 3.18-rc1, setting up a PPP interface kills my kernel with
>>
>> [  163.433251] PPP generic driver version 2.4.2
>> [  164.452474] ------------[ cut here ]------------
>> [  164.453327] kernel BUG at ../mm/vmalloc.c:1316!
>> [  164.453327] invalid opcode: 0000 [#1] PREEMPT SMP=20
>> [  164.453327] Modules linked in: ppp_async crc_ccitt ppp_generic sl=
hc af_packet xfs libcrc32c coretemp kvm_intel=20
>> snd_hda_codec_conexant iTCO_wdt snd_hda_codec_generic iTCO_vendor_su=
pport uvcvideo snd_hda_intel snd_hda_controller mac80211 videobuf2_vmal=
loc snd_hda_codec kvm e1000e videobuf2_memops cfg80211 videobuf2_core v=
4l2_common snd_hwdep i2c_i801 videodev snd_pcm pcspkr thinkpad_acpi ser=
io_raw wmi lpc_ich snd_timer thermal snd rfkill mfd_core tpm_tis shpchp=
 mei_me soundcore ptp mei pps_core acpi_cpufreq tpm battery processor a=
c dm_mod btrfs xor raid6_pq i915 i2c_algo_bit drm_kms_helper drm video =
button sg
>> [  164.453327] CPU: 0 PID: 6927 Comm: pppd Not tainted 3.18.0-rc3-3.=
ge706e91-desktop #1
>> [  164.453327] Hardware name: LENOVO 7470E36/7470E36, BIOS 6DET61WW =
(3.11 ) 11/10/2009
>>
>> This is easy to reproduce with:
>>
>> linux:~ # cat bin/crashme.sh=20
>> ----
>> #!/bin/bash -x
>> pppd local pty "netcat -l 1234" &
>> sleep 1
>> pppd local pty "netcat localhost 1234" &
>> sleep 1
>> ----
>>
>> 3.17 works fine.
>> I bisected the issue multiple times and always arrived at
>>
>> # first bad commit: [d6dd50e07c5bec00db2005969b1a01f8ca3d25ef] Merge=
 branch 'core-rcu-for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tip/tip
>>
>> which is a merge commit unfortunately.
>>
>> The BUG encountered above is in:
>>
>> 1309 static struct vm_struct *__get_vm_area_node(unsigned long size,
>> 1310                 unsigned long align, unsigned long flags, unsig=
ned long start,
>> 1311                 unsigned long end, int node, gfp_t gfp_mask, co=
nst void *caller)
>> 1312 {
>> 1313         struct vmap_area *va;
>> 1314         struct vm_struct *area;
>> 1315=20
>> 1316         BUG_ON(in_interrupt());
>> 1317         if (flags & VM_IOREMAP)
>> 1318                 align =3D 1ul << clamp(fls(size), PAGE_SHIFT, I=
OREMAP_MAX_ORDER);
>> 1319=20
>>
>> the call trace is:
>> [  164.453327] Call Trace:
>> [  164.453327]  [<ffffffff811974bd>] __vmalloc_node_range+0x6d/0x290
>> [  164.453327]  [<ffffffff8119771e>] __vmalloc+0x3e/0x50
>> [  164.453327]  [<ffffffff81146950>] bpf_prog_alloc+0x30/0xa0
>> [  164.453327]  [<ffffffff8157b716>] bpf_prog_create+0x46/0xb0
>> [  164.453327]  [<ffffffffa07ecb90>] ppp_ioctl+0x420/0xe9a [ppp_gene=
ric]
>> [  164.453327]  [<ffffffff811df1c7>] do_vfs_ioctl+0x2e7/0x4c0
>> [  164.453327]  [<ffffffff811df421>] SyS_ioctl+0x81/0xa0
>> [  164.453327]  [<ffffffff8165ee2d>] system_call_fastpath+0x16/0x1b
>> [  164.453327]  [<00007f4502d87397>] 0x7f4502d87397
>=20
> bpf_prog_create() is called inside spin_lock_bh(), and the BUG_ON()
> hits.  Below is a quick fix.
>=20
>=20
> Takashi
>=20
> -- 8< --
> From: Takashi Iwai <tiwai@suse.de>
> Subject: [PATCH] net: ppp: Don't call bpf_prog_create() in ppp_lock
>=20
> In ppp_ioctl(), bpf_prog_create() is called inside ppp_lock, which
> eventually calls vmalloc() and hits BUG_ON() in vmalloc.c.  This patc=
h
> works around the problem by moving the allocation outside the lock.
>=20
> Reported-by: Stefan Seyfried <stefan.seyfried@googlemail.com>
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

=46WIW :-)
Tested-by: Stefan Seyfried <stefan.seyfried@googlemail.com>

> ---
>  drivers/net/ppp/ppp_generic.c | 40 ++++++++++++++++++++-------------=
-------
>  1 file changed, 20 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_gene=
ric.c
> index 68c3a3f4e0ab..794a47329368 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -755,23 +755,23 @@ static long ppp_ioctl(struct file *file, unsign=
ed int cmd, unsigned long arg)
> =20
>  		err =3D get_filter(argp, &code);
>  		if (err >=3D 0) {
> +			struct bpf_prog *pass_filter =3D NULL;
>  			struct sock_fprog_kern fprog =3D {
>  				.len =3D err,
>  				.filter =3D code,
>  			};
> =20
> -			ppp_lock(ppp);
> -			if (ppp->pass_filter) {
> -				bpf_prog_destroy(ppp->pass_filter);
> -				ppp->pass_filter =3D NULL;
> +			err =3D 0;
> +			if (fprog.filter)
> +				err =3D bpf_prog_create(&pass_filter, &fprog);
> +			if (!err) {
> +				ppp_lock(ppp);
> +				if (ppp->pass_filter)
> +					bpf_prog_destroy(ppp->pass_filter);
> +				ppp->pass_filter =3D pass_filter;
> +				ppp_unlock(ppp);
>  			}
> -			if (fprog.filter !=3D NULL)
> -				err =3D bpf_prog_create(&ppp->pass_filter,
> -						      &fprog);
> -			else
> -				err =3D 0;
>  			kfree(code);
> -			ppp_unlock(ppp);
>  		}
>  		break;
>  	}
> @@ -781,23 +781,23 @@ static long ppp_ioctl(struct file *file, unsign=
ed int cmd, unsigned long arg)
> =20
>  		err =3D get_filter(argp, &code);
>  		if (err >=3D 0) {
> +			struct bpf_prog *active_filter =3D NULL;
>  			struct sock_fprog_kern fprog =3D {
>  				.len =3D err,
>  				.filter =3D code,
>  			};
> =20
> -			ppp_lock(ppp);
> -			if (ppp->active_filter) {
> -				bpf_prog_destroy(ppp->active_filter);
> -				ppp->active_filter =3D NULL;
> +			err =3D 0;
> +			if (fprog.filter)
> +				err =3D bpf_prog_create(&active_filter, &fprog);
> +			if (!err) {
> +				ppp_lock(ppp);
> +				if (ppp->active_filter)
> +					bpf_prog_destroy(ppp->active_filter);
> +				ppp->active_filter =3D active_filter;
> +				ppp_unlock(ppp);
>  			}
> -			if (fprog.filter !=3D NULL)
> -				err =3D bpf_prog_create(&ppp->active_filter,
> -						      &fprog);
> -			else
> -				err =3D 0;
>  			kfree(code);
> -			ppp_unlock(ppp);
>  		}
>  		break;
>  	}
>=20
--=20
Stefan Seyfried
Linux Consultant & Developer -- GPG Key: 0x731B665B

B1 Systems GmbH
Osterfeldstra=C3=9Fe 7 / 85088 Vohburg / http://www.b1-systems.de
GF: Ralph Dehner / Unternehmenssitz: Vohburg / AG: Ingolstadt,HRB 3537
