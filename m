From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [3/3] POHMELFS high performance network filesystem.
Date: Sun, 15 Jun 2008 09:47:03 +0200
Message-ID: <19f34abd0806150047w4338502en9a75681fb0c95438@mail.gmail.com>
References: <20080613163700.GA25860@2ka.mipt.ru>
	 <20080613164241.GC26166@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080613164241.GC26166@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have just one question yet :-)

On Fri, Jun 13, 2008 at 6:42 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> +int pohmelfs_copy_config(struct pohmelfs_sb *psb)
> +{
> +       struct pohmelfs_config *c, *dst;
> +       int err = -ENODEV;
> +
> +       mutex_lock(&pohmelfs_config_lock);
> +       list_for_each_entry(c, &pohmelfs_config_list, config_entry) {
> +               if (c->state.ctl.idx != psb->idx)
> +                       continue;
> +
> +               err = 0;
> +               list_for_each_entry(dst, &psb->state_list, config_entry) {
> +                       if (pohmelfs_config_eql(&dst->state.ctl, &c->state.ctl)) {
> +                               err = -EEXIST;
> +                               break;
> +                       }
> +               }
> +
> +               if (err)
> +                       continue;
> +
> +               dst = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
> +               if (!dst) {
> +                       err = -ENOMEM;
> +                       goto err_out_unlock;
> +               }
> +
> +               memcpy(&dst->state.ctl, &c->state.ctl, sizeof(struct pohmelfs_ctl));
> +
> +               list_add_tail(&dst->config_entry, &psb->state_list);
> +
> +               err = pohmelfs_state_init_one(psb, dst);
> +               if (err) {
> +                       list_del(&dst->config_entry);
> +                       kfree(dst);
> +               }
> +       }
> +       mutex_unlock(&pohmelfs_config_lock);
> +
> +       return err;
> +
> +err_out_unlock:
> +       mutex_unlock(&pohmelfs_config_lock);
> +
> +       mutex_lock(&psb->state_lock);
> +       list_for_each_entry_safe(dst, c, &psb->state_list, config_entry) {
> +               list_del(&dst->config_entry);
> +               kfree(dst);
> +       }
> +       mutex_unlock(&psb->state_lock);
> +
> +       return err;
> +}

I'm having a hard time convincing myself that the error handling here
is correct. You have this kind of setup:

1. for each config in config list {
    2. for each config in superblock state list {
        pohmelfs_config_eql();
        ...
    }
}

And according to your code, if pohmelfs_config_eql returns non-zero in
the last iteration of #1, then -EEXISTS will be the return value of
the whole function (but the config _will_ be copied; it is not undone
in this case). But if pohmenlfs_config_eql returns non-zero in any but
the last iteration of #1, then 0 will be the return value. Is this
your intention?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
