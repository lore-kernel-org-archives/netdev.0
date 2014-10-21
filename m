From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCHv4 3/4] sparc64: Avoid irqsave/restore on vio.lock if in_softirq()
Date: Wed, 22 Oct 2014 09:35:39 +1100
Message-ID: <CAGRGNgXvKJBhOE1z3=_gZkE=X94HnoAvTN6Zv5G1h8JuFfS8Ng@mail.gmail.com>
References: <20141021141647.GF15405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20141021141647.GF15405@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sowmini,

On Wed, Oct 22, 2014 at 1:16 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> For NAPIfied drivers , there is no need to
> synchronize by doing irqsave/restore on vio.lock in the I/O
> path.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  arch/sparc/kernel/viohs.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/arch/sparc/kernel/viohs.c b/arch/sparc/kernel/viohs.c
> index 7ef081a..d731586 100644
> --- a/arch/sparc/kernel/viohs.c
> +++ b/arch/sparc/kernel/viohs.c
> @@ -747,10 +747,11 @@ EXPORT_SYMBOL(vio_ldc_free);
>
>  void vio_port_up(struct vio_driver_state *vio)
>  {
> -       unsigned long flags;
> +       unsigned long flags = 0;

Is gcc not smart enough to know that this variable isn't used before
it's set? (I assume it isn't used elsewhere in this function)

>         int err, state;
>
> -       spin_lock_irqsave(&vio->lock, flags);
> +       if (!in_softirq())
> +               spin_lock_irqsave(&vio->lock, flags);
>
>         state = ldc_state(vio->lp);
>
> @@ -777,7 +778,8 @@ void vio_port_up(struct vio_driver_state *vio)
>                 mod_timer(&vio->timer, expires);
>         }
>
> -       spin_unlock_irqrestore(&vio->lock, flags);
> +       if (!in_softirq())
> +               spin_unlock_irqrestore(&vio->lock, flags);
>  }
>  EXPORT_SYMBOL(vio_port_up);

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
