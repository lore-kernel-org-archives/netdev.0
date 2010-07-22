From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC 1/1] netfilter: xtables: inclusion of xt_condition
Date: Thu, 22 Jul 2010 16:44:35 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
References: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com> <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, sameo@linux.intel.com,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-07-22 16:09, Luciano Coelho wrote:
>+static int condition_mt_check(const struct xt_mtchk_param *par)
>+{
>+	struct xt_condition_mtinfo *info = par->matchinfo;
>+	struct condition_variable *var;
>+	struct condition_net *cond_net =
>+		condition_pernet(current->nsproxy->net_ns);

Cc'ing Alexey who has done the netns support.

Alexey, you added par->net, but given Luciano just did it with 
current->nsproxy->net_ns, do we really need par->net?


>+int xt_condition_set_module_perms(const char *val, struct kernel_param *kp)
>+{
>+	unsigned long l;
>+	int ret;
>+	struct condition_net *cond_net =
>+		condition_pernet(current->nsproxy->net_ns);
>+
>+	if (!val) return -EINVAL;

newline before return.

>+	ret = strict_strtoul(val, 0, &l);
>+	if (ret == -EINVAL || ((uint)l != l))
>+		return -EINVAL;

>+	*((u32 *) ((u8 *) cond_net + (size_t) kp->arg)) = l;

I don't think we need this level of granularity; let the options be 
global, similar to what xt_hashlimit does.
(I am not even sure if kp->arg can be non-multiples-of-4, in which case 
this would be an alignment violation even.)

>+
>+	return 0;
>+}
>+EXPORT_SYMBOL_GPL(xt_condition_set_module_perms);
>+
>+int xt_condition_get_module_perms(char *buffer, struct kernel_param *kp)
>+{
>+	struct condition_net *cond_net =
>+		condition_pernet(current->nsproxy->net_ns);
>+
>+	return sprintf(buffer, "%u",
>+		       *((u32 *) ((u8 *) cond_net + (size_t) kp->arg)));
>+}
>+EXPORT_SYMBOL_GPL(xt_condition_get_module_perms);
>+
>+module_param_call(list_perms,
>+		  xt_condition_set_module_perms,
>+		  xt_condition_get_module_perms,
>+		  (void *) offsetof(struct condition_net, list_perms),
>+		  0600);
>+module_param_call(uid_perms,
>+		  xt_condition_set_module_perms,
>+		  xt_condition_get_module_perms,
>+		  (void *) offsetof(struct condition_net, uid_perms),
>+		  0600);
>+module_param_call(gid_perms,
>+		  xt_condition_set_module_perms,
>+		  xt_condition_get_module_perms,
>+		  (void *) offsetof(struct condition_net, gid_perms),
>+		  0600);
>+
>+module_init(condition_mt_init);
>+module_exit(condition_mt_exit);
>-- 
>1.7.0.4
>

