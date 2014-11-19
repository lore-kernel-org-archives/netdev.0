From: "Hamad Kadmany" <hkadmany@codeaurora.org>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Wed, 19 Nov 2014 12:28:19 -0000
Message-ID: <03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
References: <93856491220bda9aede41a9571fb1ac1.squirrel@www.codeaurora.org>
    <20141117130201.GB1872@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Hamad Kadmany" <hkadmany@codeaurora.org>, netdev@vger.kernel.org
To: "Jiri Pirko" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:55174 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbaKSM2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 07:28:21 -0500
In-Reply-To: <20141117130201.GB1872@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, November 17, 2014 1:02 pm, Jiri Pirko wrote:
>
> Nak.
>
> I don't like this patch. The plan for team was keep things simple and to
> have single userspace api using netlink, as that is the correct way to
> deal with things. Sysfs for this use-case is not. Please, use netlink api.

Using team driver requires using libnl3. In Android based platforms, libnl3 is not supported, and libnl3 license poses constraints in Android's user-space.

This is the reason for the this change, to have at least the team options exposed through sysfs.


>
>>
>>Signed-off-by: Hamad Kadmany <hkadmany@codeaurora.org>
>>---
>> drivers/net/team/team.c | 282 ++++++++++++++++++++++++++++++++++++++++++++++--
>> include/linux/if_team.h |   3 +
>> 2 files changed, 278 insertions(+), 7 deletions(-)
>>
>>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>index 1222229..afd2f8f 100644
>>--- a/drivers/net/team/team.c
>>+++ b/drivers/net/team/team.c
>>@@ -110,8 +110,198 @@ struct team_option_inst { /* One for each option instance */
>> 	struct team_option_inst_info info;
>> 	bool changed;
>> 	bool removed;
>>+	bool dev_attr_file_exist;
>>+	struct device_attribute dev_attr; /* corresponding sysfs attribute */
>> };
>>
>>+static struct attribute *team_sysfs_attrs[] = {
>>+	NULL,
>>+};
>>+
>>+static struct attribute_group team_sysfs_attr_group = {
>>+	.attrs = team_sysfs_attrs,
>>+};
>>+
>>+/* Device attributes (sysfs) */
>>+
>>+static ssize_t show_attribute(struct device *dev,
>>+			      struct device_attribute *attr,
>>+			      char *buf)
>>+{
>>+	struct team *team = dev_get_drvdata(dev);
>>+	struct team_option_inst *opt_inst;
>>+	ssize_t ret;
>>+	struct team_option *option;
>>+	struct team_gsetter_ctx ctx;
>>+
>>+	if (mutex_lock_interruptible(&team->lock))
>>+		return -ERESTARTSYS;
>>+
>>+	opt_inst = container_of(attr, struct team_option_inst, dev_attr);
>>+	option = opt_inst->option;
>>+	if (!option->getter) {
>>+		ret = -EOPNOTSUPP;
>>+		netdev_err(team->dev,
>>+			   "Option %s is write only\n", attr->attr.name);
>>+		goto exit;
>>+	}
>>+
>>+	ctx.info = &opt_inst->info;
>>+	/* let the option getter do its job */
>>+	ret = option->getter(team, &ctx);
>>+	if (ret)
>>+		goto exit;
>>+
>>+	/* translate option's output into sysfs output */
>>+	switch (option->type) {
>>+	case TEAM_OPTION_TYPE_U32:
>>+		ret = scnprintf(buf, PAGE_SIZE, "%u\n", ctx.data.u32_val);
>>+		break;
>>+	case TEAM_OPTION_TYPE_STRING:
>>+		ret = scnprintf(buf, PAGE_SIZE, "%s\n", ctx.data.str_val);
>>+		break;
>>+	case TEAM_OPTION_TYPE_BINARY:
>>+		if (ctx.data.bin_val.len > PAGE_SIZE) {
>>+			netdev_err(team->dev,
>>+				   "Option output is too long (%d)\n",
>>+				   ctx.data.bin_val.len);
>>+			break;
>>+		}
>>+
>>+		memcpy(buf, ctx.data.bin_val.ptr, ctx.data.bin_val.len);
>>+		ret = ctx.data.bin_val.len;
>>+		break;
>>+	case TEAM_OPTION_TYPE_BOOL:
>>+		ret = scnprintf(buf, PAGE_SIZE, "%d\n", ctx.data.bool_val);
>>+		break;
>>+	case TEAM_OPTION_TYPE_S32:
>>+		ret = scnprintf(buf, PAGE_SIZE, "%d\n", ctx.data.s32_val);
>>+		break;
>>+	default:
>>+		BUG();
>>+	}
>>+
>>+exit:
>>+	mutex_unlock(&team->lock);
>>+
>>+	return ret;
>>+}
>>+
>>+static int team_nl_send_event_options_get(struct team *team,
>>+					  struct list_head *sel_opt_inst_list);
>>+
>>+static ssize_t set_attribute(struct device *dev,
>>+			     struct device_attribute *attr,
>>+			     const char *buf, size_t count)
>>+{
>>+	struct team_option_inst *opt_inst;
>>+	struct team *team = dev_get_drvdata(dev);
>>+	int err = 0;
>>+	struct team_option *option = NULL;
>>+	struct team_gsetter_ctx ctx;
>>+
>>+	LIST_HEAD(opt_inst_list);
>>+
>>+	if (mutex_lock_interruptible(&team->lock))
>>+		return -ERESTARTSYS;
>>+
>>+	opt_inst = container_of(attr, struct team_option_inst, dev_attr);
>>+	option = opt_inst->option;
>>+	if (!option->setter) {
>>+		netdev_err(team->dev,
>>+			   "Option %s is read only\n", attr->attr.name);
>>+		err = -EOPNOTSUPP;
>>+		goto exit;
>>+	}
>>+
>>+	ctx.info = &opt_inst->info;
>>+
>>+	/* translate sysfs input into option's input */
>>+	switch (option->type) {
>>+	case TEAM_OPTION_TYPE_U32:
>>+		err = kstrtoint(buf, 0, &ctx.data.u32_val);
>>+		break;
>>+	case TEAM_OPTION_TYPE_STRING:
>>+		if (count > TEAM_STRING_MAX_LEN) {
>>+			netdev_err(team->dev,
>>+				   "Input buffer too long (%zu)\n", count);
>>+			err = -EINVAL;
>>+			break;
>>+		}
>>+		ctx.data.str_val = buf;
>>+		break;
>>+	case TEAM_OPTION_TYPE_BINARY:
>>+		ctx.data.bin_val.len = count;
>>+		ctx.data.bin_val.ptr = buf;
>>+		break;
>>+	case TEAM_OPTION_TYPE_BOOL:
>>+		err = strtobool(buf, &ctx.data.bool_val);
>>+		break;
>>+	case TEAM_OPTION_TYPE_S32:
>>+		err = kstrtoint(buf, 0, &ctx.data.s32_val);
>>+		break;
>>+	default:
>>+		BUG();
>>+	}
>>+
>>+	if (err) {
>>+		netdev_err(team->dev, "Failed to translate input buffer\n");
>>+		goto exit;
>>+	}
>>+
>>+	/* let the option setter do its job */
>>+	err = option->setter(team, &ctx);
>>+	if (err)
>>+		goto exit;
>>+
>>+	/* propagate option changed event */
>>+	opt_inst->changed = true;
>>+	list_add(&opt_inst->tmp_list, &opt_inst_list);
>>+	err = team_nl_send_event_options_get(team, &opt_inst_list);
>>+	if (err == -ESRCH) /* no listeners, not a real error */
>>+		err = 0;
>>+
>>+exit:
>>+	mutex_unlock(&team->lock);
>>+
>>+	if (!err)
>>+		err = count;
>>+	return err;
>>+}
>>+
>>+/* create sysfs attribute for each option that is being registered */
>>+static int __team_option_add_sysfs_attr(struct team *team,
>>+					struct team_option_inst *opt_inst,
>>+					bool create_sysfs_file)
>>+{
>>+	int err = 0;
>>+	struct device_attribute *new_dev_attr = &opt_inst->dev_attr;
>>+
>>+	new_dev_attr->attr.name = opt_inst->option->name;
>>+	new_dev_attr->attr.mode = S_IRUGO | S_IWUSR;
>>+	new_dev_attr->show = show_attribute;
>>+	new_dev_attr->store = set_attribute;
>>+
>>+	if (create_sysfs_file) {
>>+		err = sysfs_create_file(&team->dev->dev.kobj,
>>+					&new_dev_attr->attr);
>>+		if (err)
>>+			netdev_err(team->dev,
>>+				   "Failed to create sysfs attribute %s\n",
>>+				   new_dev_attr->attr.name);
>>+	}
>>+
>>+	return err;
>>+}
>>+
>>+static void __team_option_del_sysfs_attr(struct team *team,
>>+					 struct team_option_inst *opt_inst)
>>+{
>>+	if (opt_inst->dev_attr_file_exist)
>>+		sysfs_remove_file(&team->dev->dev.kobj,
>>+				  &opt_inst->dev_attr.attr);
>>+}
>>+
>> static struct team_option *__team_find_option(struct team *team,
>> 					      const char *opt_name)
>> {
>>@@ -124,8 +314,10 @@ static struct team_option *__team_find_option(struct team *team,
>> 	return NULL;
>> }
>>
>>-static void __team_option_inst_del(struct team_option_inst *opt_inst)
>>+static void __team_option_inst_del(struct team *team,
>>+				   struct team_option_inst *opt_inst)
>> {
>>+	__team_option_del_sysfs_attr(team, opt_inst);
>> 	list_del(&opt_inst->list);
>> 	kfree(opt_inst);
>> }
>>@@ -137,7 +329,7 @@ static void __team_option_inst_del_option(struct team *team,
>>
>> 	list_for_each_entry_safe(opt_inst, tmp, &team->option_inst_list, list) {
>> 		if (opt_inst->option == option)
>>-			__team_option_inst_del(opt_inst);
>>+			__team_option_inst_del(team, opt_inst);
>> 	}
>> }
>>
>>@@ -162,6 +354,7 @@ static int __team_option_inst_add(struct team *team, struct team_option *option,
>> 		opt_inst->info.array_index = i;
>> 		opt_inst->changed = true;
>> 		opt_inst->removed = false;
>>+		opt_inst->dev_attr_file_exist = false;
>> 		list_add_tail(&opt_inst->list, &team->option_inst_list);
>> 		if (option->init) {
>> 			err = option->init(team, &opt_inst->info);
>>@@ -170,6 +363,20 @@ static int __team_option_inst_add(struct team *team, struct team_option *option,
>> 		}
>>
>> 	}
>>+
>>+	/* add sysfs attribute. per-port and array options are skipped */
>>+	if (!option->per_port && !option->array_size) {
>>+		/* create the sysfs file only if our state allows it */
>>+		bool create_sysfs_file = device_is_registered(&team->dev->dev);
>>+
>>+		err = __team_option_add_sysfs_attr(team, opt_inst,
>>+						   create_sysfs_file);
>>+		if (err)
>>+			return err;
>>+
>>+		opt_inst->dev_attr_file_exist = true;
>>+	}
>>+
>> 	return 0;
>> }
>>
>>@@ -218,7 +425,7 @@ static void __team_option_inst_del_port(struct team *team,
>> 	list_for_each_entry_safe(opt_inst, tmp, &team->option_inst_list, list) {
>> 		if (opt_inst->option->per_port &&
>> 		    opt_inst->info.port == port)
>>-			__team_option_inst_del(opt_inst);
>>+			__team_option_inst_del(team, opt_inst);
>> 	}
>> }
>>
>>@@ -337,6 +544,51 @@ static void __team_options_unregister(struct team *team,
>>
>> static void __team_options_change_check(struct team *team);
>>
>>+static void team_attr_grp_free(struct team *team)
>>+{
>>+	kfree(team->attr_grp.attrs);
>>+}
>>+
>>+/* allocate attribute group for creating sysfs for team's own options */
>>+static int team_attr_grp_alloc(struct team *team)
>>+{
>>+	struct attribute **attributes;
>>+	struct team_option_inst *opt_inst;
>>+	int num_attr = 0;
>>+	struct team_option *option;
>>+
>>+	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
>>+		option = opt_inst->option;
>>+		/* per-port and array options currently not supported as
>>+		 * sysfs attributes
>>+		 */
>>+		if (option->per_port || option->array_size)
>>+			continue;
>>+
>>+		num_attr++;
>>+	}
>>+
>>+	/* +1 for having NULL as last item in the array */
>>+	attributes = kzalloc((num_attr + 1) * sizeof(*attributes), GFP_KERNEL);
>>+	if (!attributes)
>>+		return -ENOMEM;
>>+	team->attr_grp.attrs = attributes;
>>+
>>+	num_attr = 0;
>>+	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
>>+		option = opt_inst->option;
>>+		/* per-port and array options currently not supported as
>>+		 * sysfs attributes
>>+		 */
>>+		if (option->per_port || option->array_size)
>>+			continue;
>>+
>>+		attributes[num_attr++] = &opt_inst->dev_attr.attr;
>>+	}
>>+
>>+	return 0;
>>+}
>>+
>> int team_options_register(struct team *team,
>> 			  const struct team_option *option,
>> 			  size_t option_count)
>>@@ -1380,15 +1632,28 @@ static int team_init(struct net_device *dev)
>>
>> 	INIT_LIST_HEAD(&team->option_list);
>> 	INIT_LIST_HEAD(&team->option_inst_list);
>>-	err = team_options_register(team, team_options, ARRAY_SIZE(team_options));
>>+
>>+	err = team_options_register(team, team_options,
>>+				    ARRAY_SIZE(team_options));
>> 	if (err)
>> 		goto err_options_register;
>> 	netif_carrier_off(dev);
>>
>> 	team_set_lockdep_class(dev);
>>
>>+	/* store team context, to be used by Device attributes getter/setter */
>>+	dev_set_drvdata(&dev->dev, team);
>>+
>>+	/* allocate and register sysfs attributes for team's own options */
>>+	err = team_attr_grp_alloc(team);
>>+	if (err)
>>+		goto err_grp_alloc;
>>+	dev->sysfs_groups[0] = &team->attr_grp;
>>+
>> 	return 0;
>>
>>+err_grp_alloc:
>>+	team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
>> err_options_register:
>> 	team_queue_override_fini(team);
>> err_team_queue_override_init:
>>@@ -1407,9 +1672,15 @@ static void team_uninit(struct net_device *dev)
>> 	list_for_each_entry_safe(port, tmp, &team->port_list, list)
>> 		team_port_del(team, port->dev);
>>
>>+	sysfs_remove_group(&team->dev->dev.kobj, &team->attr_grp);
>>+	team_attr_grp_free(team);
>>+	/* set to dummy group to avoid double free by core */
>>+	dev->sysfs_groups[0] = &team_sysfs_attr_group;
>>+
>> 	__team_change_mode(team, NULL); /* cleanup */
>> 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
>> 	team_queue_override_fini(team);
>>+
>> 	mutex_unlock(&team->lock);
>> }
>>
>>@@ -2194,9 +2465,6 @@ static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_info *info)
>> 	return err;
>> }
>>
>>-static int team_nl_send_event_options_get(struct team *team,
>>-					  struct list_head *sel_opt_inst_list);
>>-
>> static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
>> {
>> 	struct team *team;
>>diff --git a/include/linux/if_team.h b/include/linux/if_team.h
>>index 25b8b15..2e9fb2a 100644
>>--- a/include/linux/if_team.h
>>+++ b/include/linux/if_team.h
>>@@ -188,6 +188,9 @@ struct team {
>> 	struct list_head option_list;
>> 	struct list_head option_inst_list; /* list of option instances */
>>
>>+	/* attribute group for registering team's own options at init */
>>+	struct attribute_group attr_grp;
>>+
>> 	const struct team_mode *mode;
>> 	struct team_mode_ops ops;
>> 	bool user_carrier_enabled;
>>--
>>1.8.5.2
>>--
>>Qualcomm Israel, on behalf of Qualcomm Innovation Center, Inc.
>>The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
>>a Linux Foundation Collaborative Project
>>
>
