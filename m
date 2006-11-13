From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20] [TCP] MD5 Signature Option (RFC2385) support.
Date: Mon, 13 Nov 2006 15:07:18 -0800 (PST)
Message-ID: <20061113.150718.58788536.davem@davemloft.net>
References: <20061110.171521.70104616.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32455
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933138AbWKMXHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 18:07:10 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061110.171521.70104616.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 10 Nov 2006 17:15:21 -0800 (PST)

> Based on implementation by Rick Payne.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

In the tcp_get_md5sig_pool sequences, if NULL is returned
the get_cpu() will leak.

+static inline
+struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
+{
+	return __tcp_get_md5sig_pool(get_cpu());
+}

This unconditionally does get_cpu().

+struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
+{
+	struct tcp_md5sig_pool **p;
+	spin_lock(&tcp_md5sig_pool_lock);
+	p = tcp_md5sig_pool;
+	if (p)
+		tcp_md5sig_users++;
+	spin_unlock(&tcp_md5sig_pool_lock);
+	return (p ? *per_cpu_ptr(p, cpu) : NULL);
+}

This will not do a put_cpu() if it returns NULL.

+	hp = tcp_get_md5sig_pool();
+	if (!hp)
+		goto clear_hash_noput;

And call sites like above do not do the put_cpu() either.

Probably the cleanest fix is to do something like this:

+static inline
+struct tcp_md5sig_pool		*tcp_get_md5sig_pool(void)
+{
+	int cpu = get_cpu();
+	struct tcp_md5sig_pool *ret = __tcp_get_md5sig_pool(cpu);
+	if (!ret)
+		put_cpu();
+	return ret;
+}
