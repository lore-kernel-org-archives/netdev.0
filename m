From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon interface
Date: Thu, 3 Dec 2015 00:05:48 +0200
Message-ID: <CAJ3xEMhGv9nTq+CtpX=e4E+4WpipVnc---EUOEqxJ06xOSBsog@mail.gmail.com>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
	<1448628359-20077-5-git-send-email-jiri@resnulli.us>
	<CAJ3xEMgUt4a-Mq8DO0a_Vm-UYJsHsrxYyGh23=rSAiZ12S9oGQ@mail.gmail.com>
	<20151129104918.GC2194@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35142 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756438AbbLBWFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:05:48 -0500
Received: by ioc74 with SMTP id 74so61244236ioc.2
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 14:05:48 -0800 (PST)
In-Reply-To: <20151129104918.GC2194@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2015 at 12:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sun, Nov 29, 2015 at 10:04:07AM CET, gerlitz.or@gmail.com wrote:
>>[..]
>>> +enum mlxsw_hwmon_attr_type {
>>> +       MLXSW_HWMON_ATTR_TYPE_TEMP,
>>> +       MLXSW_HWMON_ATTR_TYPE_TEMP_MAX,
>>> +};
>>> +
>>> +static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
>>> +                                enum mlxsw_hwmon_attr_type attr_type,
>>> +                                unsigned int type_index, unsigned int num) {
>>> +       struct mlxsw_hwmon_attr *mlxsw_hwmon_attr;
>>> +       unsigned int attr_index;
>>> +
>>> +       attr_index = mlxsw_hwmon->attrs_count;
>>> +       mlxsw_hwmon_attr = &mlxsw_hwmon->hwmon_attrs[attr_index];
>>> +
>>> +       switch (attr_type) {
>>> +       case MLXSW_HWMON_ATTR_TYPE_TEMP:
>>> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_show;
>>> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
>>> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
>>> +                        "temp%u_input", num + 1);
>>> +               break;
>>> +       case MLXSW_HWMON_ATTR_TYPE_TEMP_MAX:
>>> +               mlxsw_hwmon_attr->dev_attr.show = mlxsw_hwmon_temp_max_show;
>>> +               mlxsw_hwmon_attr->dev_attr.attr.mode = S_IRUGO;
>>> +               snprintf(mlxsw_hwmon_attr->name, sizeof(mlxsw_hwmon_attr->name),
>>> +                        "temp%u_highest", num + 1);
>>> +               break;
>>> +       default:
>>> +               BUG();
>>
>> Guys, do we really have to crash the whole system just b/c somehow an
>> unknown value propagated here during **init** time?
>>
>> I don't think so.

> "default" case simply *cannot* happen. If it happens, it is a stack
> corruption or some other fatal problem. I believe that BUG is
> appropriate at these cases.

Jiri, as Dave commented today on the LAG series,  BUG_ON() is bad and
is only to ever be used when the kernel's continued operation is
absolutely impossible, can we change here to WARN_ON() or a like?

Or.

>>> +
>>> +       mlxsw_hwmon_attr->type_index = type_index;
>>> +       mlxsw_hwmon_attr->hwmon = mlxsw_hwmon;
>>> +       mlxsw_hwmon_attr->dev_attr.attr.name = mlxsw_hwmon_attr->name;
>>> +       sysfs_attr_init(&mlxsw_hwmon_attr->dev_attr.attr);
>>> +
>>> +       mlxsw_hwmon->attrs[attr_index] = &mlxsw_hwmon_attr->dev_attr.attr;
>>> +       mlxsw_hwmon->attrs_count++;
>>> +}
>>> +
>>
>>[...]
>>> +int mlxsw_hwmon_init(struct mlxsw_core *mlxsw_core,
>>> +                    const struct mlxsw_bus_info *mlxsw_bus_info,
>>> +                    struct mlxsw_hwmon **p_hwmon)
>>> +{
>>> +       struct mlxsw_hwmon *mlxsw_hwmon;
>>> +       struct device *hwmon_dev;
>>> +       int err;
>>> +
>>> +       mlxsw_hwmon = kzalloc(sizeof(*mlxsw_hwmon), GFP_KERNEL);
>>> +       if (!mlxsw_hwmon)
>>> +               return -ENOMEM;
>>> +       mlxsw_hwmon->core = mlxsw_core;
>>> +       mlxsw_hwmon->bus_info = mlxsw_bus_info;
>>> +
>>> +       err = mlxsw_hwmon_temp_init(mlxsw_hwmon);
>>> +       if (err)
>>> +               goto err_temp_init;
>>> +
>>> +       mlxsw_hwmon->groups[0] = &mlxsw_hwmon->group;
>>> +       mlxsw_hwmon->group.attrs = mlxsw_hwmon->attrs;
>>> +
>>> +       hwmon_dev = devm_hwmon_device_register_with_groups(mlxsw_bus_info->dev,
>>> +                                                          "mlxsw",
>>> +                                                          mlxsw_hwmon,
>>> +                                                          mlxsw_hwmon->groups);
>>> +       if (IS_ERR(hwmon_dev)) {
>>> +               err = PTR_ERR(hwmon_dev);
>>> +               goto err_hwmon_register;
>>> +       }
>>> +
>>> +       mlxsw_hwmon->hwmon_dev = hwmon_dev;
>>> +       *p_hwmon = mlxsw_hwmon;
>>> +       return 0;
>>> +
>>> +err_hwmon_register:
>>> +err_temp_init:
>>> +       kfree(mlxsw_hwmon);
>>> +       return err;
>>> +}
>>> +
