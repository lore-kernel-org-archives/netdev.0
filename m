From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Wed, 31 Dec 2014 14:17:40 +0100
Message-ID: <CA+icZUWy7oLWCeN1qJUwdxD-ZFQmJ5DSmVHNy4sgqKGDsOvT=w@mail.gmail.com>
References: <CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
	<CA+icZUU1-o7m9iYNpHyitpbS8W=+mk-ZbBXiK2Zgow2TDnBo1Q@mail.gmail.com>
	<CA+icZUUO5fkmdevyhutYU6=2vBACN0Nr3WA+DMssfhy5xfsrbQ@mail.gmail.com>
	<20141229.163311.498586171360350188.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes.berg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wu Fengguang <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:39011 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaLaNRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 08:17:42 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so25506278wiv.13
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 05:17:40 -0800 (PST)
In-Reply-To: <20141229.163311.498586171360350188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 10:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Sedat Dilek <sedat.dilek@gmail.com>
> Date: Sun, 28 Dec 2014 10:34:51 +0100
>
>> On Sun, Dec 28, 2014 at 8:54 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>> Just a small thing, if you look at this...
>>>
>>> With gcc-4.9.2 I see this warning in my logs...
>>>
>>> net/netlink/genetlink.c: In function 'genl_bind':
>>> net/netlink/genetlink.c:1018:2: warning: 'err' may be used
>>> uninitialized in this function [-Wmaybe-uninitialized]
>>>
>>
>> Attached patch fixes the issue for me.
>
> Ok since the user can request arbitrary multicast groups, we cannot
> warn in this situation.
>
> And since initializing 'err' to zero makes the whole 'found'
> variable completely unnecessary, we can delete that too.
>
> This is the final patch I am applying, thanks for all of your
> help.
>
> ====================
> [PATCH] genetlink: A genl_bind() to an out-of-range multicast group should not WARN().
>
> Users can request to bind to arbitrary multicast groups, so warning
> when the requested group number is out of range is not appropriate.
>
> And with the warning removed, and the 'err' variable properly given
> an initial value, we can remove 'found' altogether.
>
> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks Dave for pushing this!

Guten Rutsch (Happy new year),
- Sedat -

> ---
>  net/netlink/genetlink.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 91566ed..2e11061 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -985,8 +985,7 @@ static struct genl_multicast_group genl_ctrl_groups[] = {
>
>  static int genl_bind(struct net *net, int group)
>  {
> -       int i, err;
> -       bool found = false;
> +       int i, err = 0;
>
>         down_read(&cb_lock);
>         for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
> @@ -1003,16 +1002,12 @@ static int genl_bind(struct net *net, int group)
>                                         err = f->mcast_bind(net, fam_grp);
>                                 else
>                                         err = 0;
> -                               found = true;
>                                 break;
>                         }
>                 }
>         }
>         up_read(&cb_lock);
>
> -       if (WARN_ON(!found))
> -               err = 0;
> -
>         return err;
>  }
>
> --
> 1.7.11.7
>
