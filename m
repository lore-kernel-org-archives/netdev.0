From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [patch iproute2 v2 1/2] devlink: Change netlink attribute validation
Date: Wed, 3 May 2017 08:43:40 -0700
Message-ID: <CALgkqUqcdy47KiW8=NdTaPj7fCHQgDh2tE9sV=86TR+PM9uZBA@mail.gmail.com>
References: <1493810723-2536-1-git-send-email-jiri@resnulli.us> <1493810723-2536-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        arkadis@mellanox.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, mlxsw@mellanox.com,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35292 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751509AbdECPnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 11:43:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id d79so13809297wmi.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 08:43:41 -0700 (PDT)
In-Reply-To: <1493810723-2536-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 4:25 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
>
> Currently the netlink attribute resolving is done by a sequence of
> if's. Change the attribute resolving to table lookup.
>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  devlink/devlink.c | 103 ++++++++++++++++--------------------------------------
>  1 file changed, 30 insertions(+), 73 deletions(-)
>
> diff --git a/devlink/devlink.c b/devlink/devlink.c
> index e90226e..35220d8 100644
> --- a/devlink/devlink.c
> +++ b/devlink/devlink.c
> @@ -232,88 +232,45 @@ static bool dl_no_arg(struct dl *dl)
>         return dl_argc(dl) == 0;
>  }
>
> +static const enum mnl_attr_data_type devlink_policy[DEVLINK_ATTR_MAX + 1] = {
> +       [DEVLINK_ATTR_BUS_NAME] = MNL_TYPE_NUL_STRING,
> +       [DEVLINK_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
> +       [DEVLINK_ATTR_PORT_INDEX] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_PORT_TYPE] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_PORT_DESIRED_TYPE] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_PORT_NETDEV_IFINDEX] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_PORT_NETDEV_NAME] = MNL_TYPE_NUL_STRING,
> +       [DEVLINK_ATTR_PORT_IBDEV_NAME] = MNL_TYPE_NUL_STRING,
> +       [DEVLINK_ATTR_SB_INDEX] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_SB_SIZE] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_SB_INGRESS_POOL_COUNT] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_EGRESS_POOL_COUNT] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_INGRESS_TC_COUNT] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_EGRESS_TC_COUNT] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_POOL_INDEX] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_POOL_TYPE] = MNL_TYPE_U8,
> +       [DEVLINK_ATTR_SB_POOL_SIZE] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE] = MNL_TYPE_U8,
> +       [DEVLINK_ATTR_SB_THRESHOLD] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_SB_TC_INDEX] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_SB_OCC_CUR] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_SB_OCC_MAX] = MNL_TYPE_U32,
> +       [DEVLINK_ATTR_ESWITCH_MODE] = MNL_TYPE_U16,
> +       [DEVLINK_ATTR_ESWITCH_INLINE_MODE] = MNL_TYPE_U8,
> +};
> +
>  static int attr_cb(const struct nlattr *attr, void *data)
>  {
>         const struct nlattr **tb = data;
>         int type;
>
> -       type = mnl_attr_get_type(attr);
> -
>         if (mnl_attr_type_valid(attr, DEVLINK_ATTR_MAX) < 0)
>                 return MNL_CB_ERROR;
>
> -       if (type == DEVLINK_ATTR_BUS_NAME &&
> -           mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_DEV_NAME &&
> -           mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_INDEX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_TYPE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_DESIRED_TYPE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_NETDEV_IFINDEX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_NETDEV_NAME &&
> -           mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_PORT_IBDEV_NAME &&
> -           mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_INDEX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_SIZE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_INGRESS_POOL_COUNT &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_EGRESS_POOL_COUNT &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_INGRESS_TC_COUNT &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_EGRESS_TC_COUNT &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_POOL_INDEX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_POOL_TYPE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_POOL_SIZE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_THRESHOLD &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_TC_INDEX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_OCC_CUR &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_SB_OCC_MAX &&
> -           mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_ESWITCH_MODE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
> -               return MNL_CB_ERROR;
> -       if (type == DEVLINK_ATTR_ESWITCH_INLINE_MODE &&
> -           mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
> +       type = mnl_attr_get_type(attr);
> +       if (mnl_attr_validate(attr, devlink_policy[type]) < 0)
>                 return MNL_CB_ERROR;
> +
>         tb[type] = attr;
>         return MNL_CB_OK;
>  }
> --
> 2.7.4
>

Much better!!!  LGTM.

Reviewed-by: Greg Rose <gvrose8192@gmail.com>
