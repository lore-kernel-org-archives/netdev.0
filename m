From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: reset network device counters on the fly
Date: Tue, 6 Jan 2009 19:54:08 -0800
Message-ID: <20090106195408.51cd3810@extreme>
References: <3375b4020901061808g527cb872ia64b47147783b91c@mail.gmail.com>
	<49641399.80305@hp.com>
	<3375b4020901061917h2d61e9bbpdcc608e1cd9cfd9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>, netdev@vger.kernel.org
To: "Huascar Tejeda" <htejeda@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34667 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbZAGDyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 22:54:09 -0500
In-Reply-To: <3375b4020901061917h2d61e9bbpdcc608e1cd9cfd9a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jan 2009 23:17:57 -0400
"Huascar Tejeda" <htejeda@gmail.com> wrote:

> Thanks a lot for your reply and sorry for sending the patch as an
> attachment; Anyway, here is the patch in case someone finds it useful.

You need to follow the required format (see Documentation/SubmittingPatches).
Patch is not properly based and does not have certificate of origin.


Also for first time submitters I recommend using the script scripts/checkpatch.pl
to make sure there are no style issues:

ERROR: trailing whitespace
#90: FILE: core/dev.c:2680:
+/*^I$

ERROR: patch seems to be corrupt (line wrapped?)
#94: FILE: core/dev.c:2683:
*buffer, size_t len, loff_t * off)

WARNING: unnecessary cast may hide bugs, see http://c-faq.com/malloc/mallocnocast.html
#101: FILE: core/dev.c:2690:
+	char **argv = (char **) kmalloc(sizeof(char *), GFP_KERNEL);

WARNING: line over 80 characters
#105: FILE: core/dev.c:2694:
+	cmd_size = ( len > RSTDEV_COMMAND_MAX_SIZE ) ? RSTDEV_COMMAND_MAX_SIZE : len;

ERROR: space prohibited after that open parenthesis '('
#105: FILE: core/dev.c:2694:
+	cmd_size = ( len > RSTDEV_COMMAND_MAX_SIZE ) ? RSTDEV_COMMAND_MAX_SIZE : len;

ERROR: space prohibited before that close parenthesis ')'
#105: FILE: core/dev.c:2694:
+	cmd_size = ( len > RSTDEV_COMMAND_MAX_SIZE ) ? RSTDEV_COMMAND_MAX_SIZE : len;

ERROR: space prohibited after that open parenthesis '('
#106: FILE: core/dev.c:2695:
+	if ( copy_from_user(cmd, buffer, cmd_size) ) {

ERROR: space prohibited before that close parenthesis ')'
#106: FILE: core/dev.c:2695:
+	if ( copy_from_user(cmd, buffer, cmd_size) ) {

WARNING: braces {} are not necessary for single statement blocks
#106: FILE: core/dev.c:2695:
+	if ( copy_from_user(cmd, buffer, cmd_size) ) {
+		return -EFAULT;
+	}

ERROR: do not use C99 // comments
#110: FILE: core/dev.c:2699:
+	//Parse user input

ERROR: space prohibited after that open parenthesis '('
#111: FILE: core/dev.c:2700:
+	while ( (tmp_token = strsep(&cmd_ptr, " \n")) ) {

ERROR: space prohibited before that close parenthesis ')'
#111: FILE: core/dev.c:2700:
+	while ( (tmp_token = strsep(&cmd_ptr, " \n")) ) {

ERROR: space prohibited after that open parenthesis '('
#112: FILE: core/dev.c:2701:
+		if ( *tmp_token ) {

ERROR: space prohibited before that close parenthesis ')'
#112: FILE: core/dev.c:2701:
+		if ( *tmp_token ) {

WARNING: unnecessary cast may hide bugs, see http://c-faq.com/malloc/mallocnocast.html
#113: FILE: core/dev.c:2702:
+			argv[argc] = (char *) kmalloc((strlen(tmp_token) + 1) *

ERROR: space prohibited after that open parenthesis '('
#119: FILE: core/dev.c:2707:
+	if ( !argv[0] || !argv[1] ) {

ERROR: space prohibited before that close parenthesis ')'
#119: FILE: core/dev.c:2707:
+	if ( !argv[0] || !argv[1] ) {

ERROR: trailing whitespace
#128: FILE: core/dev.c:2715:
+^I$

WARNING: line over 80 characters
#136: FILE: core/dev.c:2723:
+					memset(stats, 0, sizeof(struct net_device_stats));

WARNING: line over 80 characters
#144: FILE: core/dev.c:2731:
+					memset(stats, 0, sizeof(struct net_device_stats));

WARNING: line over 80 characters
#147: FILE: core/dev.c:2734:
+				printk(KERN_INFO "Device %s not found!\n", ifname);

ERROR: need consistent spacing around '%' (ctx:WxV)
#147: FILE: core/dev.c:2734:
+				printk(KERN_INFO "Device %s not found!\n", ifname);
 				                         ^

ERROR: space required before that '!' (ctx:VxV)
#147: FILE: core/dev.c:2734:
+				printk(KERN_INFO "Device %s not found!\n", ifname);
 				                                     ^

ERROR: code indent should use tabs where possible
#163: FILE: core/dev.c:2750:
+        .write   = reset_device_counters,$

ERROR: Missing Signed-off-by: line(s)

total: 18 errors, 7 warnings, 92 lines checked

/tmp/cntr.patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.



> --- net/core/dev.c.orig	2009-01-05 17:38:51.000000000 -0400
> +++ net/core/dev.c	2009-01-06 16:36:35.000000000 -0400
> @@ -161,6 +161,11 @@
>  #define PTYPE_HASH_SIZE	(16)
>  #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
> 
> +/*
> + * 	Maximum length of the command sent by the user
> + */
> +#define RSTDEV_COMMAND_MAX_SIZE (15)
> +
>  static DEFINE_SPINLOCK(ptype_lock);
>  static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
>  static struct list_head ptype_all __read_mostly;	/* Taps */
> @@ -2671,10 +2676,78 @@
>  			    sizeof(struct seq_net_private));
>  }
> 
> +
> +/*	
> + *	Called when /proc/net/dev is written
> + */
> +static ssize_t reset_device_counters(struct file *file, const char
> *buffer, size_t len, loff_t * off)
> +{
> +	struct net_device *dev;
> +	struct net_device_stats *stats;
> +	char cmd[RSTDEV_COMMAND_MAX_SIZE];
> +	unsigned long cmd_size = 0;
> +	char *cmd_ptr = cmd;
> +	char **argv = (char **) kmalloc(sizeof(char *), GFP_KERNEL);
> +	char *tmp_token, *action, *ifname;
> +	int argc = 0;
> +
> +	cmd_size = ( len > RSTDEV_COMMAND_MAX_SIZE ) ? RSTDEV_COMMAND_MAX_SIZE : len;
> +	if ( copy_from_user(cmd, buffer, cmd_size) ) {
> +		return -EFAULT;
> +	}
> +
> +	//Parse user input

Useless comment and it is C++ format

> +	while ( (tmp_token = strsep(&cmd_ptr, " \n")) ) {
> +		if ( *tmp_token ) {
> +			argv[argc] = (char *) kmalloc((strlen(tmp_token) + 1) *
> sizeof(char), GFP_KERNEL);
> +			strcpy(argv[argc++], tmp_token);
> +		}
> +	}
> +
> +	if ( !argv[0] || !argv[1] ) {
> +		printk(KERN_INFO "Please usage: reset \"[network interface]\" or
> \"reset all\"\n");
> +		return -EINVAL;
> +	}
> +
> +	//TODO: create a struct for this.
> +	action = argv[0];
> +	ifname = argv[1];
> +	
> +	kfree(argv);
> +
> +	if ( strstr(action, "reset") ) {
> +		if ( !strcmp(ifname, "all") ) {
> +			for_each_netdev(&init_net, dev) {

Action should take place in network namespace of the caller

> +				stats = dev->get_stats(dev);
The stat structure in the device is not changeable.  Many devices regenerate
it on each call.

> +				if ( stats ) {
> +					memset(stats, 0, sizeof(struct net_device_stats));
> +				}
> +			}
> +		} else {
> +			dev = dev_get_by_name(&init_net, ifname);
> +			if ( dev ) {
> +				stats = dev->get_stats(dev);
> +				if ( stats ) {
> +					memset(stats, 0, sizeof(struct net_device_stats));
> +				}
> +			} else {
> +				printk(KERN_INFO "Device %s not found!\n", ifname);
> +				return -ENODEV;
> +			}
> +		}
> +	} else {
> +		printk(KERN_INFO "\"reset\" is the only supported command!\n");
> +		return -EINVAL;
> +	}
> +
> +	return cmd_size;
> +}
