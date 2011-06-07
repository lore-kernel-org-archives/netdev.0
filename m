From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Tue, 07 Jun 2011 15:37:54 +0200
Message-ID: <1307453874.3091.14.camel@edumazet-laptop>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>
	 <1307391746.2642.11.camel@edumazet-laptop>
	 <4DEE273F.7090402@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, CaT <cat@zip.com.au>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DEE273F.7090402@fnarfbargle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 07 juin 2011 =C3=A0 21:27 +0800, Brad Campbell a =C3=A9crit :
> On 07/06/11 04:22, Eric Dumazet wrote:
>=20
> > Could you please try latest linux-2.6 tree ?
> >
> > We fixed many networking bugs that could explain your crash.
> >
> >
> >
> >
>=20
> No good I'm afraid.
>=20
> [  543.040056]=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> [  543.040136] BUG ip_dst_cache: Padding overwritten.=20
> 0xffff8803e4217ffe-0xffff8803e4217fff
> [  543.040194]=20

Thats pretty strange : These are the last two bytes of a page, set to
0x0000 (a 16 bit value)

There is no way a dst field could actually sit on this location (its a
padding), since a dst is a bit less than 256 bytes (0xe8), and each
entry is aligned on a 64byte address.

grep dst /proc/slabinfo=20

ip_dst_cache       32823  62944    256   32    2 : tunables    0    0
0 : slabdata   1967   1967      0

sizeof(struct rtable)=3D0xe8


> ---------------------------------------------------------------------=
--------
> [  543.040198]
> [  543.040298] INFO: Slab 0xffffea000d9e74d0 objects=3D25 used=3D25 f=
p=3D0x=20
>         (null) flags=3D0x8000000000004081
> [  543.040364] Pid: 4576, comm: kworker/1:2 Not tainted 3.0.0-rc2 #1
> [  543.040415] Call Trace:
> [  543.040472]  [<ffffffff810b9c1d>] ? slab_err+0xad/0xd0
> [  543.040528]  [<ffffffff8102e034>] ? check_preempt_wakeup+0xa4/0x16=
0
> [  543.040595]  [<ffffffff810ba206>] ? slab_pad_check+0x126/0x170
> [  543.040650]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
> [  543.040701]  [<ffffffff810ba29a>] ? check_slab+0x4a/0xc0
> [  543.040753]  [<ffffffff810baf2d>] ? free_debug_processing+0x2d/0x2=
50
> [  543.040808]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
> [  543.040862]  [<ffffffff810bbe99>] ? kmem_cache_free+0x99/0xa0
> [  543.040915]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
> [  543.040967]  [<ffffffff813307f6>] ? dst_gc_task+0x196/0x1f0
> [  543.041021]  [<ffffffff8104e954>] ? queue_delayed_work_on+0x154/0x=
160
> [  543.041081]  [<ffffffff813066fe>] ? do_dbs_timer+0x20e/0x3d0
> [  543.041133]  [<ffffffff81330660>] ? dst_alloc+0x180/0x180
> [  543.041187]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
> [  543.041242]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
> [  543.041296]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
> [  543.041678]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
> [  543.041729]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
> [  543.041782]  [<ffffffff81053436>] ? kthread+0x96/0xa0
> [  543.041835]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
> [  543.041890]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
> [  543.041944]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
> [  543.041993]  Padding 0xffff8803e4217f40:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.042718]  Padding 0xffff8803e4217f50:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.043433]  Padding 0xffff8803e4217f60:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.044155]  Padding 0xffff8803e4217f70:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.044866]  Padding 0xffff8803e4217f80:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.045590]  Padding 0xffff8803e4217f90:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.046311]  Padding 0xffff8803e4217fa0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.047034]  Padding 0xffff8803e4217fb0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.047755]  Padding 0xffff8803e4217fc0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.048474]  Padding 0xffff8803e4217fd0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.049203]  Padding 0xffff8803e4217fe0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
> [  543.049909]  Padding 0xffff8803e4217ff0:  5a 5a 5a 5a 5a 5a 5a 5a =
5a=20
> 5a 5a 5a 5a 5a 00 00 ZZZZZZZZZZZZZZ..
> [  543.050021] FIX ip_dst_cache: Restoring=20
> 0xffff8803e4217f40-0xffff8803e4217fff=3D0x5a
> [  543.050021]
>=20
> Dropped -mm, Hugh and Andrea from CC as this does not appear to be mm=
 or=20
> ksm related.
>=20
> I'll pare down the firewall and see if I can make it break easier wit=
h a=20
> smaller test set.

Hmm, not sure now :(

Could you reproduce another bug please ?
