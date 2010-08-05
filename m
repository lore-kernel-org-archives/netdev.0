From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 2/2] netfilter: xt_condition: change the value from
 boolean to u32
Date: Thu, 5 Aug 2010 17:12:49 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008051705320.1104@obet.zrqbmnf.qr>
References: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com> <1281019269-30985-3-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, sameo@linux.intel.com
To: luciano.coelho@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33539 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756751Ab0HEPMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 11:12:50 -0400
In-Reply-To: <1281019269-30985-3-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-08-05 16:41, luciano.coelho@nokia.com wrote:

> struct xt_condition_mtinfo {
>-	char name[31];
>+	char name[27];
> 	__u8 invert;
>+	__u32 value;

Please also bump the .revision field to 2 with this patch so that
testing can always proceed without an ABI clash.
(rev 2 would then remain over the course of the remaining patches 
you submit.)
(rev 0 = ipt_condition/pom-ng; rev 1 = xt_condition from Xt-a)

>+	char buf[14];

	char buf[sizeof("4294967296")];

seems more intuitive :-)

>+	unsigned long long value;
>+
>+	if (length == 0)
>+		return 0;
>+
>+	if (length > sizeof(buf))
>+		return -EINVAL;
>+
>+	if (copy_from_user(buf, input, length) != 0)
>+		return -EFAULT;
>+
>+	buf[length - 1] = '\0';
>+
>+	if (strict_strtoull(buf, 0, &value) != 0)
>+		return -EINVAL;
>+
>+	if (value > (u32) value)
>+		return -EINVAL;

Is it possible to use just strict_strtoul?

>-	return var->enabled ^ info->invert;
>+	return (var->value == info->value) ^ info->invert;

Since the condition value (cdmark) was thought of an nfmark-style thing, 
would it perhaps make sense to model it after it

	return (var->value & ~info->mask) ^ info->value;

Other opinions?

