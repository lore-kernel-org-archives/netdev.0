From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 10:51:47 +0300
Message-ID: <84144f020909030051u6cf6ae01he25c268f718ff3af@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>
	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
	 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
	 <4A9F7283.1090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752407AbZICHvs@vger.kernel.org>
In-Reply-To: <4A9F7283.1090306@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Thu, Sep 3, 2009 at 10:38 AM, Eric Dumazet<eric.dumazet@gmail.com> w=
rote:
>> The rcu_barrier() call was added by this commit:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommitdiff;h=3D7ed9f7e5db58c6e8c2b4b738a75d5dcd8e17aad5
>>
>> I guess we should CC Paul as well.
>
> Sure !
>
> rcu_barrier() is definitly better than synchronize_rcu() in
> kmem_cache_destroy()
>
> But its location was not really right (for SLUB at least)
>
> SLAB_DESTROY_BY_RCU means subsystem will call kfree(elems) without wa=
iting RCU
> grace period.
>
> By the time subsystem calls kmem_cache_destroy(), all previously allo=
cated
> elems must have already be kfreed() by this subsystem.
>
> We must however wait that all slabs, queued for freeing by rcu_free_s=
lab(),
> are indeed freed, since this freeing needs access to kmem_cache point=
er.
>
> As kmem_cache_close() might clean/purge the cache and call rcu_free_s=
lab(),
> we must call rcu_barrier() *after* kmem_cache_close(), and before kfr=
ee(kmem_cache *s)
>
> Alternatively we could delay this final kfree(s) (with call_rcu()) bu=
t would
> have to copy s->name in kmem_cache_create() instead of keeping a poin=
ter to
> =A0a string that might be in a module, and freed at rmmod time.
>
> Given that there is few uses in current tree that call kmem_cache_des=
troy()
> on a SLAB_DESTROY_BY_RCU cache, there is no need to try to optimize t=
his
> rcu_barrier() call, unless we want superfast reboot/halt sequences...

Oh, sure, the fix looks sane to me. It's just that I am a complete
coward when it comes to merging RCU related patches so I always try to
fish an Acked-by from Paul or Christoph ;).

                        Pekka
