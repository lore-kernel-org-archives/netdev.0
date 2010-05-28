From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Fri, 28 May 2010 08:25:04 +0300
Message-ID: <1275024304.3754.45.camel@powerslave>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan,

Thanks a lot for your comments!

On Fri, 2010-05-28 at 01:17 +0200, ext Jan Engelhardt wrote:
> On Thursday 2010-05-27 22:54, Luciano Coelho wrote:
> >There are still some issues to be resolved:
> >
> >How to treat several rules for the same interface?
> >
> >We need a key for the timer list.  I'm using the targinfo pointer for that,
> >but this looks shaky, because there is no assurance that this pointer will
> >live for the entire lifetime of the rule.
> 
> Well xt_quota for example has its targinfo around at all times,
> as have other modules.

Great, so this will work.  I had checked the x_tables code and it seemed
that the lifetime of targinfo was sufficient, but I was not sure this
would be safe in the future.  Now, if this changes in the future, my
module won't be the only one to break ;)


> >This is now an x_tables target, so other protocols need to be implemented.
> 
> Huh? You're not looking at packets, so why does it need proto-specific
> stuff?

I need to associate the timers with specific interfaces, because it's
the idle time of the interfaces that the userspace in interested in.  I
didn't find any other way to associate the timers with them, except by
looking at the iniface and outiface values in ipt_ip (and eventually,
with IPv6 properly implemented, in ip6t_ip6).  This is what Patrick
suggested when he checked my previous patch [1] and triggered me to do a
major rework on my module ;)

Do you have any other suggestion on how I can associate the rules to
specific interfaces?


> >+static
> >+struct utimer_t *__utimer_find_by_info(const struct xt_idletimer_info *info)
> >+{
> >+	struct utimer_t *entry;
> >+
> >+	list_for_each_entry(entry, &active_utimer_head, entry) {
> >+		if (info == entry->info) {
> >+			return entry;
> >+		}
> >+	}
> >+
> >+	return NULL;
> >+}
> 
> Can do with less braces.

Sure.  These remained there after I removed some traces.  I'll clean
this up.


> >+static void utimer_expired(unsigned long data)
> >+{
> >+	struct utimer_t *timer = (struct utimer_t *) data;
> >+
> >+	pr_debug("xt_idletimer: timer '%s' ns %p expired\n",
> >+		 timer->name, timer->net);
> >+
> >+	schedule_work(&timer->work);
> >+}
> 
> You don't need xt_idletimer, because pr_debug already prints
> that (with #define pr_fmt(fmt) KBUILD_MODNAME ": " as many
> other modules do)

Ok, I'll change it.  Thanks for pointing out.


> >+
> >+static struct utimer_t *utimer_create(const char *name,
> >+				      struct net *net,
> >+				      const struct xt_idletimer_info *info)
> >+{
> >+	struct utimer_t *timer;
> >+
> >+	timer = kmalloc(sizeof(struct utimer_t), GFP_ATOMIC);
> >+	if (timer == NULL)
> >+		return NULL;
> 
> This is called from user context, so GFP_KERNEL will perfectly suffice.

Yup, will change.


> >+static int xt_idletimer_checkentry(const struct xt_tgchk_param *par)
> >+{
> >+	const struct xt_idletimer_info *info = par->targinfo;
> >+	const struct ipt_entry *entryinfo = par->entryinfo;
> >+	const struct ipt_ip *ip = &entryinfo->ip;
> 
> I'm not sure spying on ipt_ip is a long-term viable solution.

Do you have any other suggestions on how I could get an interface
associated with the rule? I thought about having the userspace pass the
interface as an option to the rule (like I already do for the timeout
value), but that looked ugly to me, since the interface can already be
defined as part of the ruleset.


> >+	pr_debug("xt_idletimer: checkentry targinfo %p\n", par->targinfo);
> >+
> >+	if (info->timeout == 0) {
> >+		pr_debug("xt_idletimer: timeout value is zero\n");
> >+		return -EINVAL;
> >+	}
> >+
> >+	/* FIXME: implement support for other protocol families */
> >+	switch (par->family) {
> >+	case NFPROTO_IPV4   :
> >+		pr_debug("xt_idletimer: NFPROTO_IPV4\n");
> >+		break;
> >+
> >+	default:
> >+		pr_debug("xt_idletimer: Unsupported protocol family family!\n");
> >+		return -EINVAL;
> >+	}
> >+
> >+	if (strlen(ip->iniface) == 0 && strlen(ip->outiface) == 0) {
> >+		pr_debug("xt_idletimer: in or out interface must "
> >+			 "be specified\n");
> >+		return -EINVAL;
> >+	}
> >+
> >+	if (utimer_create(ip->iniface, par->net, info) == NULL) {
> >+		pr_debug("xt_idletimer: failed to create timer\n");
> >+		return -ENOMEM;
> >+	}
> 
> What about outiface?
> What blows up when iniface is empty?

Ooops! I've redone this part of the code so many times and in this
version I completely forgot to include the outiface.  I'll fix it.


> >+static void xt_idletimer_destroy(const struct xt_tgdtor_param *par)
> >+{
> >+	const struct xt_idletimer_info *info = par->targinfo;
> >+
> >+	pr_debug("xt_idletimer: destroy targinfo %p\n", par->targinfo);
> >+
> >+	utimer_delete(info);
> >+}
> >+
> >+static int __init init(void)
> >+{
> >+	int ret;
> >+
> >+	ret = utimer_init();
> >+	if (ret)
> >+		return ret;
> >+
> >+	ret =  xt_register_target(&xt_idletimer);
> >+	if (ret < 0) {
> >+		utimer_fini();
> >+		return ret;
> >+	}
> >+
> >+	return 0;
> >+}
> >+
> >+static void __exit fini(void)
> >+{
> >+	xt_unregister_target(&xt_idletimer);
> >+	utimer_fini();
> >+}
> >+
> >+module_init(init);
> >+module_exit(fini);
> 
> Call it just exit?

Yes.


> Also give the functions better names (see other modules), that is going
> to be unrecognizable in stacktraces otherwise.

I agree.  These names are coming from the original code.  I thought
about changing them to something clearer, but didn't bother to do it
yet, because I was focusing on the actual functionality.  I'll change
the names.

Again, thanks for your comments.  I'll rework and submit v2 soon.

Ah, and please excuse my lameness of mistyping the netdev email address
when I submitted the patch.  I fixed it now.

[1]
http://article.gmane.org/gmane.comp.security.firewalls.netfilter.devel/33934


-- 
Cheers,
Luca.

