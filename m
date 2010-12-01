From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v16 11/17]Add a hook to intercept external buffers from
 NIC driver.
Date: Wed, 1 Dec 2010 17:38:59 +0800
Message-ID: <AANLkTikiU_diGXRx6yxBx-1k-5JFXsty1MuqZyzXVu2Z@mail.gmail.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
 <c1b20adfd68fc241611845c0ef42fe8fa91ed981.1291187695.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com, Eric Dumazet <eric.dumazet@gmail.com>
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c1b20adfd68fc241611845c0ef42fe8fa91ed981.1291187695.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 1, 2010 at 4:08 PM,  <xiaohui.xin@intel.com> wrote:
> From: Xin Xiaohui <xiaohui.xin@intel.com>
> @@ -2891,6 +2925,11 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
> =A0ncls:
> =A0#endif
>
> + =A0 =A0 =A0 /* To intercept mediate passthru(zero-copy) packets her=
e */
> + =A0 =A0 =A0 skb =3D handle_mpassthru(skb, &pt_prev, &ret, orig_dev)=
;
> + =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> =A0 =A0 =A0 =A0/* Handle special case of bridge or macvlan */

I think it won't work if the skbs is captured by the previous ptype.
We need to trace the skb pages(skb_shared_info.frags[*].page), but
currently, there isn't a easy way to do that. skb pages are treated as
normal pages, and anyone can get it freely. And it is the problem in
the way to fix the potential data corruption bug.

Eric thinks af_packets(mmap) isn't worth fixing. But if this patch
serial has the same problem. It will be worth.

My idea is adding a new function dtor pointer  and some other args
pointers to the struct skb_shared_info. If skb_shared_info.dtor
exists, the pages in skb_shared_info.frags are private to this
skb->head. Anyone who wants to get these pages, should copy them
instead.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
