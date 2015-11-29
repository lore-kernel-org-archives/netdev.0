From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon interface
Date: Sun, 29 Nov 2015 11:04:07 +0200
Message-ID: <CAJ3xEMgUt4a-Mq8DO0a_Vm-UYJsHsrxYyGh23=rSAiZ12S9oGQ@mail.gmail.com>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
	<1448628359-20077-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, idosch@mellanox.com,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33242 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbK2JEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 04:04:08 -0500
Received: by igcmv3 with SMTP id mv3so52945699igc.0
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 01:04:07 -0800 (PST)
In-Reply-To: <1448628359-20077-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[..]
> +enum mlxsw_hwmon_attr_type {
> +       MLXSW_HWMON_ATTR_TYPE_TEMP,
> +       MLXSW_HWMON_ATTR_TYPE_TEMP_MAX,
> +};
> +
> +static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
> +                                enum mlxsw_hwmon_attr_type attr_type,
> +                                unsigned int type_index, unsigned int num) {
> +       struct mlxsw_hwmon_attr *mlxsw_hwmon_attr;
> +       unsigned int attr_index;
> +
> +       attr_index = mlxsw_hwmon->attrs_count;
> +       mlxsw_hwmon_attr = &mlxsw_hwmon->hwmon_attrs[attr_index];
> +
> +       switch (attr_type) {
> +       case MLXSW_HWMON_ATTR_TYPE_TEMP:
> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_show;
> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
> +                        "temp%u_input", num + 1);
> +               break;
> +       case MLXSW_HWMON_ATTR_TYPE_TEMP_MAX:
> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_max_show;
> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
> +                        "temp%u_highest", num + 1);
> +               break;
> +       default:
> +               BUG();

Guys, do we really have to crash the whole system just b/c somehow an unknown
value propagated here during **init** time?

I don't think so.

> +
> +       mlxsw_hwmon_attr->type_index = type_index;
> +       mlxsw_hwmon_attr->hwmon = mlxsw_hwmon;
> +       mlxsw_hwmon_attr->dev_attr.attr.name = mlxsw_hwmon_attr->name;
> +       sysfs_attr_init(&mlxsw_hwmon_attr->dev_attr.attr);
> +
> +       mlxsw_hwmon->attrs[attr_index] = &mlxsw_hwmon_attr->dev_attr.attr;
> +       mlxsw_hwmon->attrs_count++;
> +}
> +

[...]
> +int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
> +                    const struct mlxsw_bus_info *mlxsw_bus_info,
> +                    struct mlxsw_hwmon **p_hwmon)
> +{
> +       struct mlxsw_hwmon *mlxsw_hwmon;
> +       struct device *hwmon_dev;
> +       int err;
> +
> +       mlxsw_hwmon = kzalloc(sizeof(*mlxsw_hwmon), GFP_KERNEL);
> +       if (!mlxsw_hwmon)
> +               return -ENOMEM;
> +       mlxsw_hwmon->core = mlxsw_core;
> +       mlxsw_hwmon->bus_info = mlxsw_bus_info;
> +
> +       err = mlxsw_hwmon_temp_init(mlxsw_hwmon);
> +       if (err)
> +               goto err_temp_init;
> +
> +       mlxsw_hwmon->groups[0] = &mlxsw_hwmon->group;
> +       mlxsw_hwmon->group.attrs = mlxsw_hwmon->attrs;
> +
> +       hwmon_dev = devm_hwmon_device_register_with_groups(mlxsw_bus_info->dev,
> +                                                          "mlxsw",
> +                                                          mlxsw_hwmon,
> +                                                          mlxsw_hwmon->groups);
> +       if (IS_ERR(hwmon_dev)) {
> +               err = PTR_ERR(hwmon_dev);
> +               goto err_hwmon_register;
> +       }
> +
> +       mlxsw_hwmon->hwmon_dev = hwmon_dev;
> +       *p_hwmon = mlxsw_hwmon;
> +       return 0;
> +
> +err_hwmon_register:
> +err_temp_init:
> +       kfree(mlxsw_hwmon);
> +       return err;
> +}
> +
