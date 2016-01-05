From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Tue, 5 Jan 2016 11:13:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCBD66E@AcuExch.aculab.com>
References: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Sasha Levin' <sasha.levin@oracle.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin
> Sent: 05 January 2016 02:26
> When we need to lock all buckets in the connection hashtable we'd attempt to
> lock 1024 spinlocks, which is way more preemption levels than supported by
> the kernel. Furthermore, this behavior was hidden by checking if lockdep is
> enabled, and if it was - use only 8 buckets(!).
> 
> Fix this by using a global lock and synchronize all buckets on it when we
> need to lock them all. This is pretty heavyweight, but is only done when we
> need to resize the hashtable, and that doesn't happen often enough (or at all).
...
> +static void nf_conntrack_lock_nested(spinlock_t *lock)
> +{
> +	spin_lock_nested(lock, SINGLE_DEPTH_NESTING);
> +	while (unlikely(nf_conntrack_locks_all)) {
> +		spin_unlock(lock);
> +		spin_lock(&nf_conntrack_locks_all_lock);
> +		spin_unlock(&nf_conntrack_locks_all_lock);
> +		spin_lock_nested(lock, SINGLE_DEPTH_NESTING);
> +	}
> +}
...
> @@ -102,16 +126,19 @@ static void nf_conntrack_all_lock(void)
>  {
>  	int i;
> 
> -	for (i = 0; i < CONNTRACK_LOCKS; i++)
> -		spin_lock_nested(&nf_conntrack_locks[i], i);
> +	spin_lock(&nf_conntrack_locks_all_lock);
> +	nf_conntrack_locks_all = true;
> +
> +	for (i = 0; i < CONNTRACK_LOCKS; i++) {
> +		spin_lock(&nf_conntrack_locks[i]);
> +		spin_unlock(&nf_conntrack_locks[i]);
> +	}
>  }

If spin_lock_nested() does anything like what I think its
name suggests then I suspect that deadlocks.

	David
