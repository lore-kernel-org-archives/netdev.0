From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Thu, 16 Jun 2016 14:43:46 -0700
Message-ID: <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2016 at 1:50 PM, Alexey Khoroshilov
<khoroshilov@ispras.ru> wrote:
> tcf_ife_init() contains a big chunk of code executed with
> ife->tcf_lock spinlock held. But that code contains several calls
> to sleeping functions:
>   populate_metalist() and use_all_metadata()
>     -> add_metainfo()
>       -> find_ife_oplist(metaid)
>         -> read_lock()
>         -> try_module_get(o->owner)
>       -> kzalloc(sizeof(*mi), GFP_KERNEL);

Hmm, we don't need to hold that spinlock when we create a new ife action,
since we haven't inserted it yet. We do need it when we modify an existing
one. So I am thinking if we can refactor that code to avoid spinlock
whenever possible.

>       -> ops->alloc(mi, metaval);
>       -> module_put(ops->owner);
>   _tcf_ife_cleanup()
>     -> module_put()
>
> The same problem is actual for tcf_ife_cleanup() as well.
>

Huh? Both module_put() and kfree() should not sleep, right?
