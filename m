From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: System freeze on reboot - general protection fault
Date: Thu, 03 Sep 2009 00:17:43 +0200
Message-ID: <4A9EEF07.5070800@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <c4e36d110908110832y21fba830ub8804613df571228@mail.gmail.com>	 <20090811154853.GF2763@sgi.com>	 <c4e36d110908111410y29b922ceod6871fda2514f6e6@mail.gmail.com>	 <c4e36d110908121516u504809e9y537e9babfa95df1d@mail.gmail.com>	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net> <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42276 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbZIBWSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 18:18:39 -0400
In-Reply-To: <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zdenek Kabelac a =E9crit :
> 2009/8/17 Patrick McHardy <kaber@trash.net>:
>> Eric Dumazet wrote:
>>> Zdenek Kabelac a =E9crit :
>>>>  [<ffffffffa02c502f>] nf_conntrack_ftp_fini+0x2f/0x70 [nf_conntrac=
k_ftp]
>>>>  [<ffffffff8027bcc5>] sys_delete_module+0x1a5/0x270
>>>>  [<ffffffff8020d329>] ? retint_swapgs+0xe/0x13
>>>>  [<ffffffff80271bf2>] ? trace_hardirqs_on_caller+0x162/0x1b0
>>>>  [<ffffffff80292121>] ? audit_syscall_entry+0x191/0x1c0
>>>>  [<ffffffff80526dae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>>>>  [<ffffffff8020c84b>] system_call_fastpath+0x16/0x1b
>>>> Code: c6 00 00 0f 82 66 ff ff ff 49 8b 9e d8 05 00 00 48 85 db 75 =
16
>>>> e9 8e 00 00 00 0f 1f 44 00 00 48 85 c0 0f 84 80 00 00 00 48 89 c3 =
<0f>
>>>> b6 4b 37 48 8b 03 48 8d 14 cd 00 00 00 00 0f 18 08 48 29 ca
>>>> RIP  [<ffffffffa02b2c2c>] nf_conntrack_helper_unregister+0x16c/0x3=
20
>>>> [nf_conntrack]
>>>>  RSP <ffff88013982fe68>
>>>> CR2: 0000000000000038
>>>> ---[ end trace bc3a0ede3d0084db ]---
>>>>
>>> I am currently traveling and wont be able to help you before next w=
eek.
>>>
>>> I added netdev, Patrick, and netfilter-devel in CC so that more eye=
s can take a look.
>> Thanks for the report, I'll have a look at this. Zdenek, please
>> send me the nf_conntrack.ko file used in the above oops. Thanks.
>>
>=20
> Ok
>=20
> I've found the solution for my problem.
>=20
> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel=
/30483
>=20
> I've made this small fix from this thread:
>=20
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_con=
ntrack_core
> index b5869b9..68488f8 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1108,6 +1108,7 @@ static void nf_conntrack_cleanup_init_net(void)
>  {
>         nf_conntrack_helper_fini();
>         nf_conntrack_proto_fini();
> +       rcu_barrier();
>         kmem_cache_destroy(nf_conntrack_cachep);
>  }
>=20
> @@ -1266,7 +1267,7 @@ static int nf_conntrack_init_init_net(void)
>=20
>         nf_conntrack_cachep =3D kmem_cache_create("nf_conntrack",
>                                                 sizeof(struct nf_conn=
),
> -                                               0, SLAB_DESTROY_BY_RC=
U, NULL);
> +                                               0, 0, NULL);
>         if (!nf_conntrack_cachep) {
>                 printk(KERN_ERR "Unable to create nf_conn slab cache\=
n");
>                 ret =3D -ENOMEM;
>=20
>=20
> As the thread nf_conntrack: Use rcu_barrier() and fix kmem_cache_crea=
te flags
> seems to be samewhat 'unfinished'  and already a bit old and I've no
> idea whether it actually fixes problem completely or just hides it in
> my case - I'm leaving it to some RCU gurus to fix this issue.
>=20
> All I could say is - this this extra rcu_barrier() and removal of
> SLAB_DESTROY removes my GPF on reboot.
>=20
> Zdenek

Ouch..

Dont think such a patch makes your kernel better, it'll crash too.

You cannot remove SLAB_DESTROY_BY_RCU like this, it's there for very go=
od reasons.

