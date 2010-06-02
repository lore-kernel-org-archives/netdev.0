From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: Xtables: idletimer target implementation
Date: Wed, 02 Jun 2010 16:37:16 +0300
Message-ID: <1275485836.22501.24.camel@chilepepper>
References: <1275479897-16779-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021444480.14585@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1006021444480.14585@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan,

Thanks for your prompt review! I'll send v2 with the fixes you
suggested.


On Wed, 2010-06-02 at 14:54 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-06-02 13:58, Luciano Coelho wrote:
> >+
> >+#ifndef _XT_IDLETIMER_H
> >+#define _XT_IDLETIMER_H
> >+
> >+#define MAX_LABEL_SIZE 32
> >+
> >+struct idletimer_tg_info {
> >+	unsigned int timeout;
> >+
> >+	char label[MAX_LABEL_SIZE];
> >+};
> 
> As per "Writing Netfilter Modules" e-book, using "int" is a no-no.

Sorry I missed that one.  Fixed in v2.

 
> >+config NETFILTER_XT_TARGET_IDLETIMER
> >+	tristate  "IDLETIMER target support"
> 
> depends on NETFILTER_ADVANCED

Yes.


> >xt_IDLETIMER.c
> >+struct idletimer_tg_attr {
> >+        struct attribute attr;
> >+	ssize_t	(*show)(struct kobject *kobj,
> >+			struct attribute *attr, char *buf);
> >+};
> 
> Some indent seems to have gone wrong.

Fixed.


> >+	attr->attr.name = kstrdup(info->label, GFP_KERNEL);
> 
> Need to check return value!

Oops! Fixed in v2.  Also added sysfs_remove_file_from_group() if the
struct idletimer_tg allocation fails.


> >+	attr->attr.mode = 0444;
> 
> attr->attr.mode = S_IRUGO;

Fixed.


> 
> >+static struct xt_target idletimer_tg __read_mostly = {
> >+	.name		= "IDLETIMER",
> >+	.family		= NFPROTO_IPV4,
> 
> NFPROTO_UNSPEC

Yeps, this is a remain from the previous (and ugly) read from ipt_ip.
Fixed.


> 
> >+	.target		= idletimer_tg_target,
> >+	.targetsize     = sizeof(struct idletimer_tg_info),
> >+	.checkentry	= idletimer_tg_checkentry,
> >+	.destroy        = idletimer_tg_destroy,
> >+	.me		= THIS_MODULE,
> >+};
> >+
> >+static int __init idletimer_tg_init(void)
> >+{
> >+	int ret;
> >+
> >+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
> >+						   &THIS_MODULE->mkobj.kobj);
> >+	if (!idletimer_tg_kobj)
> >+		return -ENOMEM;
> >+
> >+	/* FIXME: do we want to keep it in the module or in the net class? */
> 
> I have only ever seen interfaces in /sys/class/net, so it might be
> wise to keep it that way in light of scripts doing 
> echo /sys/class/net/*  to get a list of interfaces.

Yes, this is the only reason why I haven't put it under the net class,
which would probably look cleaner.  In other classes it seems to be
common to add misc attributes, but the net class (as of now) only
contains interface subclasses, as you said.

I'll change the FIXME to a clearer comment.


> Looks quite ok.

Thanks!


-- 
Cheers,
Luca.

